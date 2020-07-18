import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

import '../dio_helper.dart';
import 'helper.dart';

class GetPanel extends StatefulWidget {
  @override
  State createState() => _GetPanelState();
}

class _GetPanelState extends State<GetPanel> {
  Map<String, String> _content = {"Hello ~": ""};
  var _url = "https://www.baidu.com";
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
            options: buildCacheOptions(Duration(hours: 1), forceRefresh: false))
        .then((response) => setState(
            () => _content = PanelHelper.getPrintContent(_url, null, response)))
        .catchError((onError, stackTrace) => setState(
            () => _content = PanelHelper.getPrintError(onError, stackTrace)));
  }

  @override
  Widget build(BuildContext context) {
    return PanelHelper.buildNormalPanel(
        "Normal GET example", _urlController, null, _content, _doRequest);
  }
}
