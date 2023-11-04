import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: Card(),
    );
  }
}

class Card extends StatelessWidget {
  const Card({super.key});

  @override
  Widget build(BuildContext context) {
    // return Placeholder();

    return Center(
      child: SizedBox.fromSize(
        size: Size.square(MediaQuery.of(context).size.width),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return BumpyDiffractionBuilder2(
              programFuture: ui.FragmentProgram.fromAsset('shaders/diffraction.glsl'),
              cFuture0: AssetImageProvider("assets/textures/normal.png").image,
              cFuture1: AssetImageProvider("assets/textures/alpha.png").image,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var decorator = snapshot.data!;
                  decorator.setSize(constraints.biggest);
                  return CustomPaint(
                    painter: ShaderPainter(shader: decorator.shader),
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}

class BumpyDiffractionShaderDecorator {
  ui.FragmentShader shader;

  BumpyDiffractionShaderDecorator({
    required this.shader,
  });

  setTexture(int index, ui.Image texture) {
    shader.setImageSampler(index, texture);
  }

  setSize(Size size) {
    shader = shader
      ..setFloat(0, size.height)
      ..setFloat(1, size.width);
  }

  setOffset(Offset offset) {
    shader = shader
      ..setFloat(2, offset.dx)
      ..setFloat(3, offset.dy);
  }
}

class AssetImageProvider {
  String path;

  AssetImageProvider(this.path);

  Future<ui.Image> get image async => decodeImageFromList((await rootBundle.load(path)).buffer.asUint8List());
}

class BumpyDiffractionBuilder2 extends StatelessWidget {
  const BumpyDiffractionBuilder2({
    super.key,
    required this.programFuture,
    required this.cFuture0,
    required this.cFuture1,
    required this.builder,
  });

  final Future<ui.FragmentProgram> programFuture;
  final Future<ui.Image> cFuture0;
  final Future<ui.Image> cFuture1;
  final AsyncWidgetBuilder<BumpyDiffractionShaderDecorator> builder;

  Future<BumpyDiffractionShaderDecorator> createShader() async {
    final program = await programFuture;
    final shader = program.fragmentShader();
    return BumpyDiffractionShaderDecorator(shader: shader)
      ..setTexture(0, await cFuture0)
      ..setTexture(1, await cFuture1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: createShader(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return builder(
            context,
            AsyncSnapshot.withData(
              snapshot.connectionState,
              snapshot.data!,
            ),
          );
        }

        return builder(context, snapshot);
      },
    );
  }
}

class ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;

  ShaderPainter({required this.shader});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = shader
      ..filterQuality = ui.FilterQuality.high;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
