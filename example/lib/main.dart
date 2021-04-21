import 'package:flutter/material.dart';

import 'panels/cache_manage.dart';
import 'panels/panel_204.dart';
import 'panels/panel_get.dart';
import 'panels/panel_get_bytes.dart';
import 'panels/panel_get_from_service.dart';
import 'panels/panel_post.dart';
import 'tuple.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = "DioHttpCache Example";
    return MaterialApp(
        title: title,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MyHomePage(title: title));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum Panel { CACHE_MANAGER, POST, POST_204, GET_FROM_SERVICE, GET, GET_BYTES }

class _MyHomePageState extends State<MyHomePage> {
  Panel panel = Panel.POST;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.title!),
            actions: <Widget>[_buildHomePageActionButtons(context)]),
        body: getPanel());
  }

  Widget? getPanel() {
    switch (panel) {
      case Panel.CACHE_MANAGER:
        return CacheManagerPanel();
      case Panel.GET:
        return GetPanel();
      case Panel.POST:
        return PostPanel();
      case Panel.POST_204:
        return Post204Panel();
      case Panel.GET_FROM_SERVICE:
        return PostGetLetServicePanel();
      case Panel.GET_BYTES:
        return GetBytesPanel();
    }
  }

  Widget _buildHomePageActionButtons(BuildContext context) {
    List<Pair<String, Function()>> choices = [
      Pair("Cache Manager", () => setState(() => panel = Panel.CACHE_MANAGER)),
      Pair("POST", () => setState(() => panel = Panel.POST)),
      Pair("POST 204", () => setState(() => panel = Panel.POST_204)),
      Pair("GET", () => setState(() => panel = Panel.GET)),
      Pair("GET from service",
          () => setState(() => panel = Panel.GET_FROM_SERVICE)),
      Pair("GET byte array", () => setState(() => panel = Panel.GET_BYTES)),
    ];
    return PopupMenuButton<Pair<String, Function()>>(
        onSelected: (p) => p.i1!(),
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.menu, color: Colors.white)),
        itemBuilder: (BuildContext context) => choices
            .map((choice) => PopupMenuItem<Pair<String, Function()>>(
                value: choice, child: Text(choice.i0!)))
            .toList());
  }
}
