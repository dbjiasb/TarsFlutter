import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:logger/logger.dart';
import 'package:tars_flutter/tars/codec/tars_input_stream.dart';
import 'package:tars_flutter/tars/tup/const.dart';
import 'package:tars_flutter/tars/tup/tars_uni_packet.dart';
import 'package:tars_flutter/tars/tup/tup_response.dart';
import 'package:tars_flutter/tars/tup/tup_result_exception.dart';

import 'package:encrypt/encrypt.dart' as Encrypt;

const String kAESEncodeKey = 'qRRQX6viVNqHYYKL58ZVAw==';

//tup网络请求封装
//注意:只支持 PACKET_TYPE_TUP3 = 3 类型的封包
class BaseTarsHttp {
  late String baseUrl;
  late var path = "/tup";
  late String servantName;
  var timeOut = 60000;
  var debugLog = false;
  late final dio;
  final logger = Logger();

  BaseTarsHttp(this.baseUrl, this.path, this.servantName,
      {this.timeOut = 60000, this.debugLog = false}) {
    dio = Dio(BaseOptions(
        connectTimeout: Duration(milliseconds: timeOut),
        baseUrl: baseUrl, 
        responseType: ResponseType.bytes,
        headers: {HttpHeaders.contentTypeHeader: "application/x-wup"}));
    if (debugLog) {
      dio.interceptors.add(LogInterceptor(responseBody: false)); //开启请求日志
    }
  }

  //发送http请求,不返回状态码,异常状态码直接抛出异常TupResultException
  Future<RSP> tupRequest<REQ, RSP>(
      String methodName, REQ tReq, RSP tRsp) async {
    TupResponse<RSP> response =
        await tupRequestWithRspCode(methodName, tReq, tRsp);
    if (response.code == 0) {
      return response.response!;
    } else {
      logger.e("tupDecode decode error:${response.code}");
      throw TupResultException(response.code);
    }
  }

  //发送http请求,返回状态码及response
  Future<TupResponse<RSP>> tupRequestWithRspCode<REQ, RSP>(
      String methodName, REQ tReq, RSP tRsp, {bool needEncode = false }) async {
    Uint8List _data = buildRequest(methodName, tReq);
    Uint8List encodeData = needEncode ? _encode(_data) : _data;
    dio.options.headers[HttpHeaders.contentLengthHeader] = encodeData.length;
    logger.d("send tupRequest, path:$path, methodName:$methodName, needEncode:$needEncode");
    final _result = await dio.post<List<int>>(
      path,
      // data: encodeData,
      data: Stream.fromIterable(encodeData.map((e) => [e])),
    );
    var value = _result.data;
    if (needEncode) {
      String ret = String.fromCharCodes(value!);
      value = _decode(ret);
    }
    return tupResponseDecode(methodName, value!, tRsp);
  }

  //发送无response http请求,返回状态码
  Future<TupResponse<void>> tupRequestWithRspCodeNoRsp<REQ>(
      String methodName, REQ tReq) async {
    final _data = buildRequest(methodName, tReq);
    dio.options.headers[HttpHeaders.contentLengthHeader] = _data.lengthInBytes;
    logger.d("send tupRequestNoRsp, methodName:$methodName");
    final _result = await dio.post<List<int>>(
      path,
      data: Stream.fromIterable(_data.map((e) => [e])),
    );
    final value = _result.data;
    return tupEmptyResponseDecode(methodName, value!);
  }

  //发送无response http请求,不返回状态码,异常状态码直接抛出异常TupResultException
  Future<void> tupRequestNoRsp<REQ>(String methodName, REQ tReq) async {
    TupResponse<void> response =
        await tupRequestWithRspCodeNoRsp(methodName, tReq);
    if (response.code == 0) {
      return;
    } else {
      logger.e("tupDecode decode error:${response.code}");
      throw TupResultException(response.code);
    }
  }

  //封包
  Uint8List buildRequest<REQ>(String methodName, REQ tReq) {
    TarsUniPacket encodePack = TarsUniPacket();
    encodePack.requestId = 0;
    encodePack.setTarsVersion(Const.PACKET_TYPE_TUP3);
    encodePack.setTarsPacketType(Const.PACKET_TYPE_TARSNORMAL);
    encodePack.servantName = servantName;
    encodePack.funcName = methodName;
    encodePack.put("tReq", tReq);
    Uint8List bytes = encodePack.encode();
    return bytes;
  }

