import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpeedDialActionButton extends StatefulWidget {
  SpeedDialActionButton({Key key, this.icons, this.functions}) : super(key: key);

  final List<IconData> icons;
  final List<Function> functions;

  @override _SpeedDialActionButtonState createState() => new _SpeedDialActionButtonState();
}
class _SpeedDialActionButtonState extends State<SpeedDialActionButton> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).accentColor;
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: new List.generate(widget.icons.length, (int index) {
        Widget child = new Container(
          height: 56.0,
          width: 56.0,
          alignment: FractionalOffset.topCenter,
          child: new ScaleTransition(
            scale: new CurvedAnimation(
              parent: _controller,
              curve: new Interval(
                  0.0,
                  1.0 - index / widget.icons.length / 2.0,
                  curve: Curves.easeOut
              ),
            ),
            child: new FloatingActionButton(
              backgroundColor: backgroundColor,
              mini: true,
              child: new Icon(widget.icons[index], color: foregroundColor),
              onPressed: widget.functions[index],
            ),
          ),
        );
        return child;
      }).toList()..add(
        new FloatingActionButton(
          child: new AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child) {
              return new Transform(
                transform: new Matrix4.rotationZ(_controller.value * 0.5 * math.PI),
                alignment: FractionalOffset.center,
                child: new Icon(_controller.isDismissed ? Icons.menu : Icons.close),
              );
            },
          ),
          onPressed: () {
            if (_controller.isDismissed) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          },
        ),
      ),
    );
  }
  void f(Function f) {
    f();
  }
}
