
import 'dart:core';
import 'dart:typed_data';
import '/tars/codec/tars_input_stream.dart';
import '/tars/codec/tars_output_stream.dart';
import '/tars/codec/tars_struct.dart';
import '/tars/codec/tars_displayer.dart';
import '/tars/codec/tars_deep_copyable.dart';

class RequestPacket extends TarsStruct {
  String className() {
    return "RequestPacket";
  }

  int iVersion = 0;

  int cPacketType = 0;

  int iMessageType = 0;

  int iRequestId = 0;

  String sServantName = "";

  String sFuncName = "";

  Uint8List? sBuffer;

  int iTimeout = 0;

  Map<String, String>? context;

  Map<String, String>? status;

  RequestPacket(
      {int iVersion: 0,
      int cPacketType: 0,
      int iMessageType: 0,
      int iRequestId: 0,
      String sServantName: "",
      String sFuncName: "",
      Uint8List? sBuffer,
      int iTimeout: 0,
      Map<String, String>? context,
      Map<String, String>? status}) {
    this.iVersion = iVersion;
    this.cPacketType = cPacketType;
    this.iMessageType = iMessageType;
    this.iRequestId = iRequestId;
    this.sServantName = sServantName;
    this.sFuncName = sFuncName;
    this.sBuffer = sBuffer;
    this.iTimeout = iTimeout;
    this.context = context;
    this.status = status;
  }

  @override
  void writeTo(TarsOutputStream _os) {
    _os.write(iVersion, 1);
    _os.write(cPacketType, 2);
    _os.write(iMessageType, 3);
    _os.write(iRequestId, 4);
    _os.write(sServantName, 5);
    _os.write(sFuncName, 6);
    _os.write(sBuffer, 7);
    _os.write(iTimeout, 8);
    _os.write(context, 9);
    _os.write(status, 10);
  }

  static Uint8List cache_sBuffer = Uint8List.fromList([0x0]);
  static Map<String, String> cache_context = {"": ""};
  static Map<String, String> cache_status = {"": ""};

  @override
  void readFrom(TarsInputStream _is) {
    this.iVersion = _is.read<int>(iVersion, 1, false);
    this.cPacketType = _is.read<int>(cPacketType, 2, false);
    this.iMessageType = _is.read<int>(iMessageType, 3, false);
    this.iRequestId = _is.read<int>(iRequestId, 4, false);
    this.sServantName = _is.read<String>(sServantName, 5, false);
    this.sFuncName = _is.read<String>(sFuncName, 6, false);
    this.sBuffer = _is.read<int>(cache_sBuffer, 7, false);
    this.iTimeout = _is.read<int>(iTimeout, 8, false);
    this.context = _is.readMap<String, String>(cache_context, 9, false);
    this.status = _is.readMap<String, String>(cache_status, 10, false);
  }

  @override
  void displayAsString(StringBuffer _os, int _level) {
    TarsDisplayer _ds = TarsDisplayer(_os, level: _level);
    _ds.display(iVersion, "iVersion");
    _ds.display(cPacketType, "cPacketType");
    _ds.display(iMessageType, "iMessageType");
    _ds.display(iRequestId, "iRequestId");
    _ds.display(sServantName, "sServantName");
    _ds.display(sFuncName, "sFuncName");
    _ds.display(sBuffer, "sBuffer");
    _ds.display(iTimeout, "iTimeout");
    _ds.display(context, "context");
    _ds.display(status, "status");
  }

  @override
  Object deepCopy() {
    var o = RequestPacket();
    o.iVersion = this.iVersion;
    o.cPacketType = this.cPacketType;
    o.iMessageType = this.iMessageType;
    o.iRequestId = this.iRequestId;
    o.sServantName = this.sServantName;
    o.sFuncName = this.sFuncName;
    o.sBuffer = this.sBuffer;
    o.iTimeout = this.iTimeout;
    if (null != context) {
      o.context = mapDeepCopy<String, String>(this.context!);
    }
    if (null != status) {
      o.status = mapDeepCopy<String, String>(this.status!);
    }
    return o;
  }
}
