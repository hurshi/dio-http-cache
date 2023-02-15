import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

import '../dio_helper.dart';

class CacheManagerPanel extends StatefulWidget {
  const CacheManagerPanel({super.key});

  @override
  State createState() => _CacheManagerPanelState();
}

enum _Mode { clearByKey, clearByKeyAndSubKey, clearAll }

class MyDiskStore implements ICacheStore {
  @override
  Future<bool> clearAll() {
    throw UnimplementedError();
  }

  @override
  Future<bool> clearExpired() {
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(String key, {String? subKey}) {
    throw UnimplementedError();
  }

  @override
  Future<CacheObj> getCacheObj(String key, {String? subKey}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> setCacheObj(CacheObj obj) {
    throw UnimplementedError();
  }
}

class _CacheManagerPanelState extends State<CacheManagerPanel> {
  _Mode? _mode = _Mode.clearAll;
  final _url = "article/query/0/json";
  final _keyController = TextEditingController();
  final _requestMethodController = TextEditingController();
  final _subKeyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Cache Manager",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Theme.of(context).colorScheme.secondary)),
              Container(height: 50),
              Text("1. Choose mode:",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.secondary)),
              DropdownButton<_Mode>(
                  value: _mode,
                  onChanged: (value) => setState(() => _mode = value),
                  items: <_Mode>[
                    _Mode.clearByKey,
                    _Mode.clearByKeyAndSubKey,
                    _Mode.clearAll
                  ]
                      .map<DropdownMenuItem<_Mode>>((value) =>
                          DropdownMenuItem<_Mode>(
                              value: value, child: Text(getTxtByMode(value))))
                      .toList()),
              Container(height: 20),
              for (var w in getRequestMethodViews(context)) w,
              Container(height: 20),
              for (var w in getKeyViews(context)) w,
              Container(height: 20),
              for (var w in getSubKeyViews(context)) w,
              Container(height: 20),
              Text("${getLabel()}. to clear",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.secondary)),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: FloatingActionButton(
                      child: Text("Clear",
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(color: Colors.white)),
                      onPressed: () => _clear()))
            ]));
  }

  void _clear() {
    // ignore: prefer_function_declarations_over_variables
    void Function(dynamic result) resultPrinter =
        (result) => showSnackBar("缓存清理${result ? '成功' : '失败'}");
    if (_mode == _Mode.clearAll) {
      DioHelper.getCacheManager().clearAll().then(resultPrinter);
    } else if (_mode == _Mode.clearByKey) {
      DioHelper.getCacheManager()
          .deleteByPrimaryKey(_keyController.text,
              requestMethod: _requestMethodController.text)
          .then(resultPrinter);
    } else if (_mode == _Mode.clearByKeyAndSubKey) {
      DioHelper.getCacheManager()
          .deleteByPrimaryKeyAndSubKey(_keyController.text,
              requestMethod: _requestMethodController.text,
              subKey: _subKeyController.text)
          .then(resultPrinter);
    }
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  List<Widget> getRequestMethodViews(BuildContext context) {
    if (_mode == _Mode.clearAll) return [];
    _requestMethodController.text = "POST";
    return [
      Text("2. RequestMethod:",
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Theme.of(context).colorScheme.secondary)),
      TextField(
          controller: _requestMethodController,
          style: Theme.of(context).textTheme.bodyLarge),
      Container(height: 20),
    ];
  }

  List<Widget> getKeyViews(BuildContext context) {
    if (_mode == _Mode.clearAll) return [];
    _keyController.text = "${DioHelper.baseUrl}$_url";
    return [
      Text("3. Key:",
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Theme.of(context).colorScheme.secondary)),
      TextField(
          controller: _keyController,
          style: Theme.of(context).textTheme.bodyLarge),
      Container(height: 20),
    ];
  }

  List<Widget> getSubKeyViews(BuildContext context) {
    if (_mode == _Mode.clearAll || _mode == _Mode.clearByKey) return [];
    _subKeyController.text = "k=flutter";
    return [
      Text("4. Subkey:",
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: Theme.of(context).colorScheme.secondary)),
      TextField(
          controller: _subKeyController,
          style: Theme.of(context).textTheme.bodyLarge),
      Container(height: 20),
    ];
  }

  String getLabel() {
    if (_mode == _Mode.clearAll) {
      return "2";
    } else if (_mode == _Mode.clearByKey) {
      return "4";
    } else {
      return "5";
    }
  }

  String getTxtByMode(_Mode mode) {
    if (mode == _Mode.clearAll) {
      return "Clear All";
    } else if (mode == _Mode.clearByKey) {
      return "Clear by Key";
    } else {
      return "Clear By Key and SubKey";
    }
  }
}
