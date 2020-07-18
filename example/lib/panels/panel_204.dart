import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

import '../dio_helper.dart';
import 'helper.dart';

class Post204Panel extends StatefulWidget {
  @override
  State createState() => _Post204PanelState();
}

class _Post204PanelState extends State<Post204Panel> {
  Map<String, String> _content = {"Hello ~": ""};
  var _url = "https://www.v2ex.com/generate_204";
  var _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: _url);
  }

  void _doRequest() {
    setState(() => _content = {"Requesting": _url});
    DioHelper.getDio()
        .post(_urlController.text,
            options: buildCacheOptions(Duration(hours: 1)))
        .then((response) => setState(
            () => _content = PanelHelper.getPrintContent(_url, null, response)))
        .catchError((onError, stackTrace) => setState(
            () => _content = PanelHelper.getPrintError(onError, stackTrace)));
  }

  @override
  Widget build(BuildContext context) {
    return PanelHelper.buildNormalPanel(
        "Cache 204 request", _urlController, null, _content, _doRequest);
  }
}
