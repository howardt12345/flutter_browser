import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_browser/tab/tab.dart';
import 'package:flutter_browser/ui/fab.dart';
import 'package:flutter_browser/util/settings.dart';

enum TabMenu {
  refresh,
  exit,
}

class NormalTab extends BrowserTab {
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
  final bool enableAppScheme;
  final String userAgent;
  final bool primary;
  final bool withZoom;
  final bool withLocalStorage;

  NormalTab({Key key,
    this.withJavascript,
    this.clearCache,
    this.clearCookies,
    this.enableAppScheme,
    this.userAgent,
    this.primary: true,
    this.withZoom,
    this.withLocalStorage,
    Uri uri})
      : super(key: key, uri: uri);

  @override _NormalTabState createState() => new _NormalTabState();
}

class _NormalTabState extends State<NormalTab> {
  FlutterWebviewPlugin _webviewPlugin = new FlutterWebviewPlugin();
  TextEditingController _textController;

  Rect _rect;
  Timer _resizeTimer;

  @override
  void initState() {
    super.initState();
    _webviewPlugin.close();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _webviewPlugin.close();
    _webviewPlugin.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PreferredSizeWidget appBar = buildAppBar();
    Widget bottomNavigationBar;
    List<Widget> persistentFooterButtons;

    _webviewPlugin.onUrlChanged.listen((String url) {
      widget.uri = Uri.parse(url);
      _textController.text = widget.uri.toString();
    });

    if(widget.uri != null) {
      if(_rect == null) {
        _rect = _buildRect(context, appBar, bottomNavigationBar, persistentFooterButtons);
        _webviewPlugin.launch(widget.uri.toString(),
            withJavascript: widget.withJavascript,
            clearCache: widget.clearCache,
            clearCookies: widget.clearCookies,
            enableAppScheme: widget.enableAppScheme,
            userAgent: widget.userAgent,
            rect: _rect,
            withZoom: widget.withZoom,
            withLocalStorage: widget.withLocalStorage);
      } else {
        Rect rect = _buildRect(context, appBar, bottomNavigationBar, persistentFooterButtons);
        if (_rect != rect) {
          _rect = rect;
          _resizeTimer?.cancel();
          _resizeTimer = new Timer(new Duration(milliseconds: 300), () {
            // avoid resizing to fast when build is called multiple time
            _webviewPlugin.resize(_rect);
          });
        }
      }

      return new Scaffold(
        appBar: buildAppBar(),
        persistentFooterButtons: persistentFooterButtons,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: buildFloatingActionButton(),
      );
    }
    else return buildHomePage();
  }

  Widget buildHomePage() {
    return new Scaffold(
      appBar: buildAppBar(),
      body: new Center(
        child: new Text("Home"),
      ),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  Widget buildAppBar() {
    _textController = new TextEditingController(text: (widget.uri == null) ? "" : widget.uri.toString());
    return new AppBar(
      titleSpacing: 0.0,
      leading: new IconButton(
          icon: new Icon(Icons.home),
          onPressed: () {
            setState(() => widget.uri = null);
            refresh();
          }
      ),
      title: new TextField(
        maxLines: 1,
        keyboardType: TextInputType.url,
        controller: _textController,
        style: new TextStyle(
            color: Colors.black
        ),
        decoration: new InputDecoration.collapsed(
          border: InputBorder.none,
          hintText: "Search or enter URL",
        ),
        onSubmitted: handleSubmitted,
      ),
      actions: <Widget>[
        new PopupMenuButton<TabMenu>(
          onSelected: (TabMenu result) {
            switch(result) {
              case TabMenu.refresh:
                refresh();
                break;
              case TabMenu.exit:
                exit(0);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<TabMenu>>[
            new PopupMenuItem<TabMenu>(
                value: TabMenu.refresh,
                child: new Text("Refresh")
            ),
            new PopupMenuItem<TabMenu>(
                value: TabMenu.exit,
                child: new Text("Exit")
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFloatingActionButton() {
    return new SpeedDialActionButton(
      icons: <IconData>[
        Icons.bookmark,
        Icons.refresh,
        Icons.settings,
      ],
      functions: <Function>[
        bookmark,
        refresh,
            () {
          Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Settings")));
        },
      ],
    );
  }

  Rect _buildRect(BuildContext context,
      PreferredSizeWidget appBar,
      Widget bottomNavigationBar,
      List<Widget> persistentFooterButtons) {
    bool fullscreen = appBar == null;

    final mediaQuery = MediaQuery.of(context);
    final topPadding = widget.primary ? mediaQuery.padding.top : 0.0;
    num top =
    fullscreen ? 0.0 : appBar.preferredSize.height + topPadding;

    num height = mediaQuery.size.height - top;

    if (bottomNavigationBar != null) {
      height -= 56.0;
    }

    if (persistentFooterButtons != null) {
      height -= 53.0;
    }

    return new Rect.fromLTWH(0.0, top, mediaQuery.size.width, height);
  }

  Future handleSubmitted(String text) async {
    print(text);
    _textController.clear();

    if(text.isEmpty) {
      setState(() => widget.uri = null);
    } else {
      print(await canLaunch(text.replaceAll(" ", "")));
      if(await canLaunch(text.replaceAll(" ", ""))) {
        setState(() {
          widget.uri = Uri.parse(text.replaceAll(" ", ""));
          if(_rect != null) refresh();
        });
      } else {
        search(text);
      }
      _textController.text = widget.uri.toString();
    }
  }

  void copy() async {
    await Clipboard.setData(new ClipboardData(text: widget.uri.toString()));
  }

  void bookmark() {
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Bookmark")));
  }

  void refresh() {
    if(widget.uri != null) {
      _webviewPlugin.reload();
    }
  }

  void search(String query) {
    setState(() =>
      widget.uri = Uri.parse("https://"+Settings.searchEngine+"/search?q="+query)
    );
  }
}

/*
icon: new Image.network(
    'https://www.google.com/s2/favicons?domain=${widget.uri.origin}'
),
* */