import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:tars_flutter/tars/codec/tars_input_stream.dart';
import 'package:tars_flutter/tars/codec/tars_output_stream.dart';

import 'const.dart';
import 'request_packet.dart';
import 'uni_attribute.dart';

class UniPacket extends UniAttribute {
  static const int UniPacketHeadSize = 4;

  RequestPacket package = RequestPacket();

  /// 获取请求的service名字
  ///
  /// @return
  String get servantName {
    return package.sServantName;
  }

  set servantName(String value) {
    package.sServantName = value;
  }

  /// 获取请求的函数名字
  ///
  /// @return
  String get funcName {
    return package.sFuncName;
  }

  set funcName(String value) {
    package.sFuncName = value;
  }

  /// 获取消息序列号
  ///
  /// @return
  int get requestId {
    return package.iRequestId;
  }

  set requestId(int value) {
    package.iRequestId = value;
  }

  UniPacket() {
    package.iVersion = Const.PACKET_TYPE_TUP3;
  }

  void setVersion(int iVer) {
    this.version = iVer;
    package.iVersion = iVer;
  }

  int getVersion() {
    return package.iVersion;
  }

  /// 将put的对象进行编码
  Uint8List encode() {
    if (package.sServantName.compareTo("") == 0) {
      throw new ArgumentError("servantName can not is null");
    }
    if (package.sFuncName.compareTo("") == 0) {
      throw new ArgumentError("funcName can not is null");
    }

    TarsOutputStream _os = new TarsOutputStream();
    _os.setServerEncoding(encodeName);
    if (package.iVersion == Const.PACKET_TYPE_TUP) {
      throw UnimplementedError();
    } else {
      _os.write(newData, 0);
    }

    package.sBuffer = _os.toUint8List();

    _os = new TarsOutputStream();
    _os.setServerEncoding(encodeName);
    this.writeTo(_os);
    Uint8List body = _os.toUint8List();
    int size = body.lengthInBytes;

    final WriteBuffer buffer = WriteBuffer();
    buffer.putInt32(size + UniPacketHeadSize, endian: Endian.big);
    buffer.putUint8List(body);
    return buffer.done().buffer.asUint8List();
  }

  /// 对传入的数据进行解码 填充可get的对象
  void decode(Uint8List buffer, {int index: 0}) {
    if (buffer.lengthInBytes < UniPacketHeadSize) {
      throw new ArgumentError("Decode namespace must include size head");
    }
    try {
      TarsInputStream _is =
          new TarsInputStream(buffer, pos: UniPacketHeadSize + index);
      _is.setServerEncoding(encodeName);
      //解码出RequestPacket包
      this.readFrom(_is);

      //设置tup版本
      version = package.iVersion;

      _is = new TarsInputStream(package.sBuffer);
      _is.setServerEncoding(encodeName);

      if (package.iVersion == Const.PACKET_TYPE_TUP) {
        throw UnimplementedError();
      } else {
        newData = _is.readMap<String, Uint8List>({
          "": Uint8List.fromList([0x0])
        }, 0, false);
      }
    } catch (e) {
      print('decode exception: $e');
      throw (e);
    }
  }

  @override
  void writeTo(TarsOutputStream _os) {
    package.writeTo(_os);
  }

  @override
  void readFrom(TarsInputStream _is) {
    package.readFrom(_is);
  }
}
