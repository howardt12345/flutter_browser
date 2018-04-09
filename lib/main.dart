import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_browser/tab/normal_tab.dart';
import 'package:flutter_browser/util/settings.dart';

void main() => runApp(new MyApp());

Settings settings = new Settings();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Browser',
      theme: new ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.grey[100],
        primaryColorBrightness: Brightness.light,
      ),
      home: new Browser(title: 'Flutter Browser'),
    );
  }
}

class Browser extends StatefulWidget {
  Browser({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _BrowserState createState() => new _BrowserState();
}

class _BrowserState extends State<Browser> {
  static const platform = const MethodChannel('app.channel.shared.data');
  String dataShared = "";

  @override
  void initState() {
    getSharedText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new NormalTab(
        uri: (dataShared.isNotEmpty) ? Uri.parse(dataShared) : null,
      ),
    );
  }

  getSharedText() async {
    var sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null) {
      setState(() {
        dataShared = sharedData;
      });
    }
  }
}
