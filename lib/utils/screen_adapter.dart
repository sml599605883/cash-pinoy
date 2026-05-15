import 'dart:math';
import 'package:flutter/widgets.dart';

class ScreenAdapter {
  static const double designWidth = 375;
  static const double designHeight = 812;

  static double _scaleW = 1;
  static double _scaleH = 1;
  static double _scaleText = 1;
  static double _screenW = designWidth;
  static double _screenH = designHeight;

  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _screenW = size.width;
    _screenH = size.height;
    _scaleW = size.width / designWidth;
    _scaleH = size.height / designHeight;
    _scaleText = min(_scaleW, _scaleH);
  }

  static double w(double value) => value * _scaleW;
  static double h(double value) => value * _scaleH;
  static double sp(double value) => value * _scaleText;
  static double r(double value) => value * _scaleText;
  static double get screenW => _screenW;
  static double get screenH => _screenH;
}

extension ScreenNum on num {
  double get w => ScreenAdapter.w(toDouble());
  double get h => ScreenAdapter.h(toDouble());
  double get sp => ScreenAdapter.sp(toDouble());
  double get r => ScreenAdapter.r(toDouble());
}
