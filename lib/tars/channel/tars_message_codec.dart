// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'arguments/invoke/invoke_argument.dart';
import 'arguments/register/register_parameter.dart';

export 'dart:typed_data' show ByteData;

/// A message encoding/decoding mechanism.
///
/// Both operations throw an exception, if conversion fails. Such situations
/// should be treated as programming errors.
///
/// See also:
///
///  * [BasicMessageChannel], which use [TarsMessageCodec]s for communication
///    between Flutter and platform plugins.
abstract class TarsMessageCodec<T> {
  /// Encodes the specified [message] in binary.
  ///
  /// Returns null if the message is null.
  ByteData? encodeMessage(T message);

  /// Decodes the specified [message] from binary.
  ///
  /// Returns null if the message is null.
  T? decodeMessage(ByteData? message);
}

/// An command object representing the invocation of a named method.
@immutable
class TarsMethodCall {
  /// Creates a [TarsMethodCall] representing the invocation of [method] with the
  /// specified [arguments].
  const TarsMethodCall(this.method, this.arguments) : assert(method != null);

  /// The name of the method to be called.
  final String method;

  /// The arguments for the method.
  ///
  /// Must be a valid value for the [TarsMethodCodec] used.
  ///
  /// This property is `dynamic`, which means type-checking is skipped when accessing
  /// this property. To minimize the risk of type errors at runtime, the value should
  /// be cast to `Object?` when accessed.
  final InvokeArgument arguments;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'MethodCall')}($method, $arguments)';
}

/// A codec for method calls and enveloped results.
///
/// All operations throw an exception, if conversion fails.
///
/// See also:
///
///  * [TarsMethodChannel], which use [TarsMethodCodec]s for communication
///    between Flutter and platform plugins.
///  * [TarsEventChannel], which use [TarsMethodCodec]s for communication
///    between Flutter and platform plugins.
abstract class TarsMethodCodec {
  /// Encodes the specified [methodCall] into binary.
  ByteData encodeMethodCall(TarsMethodCall methodCall);

  /// Decodes the specified [methodCall] from binary.
  // TarsMethodCall decodeMethodCall(ByteData? methodCall);

  String decodeMethod(ByteData? methodCall);

  InvokeArgument decodeMethodArguments(
      ByteData? methodCall, RegisterParameter? resultParameter);

  /// Decodes the specified result [envelope] from binary.
  ///
  /// Throws [TarsPlatformException], if [envelope] represents an error, otherwise
  /// returns the enveloped result.
  ///
  /// The type returned from [decodeEnvelope] is `dynamic` (not `Object?`),
  /// which means *no type checking is performed on its return value*. It is
  /// strongly recommended that the return value be immediately cast to a known
  /// type to prevent runtime errors due to typos that the type checker could
  /// otherwise catch.
  InvokeArgument decodeEnvelope(
      ByteData envelope, RegisterParameter? resultParameter);

  /// Encodes a successful [result] into a binary envelope.
  ByteData encodeSuccessEnvelope(InvokeArgument result);

  /// Encodes an error result into a binary envelope.
  ///
  /// The specified error [code], human-readable error [message] and error
  /// [details] correspond to the fields of [TarsPlatformException].
  ByteData encodeErrorEnvelope(
      {required String code, String? message, Object? details});
}

/// Thrown to indicate that a platform interaction failed in the platform
/// plugin.
///
/// See also:
///
///  * [TarsMethodCodec], which throws a [TarsPlatformException], if a received result
///    envelope represents an error.
///  * [TarsMethodChannel.invokeMethod], which completes the returned future
///    with a [PlatformException], if invoking the platform plugin method
///    results in an error envelope.
///  * [TarsEventChannel.receiveBroadcastStream], which emits
///    [PlatformException]s as error events, whenever an event received from the
///    platform plugin is wrapped in an error envelope.
class TarsPlatformException implements Exception {
  /// Creates a [TarsPlatformException] with the specified error [code] and optional
  /// [message], and with the optional error [details] which must be a valid
  /// value for the [TarsMethodCodec] involved in the interaction.
  TarsPlatformException({
    required this.code,
    this.message,
    this.details,
    this.stacktrace,
  }) : assert(code != null);

  /// An error code.
  final String code;

  /// A human-readable error message, possibly null.
  final String? message;

  /// Error details, possibly null.
  ///
  /// This property is `dynamic`, which means type-checking is skipped when accessing
  /// this property. To minimize the risk of type errors at runtime, the value should
  /// be cast to `Object?` when accessed.
  final dynamic details;

  /// Native stacktrace for the error, possibly null.
  ///
  /// This contains the native platform stack trace, not the Dart stack trace.
  ///
  /// The stack trace for Dart exceptions can be obtained using try-catch blocks, for example:
  ///
  /// ```dart
  /// try {
  ///   ...
  /// } catch (e, stacktrace) {
  ///   print(stacktrace);
  /// }
  /// ```
  final String? stacktrace;

  @override
  String toString() =>
      'PlatformException($code, $message, $details, $stacktrace)';
}

/// Thrown to indicate that a platform interaction failed to find a handling
/// plugin.
///
/// See also:
///
///  * [TarsMethodChannel.invokeMethod], which completes the returned future
///    with a [MissingPluginException], if no plugin handler for the method call
///    was found.
///  * [OptionalMethodChannel.invokeMethod], which completes the returned future
///    with null, if no plugin handler for the method call was found.
class TarsMissingPluginException implements Exception {
  /// Creates a [TarsMissingPluginException] with an optional human-readable
  /// error message.
  TarsMissingPluginException([this.message]);

  /// A human-readable error message, possibly null.
  final String? message;

  @override
  String toString() => 'MissingPluginException($message)';
}
