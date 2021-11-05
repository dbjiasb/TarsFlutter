
import 'dart:core';

import 'package:tars_flutter/tars/codec/tars_deep_copyable.dart';
import 'package:tars_flutter/tars/codec/tars_displayer.dart';
import 'package:tars_flutter/tars/codec/tars_input_stream.dart';
import 'package:tars_flutter/tars/codec/tars_output_stream.dart';
import 'package:tars_flutter/tars/codec/tars_struct.dart';

import 'TestReq.dart';

class TestData extends TarsStruct {
  String className() {
    return "TestData";
  }

  int id = 0;

  String? code = "";

  List<String>? stringList;

  Map<int, TestReq>? mapData;

  TestData(
      {int id: 0,
      String? code: "",
      List<String>? stringList,
      Map<int, TestReq>? mapData}) {
    this.id = id;
    this.code = code;
    this.stringList = stringList;
    this.mapData = mapData;
  }

  @override
  void writeTo(TarsOutputStream _os) {
    _os.write(id, 0);
    if (null != code) {
      _os.write(code, 1);
    }
    if (null != stringList) {
      _os.write(stringList, 2);
    }
    if (null != mapData) {
      _os.write(mapData, 3);
    }
  }

  static List<String> cache_stringList = [""];
  static Map<int, TestReq> cache_mapData = {0: TestReq()};

  @override
  void readFrom(TarsInputStream _is) {
    this.id = _is.read<int>(id, 0, false);
    this.code = _is.read<String>(code, 1, false);
    this.stringList = _is.read<String>(cache_stringList, 2, false);
    this.mapData = _is.readMap<int, TestReq>(cache_mapData, 3, false);
  }

  @override
  void displayAsString(StringBuffer _os, int _level) {
    TarsDisplayer _ds = TarsDisplayer(_os, level: _level);
    _ds.display(id, "id");
    _ds.display(code, "code");
    _ds.display(stringList, "stringList");
    _ds.display(mapData, "mapData");
  }

  @override
  Object deepCopy() {
    var o = TestData();
    o.id = this.id;
    o.code = this.code;
    if (null != stringList) {
      o.stringList = listDeepCopy<String>(this.stringList!);
    }
    if (null != mapData) {
      o.mapData = mapDeepCopy<int, TestReq>(this.mapData!);
    }
    return o;
  }
}
