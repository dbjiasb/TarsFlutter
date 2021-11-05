// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

// import 'package:flutter/services.dart';
import 'package:flutter/src/services/binding.dart';
import 'package:flutter/src/services/binary_messenger.dart';
import 'package:logger/logger.dart';
import 'arguments/invoke/invoke_argument.dart';
import 'arguments/invoke/invoke_argument0.dart';
import 'arguments/register/register_parameter.dart';
import 'tars_message_codec.dart';
import 'tars_message_codecs.dart';

/// A named channel for communicating with platform plugins using asynchronous
/// method calls.
///
/// Method calls are encoded into binary before being sent, and binary results
/// received are decoded into Dart values. The [MethodCodec] used must be
/// compatible with the one used by the platform plugin. This can be achieved
/// by creating a method channel counterpart of this channel on the
/// platform side. The Dart type of arguments and results is `dynamic`,
/// but only values supported by the specified [MethodCodec] can be used.
/// The use of unsupported values should be considered programming errors, and
/// will result in exceptions being thrown. The null value is supported
/// for all codecs.
///
/// The logical identity of the channel is given by its name. Identically named
/// channels will interfere with each other's communication.
///
/// See: <https://flutter.dev/platform-channels/>
class TarsMethodChannel {
  /// Creates a [TarsMethodChannel] with the specified [name].
  ///
  /// The [codec] used will be [StandardMethodCodec], unless otherwise
  /// specified.
  ///
  /// The [name] and [codec] arguments cannot be null. The default [ServicesBinding.defaultBinaryMessenger]
  /// instance is used if [binaryMessenger] is null.
  TarsMethodChannel(this.name,
      [this.codec = const TarsStandardMethodCodec(),
      BinaryMessenger? binaryMessenger])
      : assert(name != null),
        assert(codec != null),
        _binaryMessenger = binaryMessenger {
    incomingMethodCallHandler = IncomingMethodCallHandler(codec);
  }

  /// The logical channel on which communication happens, not null.
  final String name;

  /// The message codec used by this channel, not null.
  final TarsMethodCodec codec;

  final logger = Logger();

  /// The messenger used by this channel to send platform messages.
  ///
  /// The messenger may not be null.
  BinaryMessenger get binaryMessenger {
    var temp =
        _binaryMessenger ?? ServicesBinding.instance!.defaultBinaryMessenger;
    temp.setMessageHandler(
        name,
        (ByteData? message) =>
            incomingMethodCallHandler.handleAsMethodCall(message));
    return temp;
  }

  final BinaryMessenger? _binaryMessenger;

  late final IncomingMethodCallHandler incomingMethodCallHandler;

  @optionalTypeArgs
  Future<T?> invokeMethod<T>(String method, InvokeArgument arguments,
      [bool missingOk = true, RegisterParameter? resultParameter]) async {
    assert(method != null);
    assert(arguments != null);

    logger.d("invokeMethod $method");

    final ByteData? result = await binaryMessenger.send(
      name,
      codec.encodeMethodCall(TarsMethodCall(method, arguments)),
    );
    if (result == null) {
      if (missingOk) {
        return null;
      }
      logger.e(
          "invokeMethod error: No implementation found for method $method on channel $name");
      throw TarsMissingPluginException(
          'No implementation found for method $method on channel $name');
    }
    return codec.decodeEnvelope(result, resultParameter) as T?;
  }

  void registerMethodCallHandler(final MethodHandler handler) {
    incomingMethodCallHandler.registerMethodCallHandler(handler);
  }

  void registerMethodCallHandlers(final List<MethodHandler> handlers) {
    incomingMethodCallHandler.registerMethodCallHandlers(handlers);
  }

  void clearMethodCallHandler() {
    incomingMethodCallHandler.clear();
  }
}

class IncomingMethodCallHandler {
  final Map<String, MethodHandler> handlers = {};
  late final TarsMethodCodec codec;

  IncomingMethodCallHandler(this.codec);

  final logger = Logger();

  void clear() {
    this.handlers.clear();
    logger.d("clear MethodHandlers");
  }

  void registerMethodCallHandler(final MethodHandler handler) {
    handlers[handler.method] = handler;
    logger.d(
        "registerMethodCallHandler,${handler.method},count:${handlers.length}");
  }

  void registerMethodCallHandlers(final List<MethodHandler> _handlers) {
    _handlers.forEach((element) {
      handlers[element.method] = element;
      logger.d(
          "registerMethodCallHandlers,${element.method},count:${handlers.length}");
    });
  }

  Future<ByteData?>? handleAsMethodCall(ByteData? message) async {
    logger.d("call handleAsMethodCall,length:${message?.lengthInBytes}");

    final String method = codec.decodeMethod(message);
    if (!handlers.containsKey(method)) {
      logger.w(
          "handlers not contain method: $method, handlers count:${handlers.length}");
      return null;
    }
    MethodHandler handler = handlers[method]!;
    InvokeArgument arguments =
        codec.decodeMethodArguments(message, handler.argumentsMapping);
    try {
      final TarsMethodCall call = new TarsMethodCall(method, arguments);
      var result = await handler.methodCallHandler(call);
      if (result == null) {
        return codec.encodeSuccessEnvelope(InvokeArgument0());
      } else {
        return codec.encodeSuccessEnvelope(result);
      }
    } on TarsPlatformException catch (e) {
      logger.e("handleAsMethodCall error: ${e.toString()}");
      return codec.encodeErrorEnvelope(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    } on TarsMissingPluginException catch (e) {
      logger.e("handleAsMethodCall error: ${e.toString()}");
      return null;
    } catch (e) {
      logger.e("handleAsMethodCall error: ${e.toString()}");
      return codec.encodeErrorEnvelope(
          code: 'error', message: e.toString(), details: null);
    }
  }
}

class MethodHandler {
  late String method;
  late RegisterParameter argumentsMapping;
  late Future<dynamic> Function(TarsMethodCall call) methodCallHandler;

  MethodHandler(String method, RegisterParameter argumentsMapping,
      Future<dynamic> Function(TarsMethodCall call) methodCallHandler) {
    this.method = method;
    this.argumentsMapping = argumentsMapping;
    this.methodCallHandler = methodCallHandler;
  }
}
