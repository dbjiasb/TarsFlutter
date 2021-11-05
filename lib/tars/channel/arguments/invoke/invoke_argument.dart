import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:tars_flutter/tars/codec/tars_output_stream.dart';
import 'package:tars_flutter/tars/codec/tars_struct.dart';

import '../../tars_message_codecs.dart';

abstract class InvokeArgument {
  List<Object> getArguments();

  var messageCodec = const TarsStandardMessageCodec();

  void encode(WriteBuffer buffer) {
    List<Object?> arguments = getArguments();
    buffer.putUint8(TarsStandardMessageCodec.valueList);
    messageCodec.writeSize(buffer, arguments.length);
    if (arguments.isNotEmpty) {
      arguments.forEach((element) {
        write(element, buffer);
      });
    }
  }

  write(Object? it, WriteBuffer buffer) {
    if (it == null) {
      messageCodec.writeValue(buffer, it);
    }
    if (it is List) {
      buffer.putUint8(TarsStandardMessageCodec.valueList);
      messageCodec.writeSize(buffer, it.length);
      for (var i = 0; i < it.length; ++i) {
        write(it[i]!!, buffer);
      }
    } else if (it is Map) {
      buffer.putUint8(TarsStandardMessageCodec.valueMap);
      messageCodec.writeSize(buffer, it.length);
      var entries = it.entries;
      if (entries.isNotEmpty) {
        entries.forEach((element) {
          write(element.key!!, buffer);
          write(element.value!!, buffer);
        });
      }
    } else if (it is TarsStruct) {
      var outputStream = TarsOutputStream();
      it.writeTo(outputStream);
      var bytes = outputStream.toUint8List();
      messageCodec.writeValue(buffer, bytes);
    } else {
      messageCodec.writeValue(buffer, it);
    }
  }
}
