import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'util.dart';

typedef ShaderWidgetBuilder = AsyncWidgetBuilder<ui.FragmentProgram>;

class FragmentProgramLoaderBuilder extends StatelessWidget {
  const FragmentProgramLoaderBuilder({super.key, required this.assetKey, required this.builder});

  final String assetKey;
  final ShaderWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ui.FragmentProgram.fromAsset(assetKey),
      builder: builder,
    );
  }
}

typedef ImageLoaderWidgetBuilder = AsyncWidgetBuilder<List<ui.Image>>;

class ImageLoaderBuilder extends StatelessWidget {
  const ImageLoaderBuilder({super.key, required this.assetKeys, required this.builder});

  final List<String> assetKeys;
  final ImageLoaderWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait(assetKeys.map((item) => imageFromAsset(item))),
      builder: builder,
    );
  }
}
