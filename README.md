# 关于项目

Tars RPC通信框架的Flutter支持库(Flutter Support Library For Tars RPC framework)

> [什么是Tars](https://github.com/TarsCloud/TarsCpp)


## 本项目使用场景

### 1. 在Flutter模块中，直接收发基于Tars框架（TUP封包协议）的网络请求。

> 这种模式只需要依赖本项目即可，无需安卓或者iOS原生层依赖额外的库

> [了解什么是TUP，以及与Tars协议的关系](https://github.com/TarsCloud/TarsTup)

### 2. 在Flutter模块集成到已有Android或iOS应用模式下，实现在Flutter模块和Android原生层之间传递Tars对象

> 2.1. Android端支持库(https://github.com/brooklet/TarsFlutterAndroid)

---

## tars协议定义转成dart代码

1. 根据业务需要，定义自己的tars协议文件: bz.tars，如：

```
module test
{   
	struct TestReq
    {
        0 optional int    id;
        1 optional string name;
    };

    struct TestData
    {
        0 optional int               id;
        1 optional string            code;
        2 optional vector<string>    stringList;
        3 optional map<int, TestReq> mapData;
    };

    struct TestRsp
    {
        0 optional vector<TestData>           data;
        1 optional vector<byte>               bytesData;
        2 optional map<int, TestData>         mapData;
        3 optional vector<string>             stringList;
        4 optional map<int, vector<TestData>> nestData;
        5 optional long                       id;
        6 optional string                     name;
    };
	
};
```

2. 从[https://github.com/brooklet/TarsCpp/](https://github.com/brooklet/TarsCpp/) 拉取代码，并编译 /tools/tars2dart模块， 编译生成 tars2dart 命令行工具

3. 用tars2dart命令行工具生成 bz.tars 对应的dart代码

    `tars2dart --dir=./dart/ --base-package=tars_idl --extends-package=package:tars_flutter/tars/codec/ ./bz.tars`

    > `--dir`指定dart代码的保存目录

    > `--base-package`指定生成dart代码的保存子路径

    > `--extends-package`指定生成dart代码中tars支持库的import路径,无需修改

    > `./bz.tars`指定tars协议定义文件路径

---

## 1. 通过dio库，基于Tars框架的TUP封包协议直接收发网络请求，封包解包

### 快速接入

    ```
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

    ```


   > 需要注意的是，目前本项目只支持TUP的PACKET_TYPE_TUP3封包类型

### 定制接入

   > 可以参考 [base_tars_http.dart](lib\tars\net\base_tars_http.dart) 自行封装网络请求的收发,涉及TUP数据封包及解包的主要是以下三个方法：

    
    ```
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

    ```

---

## 2. 在Flutter模块集成到已有Android或iOS应用模式下，实现在Flutter模块和Android原生层之间传递Tars对象

### 2.1 [Android端支持库](https://github.com/brooklet/TarsFlutterAndroid)

### 2.2 TODO

