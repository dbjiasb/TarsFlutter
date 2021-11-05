import 'dart:core';
import 'dart:typed_data';
import '/tars/codec/tars_input_stream.dart';
import '/tars/codec/tars_output_stream.dart';
import '/tars/codec/tars_struct.dart';
import 'const.dart';
import 'object_create_exception.dart';

class UniAttribute extends TarsStruct {
  /// 精简版tup，PACKET_TYPE_TUP3类型
  late Map<String, Uint8List> newData;

  /// 存储get后的数据 避免多次解析
  Map<String, Object> cachedData = new Map<String, Object>();

  int _iVer = Const.PACKET_TYPE_TUP;

  set version(int value) {
    _iVer = value;
  }

  int get version {
    return _iVer;
  }

  String _encodeName = "UTF-8";

  set encodeName(String value) {
    _encodeName = value;
  }

  String get encodeName {
    return _encodeName;
  }

  TarsInputStream _is = new TarsInputStream(null);

  UniAttribute() {
    newData = new Map<String, Uint8List>();
  }

  /// 清除缓存的解析过的数据
  void clearCacheData() {
    cachedData.clear();
  }

  bool isEmpty() {
    if (_iVer == Const.PACKET_TYPE_TUP3) {
      return newData.length == 0;
    } else {
      throw UnimplementedError();
    }
  }

  int get length {
    if (_iVer == Const.PACKET_TYPE_TUP3) {
      return newData.length;
    } else {
      throw UnimplementedError();
      // return _data.length;
    }
  }

  bool containsKey(String key) {
    if (_iVer == Const.PACKET_TYPE_TUP3) {
      return newData.containsKey(key);
    } else {
      throw UnimplementedError();
      // return _data.containsKey(key);
    }
  }

  /// 放入一个元素
  /// @param <T>
  /// @param name
  /// @param t
  void put<T>(String name, T t) {
    if (name == null) {
      throw new ArgumentError("put key can not is null");
    }
    if (t == null) {
      throw new ArgumentError("put value can not is null");
    }

    TarsOutputStream _out = new TarsOutputStream();
    _out.setServerEncoding(_encodeName);
    _out.write(t, 0);
    Uint8List sBuffer = _out.toUint8List();

    if (_iVer == Const.PACKET_TYPE_TUP3) {
      cachedData.remove(name);

      if (newData.containsKey(name)) {
        newData[name] = sBuffer;
      } else {
        newData[name] = sBuffer;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Object decodeData(Uint8List data, Object proxy) {
    _is.wrap(data);
    _is.setServerEncoding(_encodeName);
    Object o = _is.read(proxy, 0, true);
    return o;
  }

  /// 获取tup精简版本编码的数据,兼容旧版本tup
  /// @param <T>
  /// @param name
  /// @param proxy
  /// @return
  /// @throws ObjectCreateException
  T getByClass<T>(String name, T proxy) {
    Object? obj;
    if (_iVer == Const.PACKET_TYPE_TUP3) {
      if (!newData.containsKey(name)) {
        return obj as T;
      } else if (cachedData.containsKey(name)) {
        obj = cachedData[name];
        return obj as T;
      } else {
        try {
          Uint8List data = newData[name] as Uint8List;
          Object o = decodeData(data, proxy!);
          saveDataCache(name, o);
          return o as T;
        } catch (ex) {
          throw new ObjectCreateException(ex.toString());
        }
      }
    } else {
      //兼容tup2
      throw UnimplementedError();
    }
  }

  /// 获取一个元素,tup新旧版本都兼容
  /// @param Name
  /// @param DefaultObj
  /// @return
  /// @throws ObjectCreateException
  T get<T>(String Name, T DefaultObj) {
    try {
      Object? result = null;
      if (_iVer == Const.PACKET_TYPE_TUP3) {
        result = getByClass<T>(Name, DefaultObj);
      } else {
        //tup2
        throw UnimplementedError();
      }
      if (result == null) {
        return DefaultObj;
      }
      return result as T;
    } catch (ex) {
      return DefaultObj;
    }
  }

  void saveDataCache(String name, Object o) {
    cachedData[name] = o;
  }

  Uint8List encode() {
    TarsOutputStream _os = new TarsOutputStream();
    _os.setServerEncoding(_encodeName);
    if (_iVer == Const.PACKET_TYPE_TUP3) {
      _os.write(newData, 0);
    } else {
      throw UnimplementedError();
    }
    return _os.toUint8List();
  }

  void decode(Uint8List buffer, {int index: 0}) {
    //try tup3
    try {
      _iVer = Const.PACKET_TYPE_TUP3;
      _is.wrap(buffer, pos: index);
      _is.setServerEncoding(_encodeName);

      newData = _is.readMap<String, Uint8List>({
        "": Uint8List.fromList([0x0])
      }, 0, false);
    } catch (ex) {
      throw ObjectCreateException(ex.toString());
    }
  }

  @override
  void writeTo(TarsOutputStream _os) {
    if (_iVer == Const.PACKET_TYPE_TUP3) {
      _os.write(newData, 0);
    } else {
      throw UnimplementedError();
    }
  }

  @override
  void readFrom(TarsInputStream _is) {
    if (_iVer == Const.PACKET_TYPE_TUP3) {
      newData = {
        "": Uint8List.fromList([0x0])
      };
      _is.readMap<String, Uint8List>(newData, 0, false);
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Object deepCopy() {
    throw UnimplementedError();
  }

  @override
  void displayAsString(StringBuffer sb, int level) {
    throw UnimplementedError();
  }
}
