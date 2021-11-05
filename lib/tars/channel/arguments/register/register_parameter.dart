import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../tars_message_codec.dart';
import '/tars/codec/tars_input_stream.dart';
import '/tars/codec/tars_struct.dart';
import '/tars/channel/tars_message_codecs.dart';
import '/tars/channel/arguments/invoke/invoke_argument.dart';

abstract class RegisterParameter {
  List<Object> getMappingParameter();

  InvokeArgument dispatchResult(List<Object> result);

  var messageCodec = const TarsStandardMessageCodec();

  InvokeArgument decode(ReadBuffer buffer) {
    List<Object> mappingParameter = getMappingParameter();
    List<Object> result = [];

    var type = buffer.getUint8();
    var size = messageCodec.readSize(buffer);
    debugPrint("RegisterParameter decode: type:${type}, size:${size}");
    mappingParameter.forEach((element) {
      var obj = decodeElement(element, buffer);
      result.add(obj);
    });

    return dispatchResult(result);
  }

  Object decodeElement(Object it, ReadBuffer buffer) {
    var type = buffer.getUint8();
    if (it is List) {
      var size = messageCodec.readSize(buffer);
      var obj = [];
      for (var i = 0; i < size; ++i) {
        obj.add(decodeElement(it[0], buffer));
      }
      return obj;
    } else if (it is Map) {
      var size = messageCodec.readSize(buffer);
      var obj = {};
      for (var i = 0; i < size; ++i) {
        var key = decodeElement(it.keys.first, buffer);
        var value = decodeElement(it.values.first, buffer);
        obj[key] = value;
      }
      return obj;
    } else if (it is TarsStruct) {
      var obj = it.deepCopy() as TarsStruct;
      var bytes = messageCodec.readValueOfType(
          TarsStandardMessageCodec.valueUint8List, buffer) as Uint8List;
      var inputStream = TarsInputStream(bytes);
      obj.readFrom(inputStream);
      return obj;
    } else {
      var obj = messageCodec.readValueOfType(type, buffer);
      if (obj == null) {
        throw Exception("decodeElement get null, type: $type");
      }
      return obj;
    }
  }
}
