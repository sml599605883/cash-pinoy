import 'package:flutter/material.dart';

class NoPopPageRoute<T> extends MaterialPageRoute<T> {
  NoPopPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  bool get popGestureEnabled => false;
}
