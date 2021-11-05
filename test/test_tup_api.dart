import 'package:tars_flutter/tars/net/base_tars_http.dart';
import 'package:tars_flutter/tars/tup/tup_response.dart';

import 'tars_idl/test/TestReq.dart';
import 'tars_idl/test/TestRsp.dart';

/// 请求后端tup接口的demo
class TestTupApi {
  late String tarsUrl;
  BaseTarsHttp? baseTarsHttp;

  TestTupApi(this.tarsUrl);

  BaseTarsHttp getBaseTarsHttp() {
    if (baseTarsHttp == null) {
      baseTarsHttp = BaseTarsHttp(tarsUrl, "/tup", "testui");
      return baseTarsHttp!;
    } else {
      return baseTarsHttp!;
    }
  }

  /// 调用后端接口,不返回状态码,异常状态码直接抛出异常TupResultException
  /// [适用于后端业务不会返回特定状态码的情况,可以在外层统一封装针对不同状态码的通用处理逻辑]
  Future<TestRsp> testApi(TestReq req) async {
    return await getBaseTarsHttp().tupRequest("testApi", req, TestRsp());
  }
  
  /// 调用后端接口,返回状态码及response
  /// [适用于后端业务会返回特定状态码,前端需要特殊处理的情况]
  Future<TupResponse<TestRsp>> testApiWithRspCode(TestReq req) async {
    return await getBaseTarsHttp()
        .tupRequestWithRspCode("testApi", req, TestRsp());
  }
  
  /// 调用后端无response接口,不返回状态码,异常状态码直接抛出异常TupResultException
  /// [适用于后端业务不会返回特定状态码的情况,可以在外层统一封装针对不同状态码的通用处理逻辑]
  Future<void> testApiNoResponse(TestReq req) async {
    return await getBaseTarsHttp().tupRequestNoRsp("testApiNoResponse", req);
  }

  /// 调用后端无response接口,返回状态码及response
  /// [适用于后端业务会返回特定状态码,前端需要特殊处理的情况]
  Future<TupResponse<void>> testApiWithRspCodeNoResponse(TestReq req) async {
    return await getBaseTarsHttp().tupRequestWithRspCodeNoRsp("testApiNoResponse", req);
  }

}
