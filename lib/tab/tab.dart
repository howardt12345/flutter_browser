import 'package:flutter/material.dart';

abstract class BrowserTab extends StatefulWidget {
  BrowserTab({Key key, this.uri}) : super(key: key);

  Uri uri;
}