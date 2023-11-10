import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:holographic_spiral/util.dart';
import 'package:holographic_spiral/util.dart';

import 'painter.dart';
import 'sandbox.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      // home: Card(),
      home: SandboxPage(),
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
              programFuture: ui.FragmentProgram.fromAsset('shaders/diffraction.frag'),
              cFuture0: imageFromAsset("assets/textures/normal.png"),
              cFuture1: imageFromAsset("assets/textures/alpha.png"),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  snapshot.data!.setSize(constraints.biggest);
                  return AnimatedCard(decorator: snapshot.data!);
                }

                if (snapshot.hasError) {
                  return SingleChildScrollView(
                    child: ErrorWidget(snapshot.error!),
                  );
                }

                return const Placeholder();
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({super.key, required this.decorator});

  final BumpyDiffractionShaderDecorator decorator;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: const Offset(200, 100),
    end: const Offset(200, 200),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  ));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        widget.decorator.setOffset(_offsetAnimation.value);
        return CustomPaint(
          painter: ShaderPainter(shader: widget.decorator.shader),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

