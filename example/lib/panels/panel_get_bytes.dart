import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

import '../dio_helper.dart';
import 'helper.dart';

class GetBytesPanel extends StatefulWidget {
  @override
  State createState() => _GetBytesPanelState();
}

class _GetBytesPanelState extends State<GetBytesPanel> {
  Map<String, String> _content = {"Hello ~": ""};
  var _url =
      "https://ss0.baidu.com/6ONWsjip0QIZ8tyhnq/it/u=1731248121,277041329&fm=58&s=0DE6CD13D1A06D015651B0D6000080B1&bpow=121&bpoh=75";
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
            options: buildCacheOptions(Duration(hours: 1),
                forceRefresh: false,
                options: Options(responseType: ResponseType.bytes)))
        .then((response) => setState(
            () => _content = PanelHelper.getPrintContent(_url, null, response)))
        .catchError((onError, stackTrace) => setState(
            () => _content = PanelHelper.getPrintError(onError, stackTrace)));
  }

  @override
  Widget build(BuildContext context) {
    return PanelHelper.buildNormalPanel(
        "GET bytes example", _urlController, null, _content, _doRequest);
  }
}
