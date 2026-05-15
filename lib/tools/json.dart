import 'dart:convert';

enum DataType { num, string, bool, list, map, nullType }

class Json {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  dynamic _object;
  dynamic _type = DataType.nullType;

  List<dynamic> _rawList = [];
  Map<String, dynamic> _rawMap = {};
  num _rawNum = 0;
  String _rawString = '';
  bool _rawBool = false;
  // ignore: unused_field
  Null _rawNull;

  Json(dynamic object) {
    _init(object);
  }

  Json.parse(String string) {
    try {
      _init(jsonDecode(string));
    } catch (err) {
      _init(null);
    }
  }

  Json.parseBytes(List<int> data) {
    try {
      _init(jsonDecode(String.fromCharCodes(data)));
    } catch (err) {
      _init(null);
    }
  }

  void _init(dynamic object) {
    _object = object;
    if (object is Map) {
      try {
        _rawMap = Map<String, dynamic>.from(object);
        _object = _rawMap;
        _type = DataType.map;
      } catch (error) {
        _rawNull = null;
        _type = DataType.nullType;
      }
    } else if (object is List<dynamic>) {
      _rawList = List<dynamic>.from(object);
      _object = _rawList;
      _type = DataType.list;
    } else if (object is bool) {
      _rawBool = object;
      _type = DataType.bool;
    } else if (object is num) {
      _rawNum = object;
      _type = DataType.num;
    } else if (object is String) {
      _rawString = object;
      _type = DataType.string;
    } else {
      _rawNull = null;
      _type = DataType.nullType;
    }
  }

  Json operator [](dynamic value) {
    if (value is int) {
      return _valueAt(value);
    } else if (value is String) {
      return _valueForKey(value);
    } else {
      var r = Json(null);
      return r;
    }
  }

  void operator []=(dynamic key, dynamic value) {
    if (key is int) {
      if (_type == DataType.list) {
        _rawList[key] = value;
      } else {
        _rawList = [value];
        _object = _rawList;
        _type = DataType.list;
      }
    } else if (key is String) {
      if (_type == DataType.map) {
        _rawMap[key] = value;
      } else {
        _rawMap = {key: value};
        _object = _rawMap;
        _type = DataType.map;
      }
    }
  }

  void remove(dynamic key) {
    if (key is int) {
      _removeAt(key);
    } else if (key is String) {
      _removeForKey(key);
    }
  }

  void _removeForKey(String key) {
    if (_type == DataType.map) {
      _rawMap.remove(key);
    }
  }

  void _removeAt(int index) {
    if (_type == DataType.list && index < _rawList.length) {
      _rawList.removeAt(index);
    }
  }

  Json _valueAt(int index) {
    if (_type != DataType.list) {
      var r = Json(null);
      return r;
    } else if (index < _rawList.length) {
      return Json(_rawList[index]);
    } else {
      return Json(null);
    }
  }

  Json _valueForKey(String key) {
    if (_type != DataType.map) {
      var r = Json(null);
      return r;
    } else {
      var r = _rawMap[key];
      if (r is Json) {
        return r;
      }
      return Json(r);
    }
  }

  dynamic get object => _object;

  Map<String, Json>? get mapOrNull => _mapOrNull();

  Map<String, Json> get mapValue => mapOrNull ?? {};

  List<Json>? get listOrNull => _listOrNull();

  List<Json> get listValue => listOrNull ?? [];

  bool? get boolOrNull => _boolOrNull();

  bool get boolValue => _boolValue();

  num? get numOrNull => _numOfNull();

  num get numValue => _numValue();

  int? get intOrNull => numOrNull?.toInt();

  int get intValue => numValue.toInt();

  double? get doubleOrNull => numOrNull?.toDouble();

  double get doubleValue => numValue.toDouble();

  String? get stringOrNull => _type == DataType.string ? _rawString : null;

  String get stringValue => _stringValue();

  bool isNull() => _type == DataType.nullType;

  bool exists() => _object != null;

  Map<String, Json>? _mapOrNull() {
    if (_type == DataType.map) {
      var d = _rawMap.map((key, value) => MapEntry(key, Json(value)));
      return d;
    } else {
      return null;
    }
  }

  List<Json>? _listOrNull() {
    if (_type == DataType.list) {
      var d = _rawList.map((value) => Json(value)).toList();
      return d;
    } else {
      return null;
    }
  }

  String rawString({bool prettyPrint = false}) {
    if (prettyPrint) {
      String prettyJsonString = _encoder.convert(_object);
      return prettyJsonString;
    } else {
      return jsonEncode(_object);
    }
  }

  bool? _boolOrNull() {
    if (_type == DataType.bool) {
      return _rawBool;
    } else {
      return null;
    }
  }

  bool _boolValue() {
    switch (_type) {
      case DataType.bool:
        return _rawBool;
      case DataType.num:
        return _rawNum != 0;
      case DataType.string:
        return [
          "true",
          "y",
          "t",
          "yes",
          "1",
        ].contains(_rawString.toLowerCase());
      default:
        return false;
    }
  }

  num? _numOfNull() {
    switch (_type) {
      case DataType.bool:
        return _rawBool ? 1 : 0;
      case DataType.num:
        return _rawNum;
      default:
        return null;
    }
  }

  num _numValue() {
    switch (_type) {
      case DataType.string:
        return int.tryParse(_rawString) ?? double.tryParse(_rawString) ?? 0;
      case DataType.num:
        return _rawNum;
      case DataType.bool:
        return _rawBool ? 1 : 0;
      default:
        return 0;
    }
  }

  String _stringValue() {
    switch (_type) {
      case DataType.string:
        // return _replaceImageUrlString(_rawString);
        return _rawString;
      case DataType.num:
        return _rawNum.toString();
      case DataType.bool:
        return _rawBool.toString();
      default:
        return '';
    }
  }

  // String _replaceImageUrlString(String input) {
  //   final startIndex = input.indexOf('http');
  //   final endIndex = input.indexOf('aliyuncs.com');
  //   if (startIndex == -1 || endIndex == -1) {
  //     return input;
  //   }
  //   return input.replaceRange(
  //     startIndex,
  //     endIndex + 12,
  //     'http://192.168.31.150:8088/oss-ph-dc',
  //   );
  // }
}
