import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

import '../dio_helper.dart';

class PanelHelper {
  static Map<String, String> getPrintContent<T>(
      String key, String? subKey, Response<T> response) {
    var result = {
      "Cached": "",
      "Key":
          "${key.startsWith(RegExp(r'https?:')) ? '' : DioHelper.baseUrl}$key"
    };
    if (null != subKey && subKey.length > 0) {
      result.addAll({"subKey": subKey});
    }
    if (null != response.headers.value(DIO_CACHE_HEADER_KEY_DATA_SOURCE)) {
      result.addAll({"data source": "data come from cache"});
    } else {
      result.addAll({"data source": "data come from net"});
    }
    result.addAll({
      "statusCode": "${response.statusCode}",
      "Header": response.headers.toString(),
      "Content": jsonEncode(response.data)
    });
    return result;
  }

  static Map<String, String> getPrintError(
      dynamic onError, dynamic stackTrace) {
    return {
      "Error occur": "",
      "onError": onError.toString(),
      "stackTrace": stackTrace.toString()
    };
  }

  static Widget buildNormalPanel(
      String title,
      TextEditingController? _urlController,
      TextEditingController? _paramsController,
      Map<String, String?> txt,
      Function() request) {
    return Builder(
        builder: (context) => Padding(
            padding: EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("NOTE: $title",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: Theme.of(context).primaryColor)),
                  Container(height: 20),
                  Text("Base url:",
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: Theme.of(context).accentColor)),
                  Text(DioHelper.baseUrl,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(color: Colors.grey)),
                  for (var w in _buildInput(
                      context,
                      _urlController,
                      "Request url",
                      (null == _paramsController) ? request : null))
                    w,
                  for (var w in _buildInput(
                      context, _paramsController, "Request params", request))
                    w,
                  Expanded(
                      child: SingleChildScrollView(
                          child: RichText(
                              text: TextSpan(children: [
                    for (var w in _buildConsoleOutput(context, txt)) w,
                  ]))))
                ])));
  }

  static List<TextSpan> _buildConsoleOutput(
      BuildContext context, Map<String, String?> map) {
    List<TextSpan> widgets = [];
    map.forEach((k, v) {
      widgets.add(TextSpan(
          text: "$k: ",
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: Colors.teal)));
      widgets.add(TextSpan(
          text: "$v\n\n",
          style: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: Theme.of(context).disabledColor)));
    });
    return widgets;
  }

  static List<Widget> _buildInput(BuildContext context,
      TextEditingController? controller, String title, Function()? request) {
    if (null == controller) return [];
    return [
      Container(height: 20),
      Text("$title:",
          style: Theme.of(context)
              .textTheme
              .subtitle2!
              .copyWith(color: Theme.of(context).accentColor)),
      Row(children: <Widget>[
        Expanded(child: TextField(controller: controller)),
        for (var w in _buildRequestButton(context, request)) w,
      ]),
    ];
  }

  static List<Widget> _buildRequestButton(
      BuildContext context, Function()? request) {
    if (null != request)
      return [
        Container(width: 10),
        FloatingActionButton(
            child: Text("GO",
                style: Theme.of(context)
                    .textTheme
                    .subtitle2!
                    .copyWith(color: Colors.white)),
            onPressed: () => request())
      ];
    return [];
  }
}
