
import 'dart:core';
import 'dart:typed_data';
import 'package:tars_flutter/tars/codec/tars_deep_copyable.dart';
import 'package:tars_flutter/tars/codec/tars_displayer.dart';
import 'package:tars_flutter/tars/codec/tars_input_stream.dart';
import 'package:tars_flutter/tars/codec/tars_output_stream.dart';
import 'package:tars_flutter/tars/codec/tars_struct.dart';

import 'TestData.dart';

class TestRsp extends TarsStruct {
  String className() {
    return "TestRsp";
  }

  List<TestData>? data;

  Uint8List? bytesData;

  Map<int, TestData>? mapData;

  List<String>? stringList;

  Map<int, List<TestData>>? nestData;

  int id = 0;

  String? name = "";

  TestRsp(
      {List<TestData>? data,
      Uint8List? bytesData,
      Map<int, TestData>? mapData,
      List<String>? stringList,
      Map<int, List<TestData>>? nestData,
      int id: 0,
      String? name: ""}) {
    this.data = data;
    this.bytesData = bytesData;
    this.mapData = mapData;
    this.stringList = stringList;
    this.nestData = nestData;
    this.id = id;
    this.name = name;
  }

  @override
  void writeTo(TarsOutputStream _os) {
    if (null != data) {
      _os.write(data, 0);
    }
    if (null != bytesData) {
      _os.write(bytesData, 1);
    }
    if (null != mapData) {
      _os.write(mapData, 2);
    }
    if (null != stringList) {
      _os.write(stringList, 3);
    }
    if (null != nestData) {
      _os.write(nestData, 4);
    }
    _os.write(id, 5);
    if (null != name) {
      _os.write(name, 6);
    }
  }

  static List<TestData> cache_data = [TestData()];
  static Uint8List cache_bytesData = Uint8List.fromList([0x0]);
  static Map<int, TestData> cache_mapData = {0: TestData()};
  static List<String> cache_stringList = [""];
  static Map<int, List<TestData>> cache_nestData = {
    0: [TestData()]
  };

  @override
  void readFrom(TarsInputStream _is) {
    this.data = _is.read<TestData>(cache_data, 0, false);
    this.bytesData = _is.read<int>(cache_bytesData, 1, false);
    this.mapData = _is.readMap<int, TestData>(cache_mapData, 2, false);
    this.stringList = _is.read<String>(cache_stringList, 3, false);
    this.nestData = _is.readMapList<int, TestData>(cache_nestData, 4, false);
    this.id = _is.read<int>(id, 5, false);
    this.name = _is.read<String>(name, 6, false);
  }

  @override
  void displayAsString(StringBuffer _os, int _level) {
    TarsDisplayer _ds = TarsDisplayer(_os, level: _level);
    _ds.display(data, "data");
    _ds.display(bytesData, "bytesData");
    _ds.display(mapData, "mapData");
    _ds.display(stringList, "stringList");
    _ds.display(nestData, "nestData");
    _ds.display(id, "id");
    _ds.display(name, "name");
  }

  @override
  Object deepCopy() {
    var o = TestRsp();
    if (null != data) {
      o.data = listDeepCopy<TestData>(this.data!);
    }
    o.bytesData = this.bytesData;
    if (null != mapData) {
      o.mapData = mapDeepCopy<int, TestData>(this.mapData!);
    }
    if (null != stringList) {
      o.stringList = listDeepCopy<String>(this.stringList!);
    }
    if (null != nestData) {
      o.nestData = mapListDeepCopy<int, TestData>(this.nestData!);
    }
    o.id = this.id;
    o.name = this.name;
    return o;
  }
}
