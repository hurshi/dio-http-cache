import 'package:flutter/material.dart';

import 'panel_cache_manage.dart';
import 'panel_post.dart';
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
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum Panel { POST, CACHE_MANAGER }

class _MyHomePageState extends State<MyHomePage> {
  Panel panel = Panel.POST;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[_buildHomePageActionButtons(context)]),
      body: getPanel(),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.cached),
          onPressed: () => setState(() => panel =
              (panel == Panel.POST) ? Panel.CACHE_MANAGER : Panel.POST)),
    );
  }

  Widget getPanel() {
    switch (panel) {
      case Panel.POST:
        return PostPanel();
      case Panel.CACHE_MANAGER:
        return CacheManagerPanel();
    }
    return null;
  }

  Widget _buildHomePageActionButtons(BuildContext context) {
    List<Pair<String, Function()>> choices = [
      Pair("POST", () => setState(() => panel = Panel.POST)),
      Pair("Cache Manager", () => setState(() => panel = Panel.CACHE_MANAGER)),
    ];
    return PopupMenuButton<Pair<String, Function()>>(
        onSelected: (p) => p.i1(),
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.menu, color: Colors.white)),
        itemBuilder: (BuildContext context) => choices
            .map((choice) => PopupMenuItem<Pair<String, Function()>>(
                value: choice, child: Text(choice.i0)))
            .toList());
  }
}
