
import 'dart:typed_data';

import 'package:tars_flutter/tars/codec/tars_input_stream.dart';
import 'package:tars_flutter/tars/codec/tars_output_stream.dart';

import './tars_idl/test/TestReq.dart';
import './tars_idl/test/TestRsp.dart';
import './tars_idl/test/TestData.dart';

import 'common.dart';

String testOutput() {
  var testRsp = TestRsp();
  testRsp.id = 1;
  testRsp.name = '测试';

  Map<int, TestReq>? mapData = Map.fromEntries(
      List<MapEntry<int, TestReq>>.filled(1,
          MapEntry<int, TestReq>(123, TestReq(id: 233, name: 'TestReq测试1'))));

  var testData1 = TestData(
      id: 100, code: '测试1', stringList: ['张三', '李四'], mapData: mapData);
  var testData2 = TestData(
      id: 200, code: '测试2', stringList: ['张三2', '李四2'], mapData: mapData);

  testRsp.stringList = ['张三3', '李四3'];
  testRsp.data = [testData1, testData2];
  testRsp.bytesData = Uint8List.fromList(List.filled(5, 0x23));

  testRsp.nestData = {
    8888: [
      TestData(
          id: 300,
          code: '测试3',
          stringList: ['张三3', '李四'],
          mapData: {1: TestReq(id: 444, name: 'TestReq测试2')}),
      TestData(
          id: 400,
          code: '测试4',
          stringList: ['张三4', '李四'],
          mapData: {22: TestReq(id: 555, name: 'TestReq测试3')})
    ]
  };
  testRsp.mapData = {333333: testData2};

  var output = TarsOutputStream();
  testRsp.writeTo(output);
  var bytes = output.toUint8List();
  String hex = toHex(bytes);
  print(hex);
  return hex;
}

void testInput(String hex) {
  Uint8List input = toUnitList(hex);
  var tarsInputStream = TarsInputStream(input);
  var testRsp = TestRsp();
  testRsp.readFrom(tarsInputStream);
  print((testRsp.data!.length).toString() +
      ',' +
      ((testRsp.data![0]!).code).toString());
}

void main() {
  var hex = testOutput();
  testInput(hex);
}
