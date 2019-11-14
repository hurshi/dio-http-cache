import 'dart:convert';

import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dio_helper.dart';

class PostPanel extends StatefulWidget {
  @override
  State createState() => _PostPanelState();
}

class _PostPanelState extends State<PostPanel> {
  String _content = "Hello ~";

//  var _url = "https://www.v2ex.com/generate_204"; //204 test
  var _url = "article/query/0/json";
  var _paramsController;
  var _urlController;

  @override
  void initState() {
    super.initState();
    _paramsController = TextEditingController(text: "flutter");
    _urlController = TextEditingController(text: _url);
  }

  void _doPost() {
    var params = _paramsController.text;
    var paramsAvailable = null != params && params.length > 0;
    setState(() => _content = "Requesting $params ...");
    DioHelper.getDio()
        .post(_urlController.text,
            data: paramsAvailable ? {'k': params} : {},
            options: buildCacheOptions(Duration(hours: 1),
                subKey: paramsAvailable ? "k=$params" : null,
                forceRefresh: false))
        .then((response) => setState(() => _content = "Cached:\n\n"
            "key: ${_url.startsWith(RegExp(r"https?:")) ? "" : DioHelper.baseUrl}$_url\n\n"
            "${paramsAvailable ? 'subkey: k=$params\n\n' : ""}"
            "StatusCode: ${response.statusCode}\n\nc"
            "ontent: ${jsonEncode(response.data)}"))
        .catchError((onError, stackTrace) => setState(() =>
            _content = "Error occur:\n$onError\n\nStackTrace:\n$stackTrace"));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("Base url:",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle
                      .copyWith(color: Theme.of(context).accentColor)),
              Text(DioHelper.baseUrl,
                  style: Theme.of(context)
                      .textTheme
                      .body1
                      .copyWith(color: Colors.grey)),
              Container(height: 20),
              Text("Request url:",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle
                      .copyWith(color: Theme.of(context).accentColor)),
              TextField(controller: _urlController),
              Container(height: 20),
              Text("Request params:",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle
                      .copyWith(color: Theme.of(context).accentColor)),
              Row(children: <Widget>[
                Expanded(child: TextField(controller: _paramsController)),
                FloatingActionButton(
                    child: Text("GO",
                        style: Theme.of(context)
                            .textTheme
                            .subtitle
                            .copyWith(color: Colors.white)),
                    onPressed: () => _doPost()),
              ]),
              Expanded(
                child: SingleChildScrollView(
                    child: Text(
                  '$_content',
                  style: TextStyle(color: Colors.blueGrey),
                )),
              )
            ]));
  }
}