  //有response解包
  TupResponse<RSP> tupResponseDecode<RSP>(
      String methodName, List<int> list, RSP tRsp) {
    var bytes = Uint8List.fromList(list);
    BinaryReader br = BinaryReader(bytes);
    int size = br.readInt(4);
    TarsUniPacket respPack = TarsUniPacket();
    respPack.decode(bytes);
    var code = respPack.get("", 0);
    logger.d("get tupRequest response, methodName:$methodName, code:$code");
    RSP rsp = respPack.get<RSP>("tRsp", tRsp);
    return TupResponse<RSP>(code: code, response: rsp);
  }

  REQ tupReqDecode<REQ>(
      String methodName, List<int> list, REQ tRsp) {
    var bytes = Uint8List.fromList(list);
    BinaryReader br = BinaryReader(bytes);
    int size = br.readInt(4);
    TarsUniPacket respPack = TarsUniPacket();
    respPack.decode(bytes);
    var code = respPack.get("", 0);
    logger.d("get tupRequest response, methodName:$methodName, code:$code");
    REQ req = respPack.get<REQ>("tReq", tRsp);
    return req;
  }
  
  //无response解包
  TupResponse<void> tupEmptyResponseDecode(String methodName, List<int> list) {
    var bytes = Uint8List.fromList(list);
    BinaryReader br = BinaryReader(bytes);
    int size = br.readInt(4);
    TarsUniPacket respPack = TarsUniPacket();
    respPack.decode(bytes);
    var code = respPack.get("", 0);
    logger.d("get tupRequest response, methodName:$methodName, code:$code");
    return TupResponse<void>(code: code);
  }

  String _encodetoString(Uint8List origin) {

    origin = Uint8List.fromList(utf8.encode("123456789"));//Utf8Encoder().convert("1234567890");

    final key = Encrypt.Key.fromBase64(kAESEncodeKey);
    // final IV = Encrypt.IV.fromUtf8("0000000000000000");

    //AES Encode
    //设置ecb模式
    final encrypter = Encrypt.Encrypter(
        Encrypt.AES(key, mode: Encrypt.AESMode.ecb, padding: 'PKCS7'));
    //Encode return base64
    String aesEncodedStr = encrypter.encryptBytes(origin, iv: null).base64;
    return aesEncodedStr;
  }

  Uint8List _encode(Uint8List origin) {

    // origin = Uint8List.fromList(utf8.encode("1234567890"));//Utf8Encoder().convert("1234567890");
    
    final key = Encrypt.Key.fromBase64(kAESEncodeKey);
    // final IV = Encrypt.IV.fromUtf8("0000000000000000");

    //AES Encode
    //设置ecb模式
    final encrypter = Encrypt.Encrypter(
        Encrypt.AES(key, mode: Encrypt.AESMode.ecb, padding: 'PKCS7'));
    //Encode return base64
    String aesEncodedStr = encrypter.encryptBytes(origin, iv: null).base64;

    Uint8List rett = Uint8List.fromList(utf8.encode(aesEncodedStr));

    return rett;//Utf8Encoder().convert(aesEncodedStr);
  }

  /// decode flow: origin -> AES.ECB -> Base64 -> Url Ecode
  Uint8List _decode(String origin) {

    // origin = "C9u98BlFbmeFsxRgnt75FQ==";

    //Decode base64
    Encrypted aesEncodeData = Encrypt.Encrypted.fromBase64(origin);

    //AES Decode
    final key = Encrypt.Key.fromBase64(kAESEncodeKey);
    final encrypter = Encrypt.Encrypter(
        Encrypt.AES(key, mode: Encrypt.AESMode.ecb, padding: 'PKCS7'));

    List<int> result = encrypter.decryptBytes(aesEncodeData, iv: null);
    var ttt = String.fromCharCodes(result);
    print("decode result: $ttt");
    return Uint8List.fromList(result);
  }
}
