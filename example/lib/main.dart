import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dio-http-cache',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'dio-http-cache'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _content =
      "press to request \nhttps://www.wanandroid.com/article/query/0/json";
  var _url = "https://www.wanandroid.com/article/query/0/json";
  static DioCacheManager _manager = DioCacheManager(CacheConfig());

  var _dio = Dio(BaseOptions(
      contentType: ContentType.parse(
          "application/x-www-form-urlencoded; charset=utf-8")))
    ..interceptors.add(_manager.interceptor)
    ..httpClientAdapter = _getHttpClientAdapter();

  var _controller = TextEditingController(text: "flutter");

  void _doPost(String keyword) {
    setState(() {
      _content = "Requesting $keyword ...";
    });
    _dio
        .post(_url,
            data: {'k': keyword},
            options: buildCacheOptions(Duration(hours: 1),
                subKey: "k=$keyword", forceRefresh: false))
        .then((response) {
      setState(() {
        _content =
            "StatusCode = ${response.statusCode}\n${jsonEncode(response.data)}";
      });
    });
  }

  void _deleteCache(String url, {String subKey}) {
    _manager.delete(url, subKey: subKey);
  }

  void _clearExpired() {
    _manager.clearExpired();
  }

  void _clearAll() {
    _manager.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
            child: Column(children: <Widget>[
          MaterialButton(
            child: Text("Delete cache by key"),
            color: Colors.blue,
            onPressed: () {
              _deleteCache(_url);
            },
          ),
          MaterialButton(
            child: Text("Delete cache by key and subkey=flutter"),
            color: Colors.blue,
            onPressed: () {
              _deleteCache(_url, subKey: "k=flutter");
            },
          ),
          MaterialButton(
            child: Text("clear all cache"),
            color: Colors.blue,
            onPressed: () {
              _clearAll();
            },
          ),
          Row(children: <Widget>[
            Expanded(
                child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: "request params",
                    ))),
            IconButton(
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                ),
                iconSize: 35,
                onPressed: () {
                  _doPost(_controller.text);
                })
          ]),
          Expanded(
            child: SingleChildScrollView(
                child: Text(
              '$_content',
              style: TextStyle(color: Colors.blueGrey),
            )),
          )
        ])));
  }

  // set proxy
  static DefaultHttpClientAdapter _getHttpClientAdapter() {
    DefaultHttpClientAdapter httpClientAdapter;
    httpClientAdapter = DefaultHttpClientAdapter();
    httpClientAdapter.onHttpClientCreate = (HttpClient client) {
      client.findProxy = (uri) {
        return 'PROXY 10.0.0.103:8008';
      };
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    return httpClientAdapter;
  }
}
