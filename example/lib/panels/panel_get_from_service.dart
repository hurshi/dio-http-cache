import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

import '../dio_helper.dart';
import 'helper.dart';

class PostGetLetServicePanel extends StatefulWidget {
  @override
  State createState() => _PostGetLetServicePanelState();
}

class _PostGetLetServicePanelState extends State<PostGetLetServicePanel> {
  Map<String, String> _content = {"Hello ~": ""};
  var _url =
      "https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Cache-Control";
  var _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _url);
  }

  void _doRequest() {
    setState(() => _content = {"Requesting": _url});
    DioHelper.getDio()
        .get(_urlController.text,
            options: buildServiceCacheOptions(forceRefresh: false))
        .then((response) => setState(
            () => _content = PanelHelper.getPrintContent(_url, null, response)))
        .catchError((onError, stackTrace) => setState(
            () => _content = PanelHelper.getPrintError(onError, stackTrace)));
  }

  @override
  Widget build(BuildContext context) {
    return PanelHelper.buildNormalPanel(
        "Cache strategy by service, try to read maxAge and maxStale from response http head.",
        _urlController,
        null,
        _content,
        _doRequest);
  }
}
