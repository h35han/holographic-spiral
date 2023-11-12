import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'builder.dart';
import 'painter.dart';

//  Stack
//    ...
//    DiffractionSpiral
//      TextureLoader
//        ShaderLoader
//          ShaderMask
//            DiffractionShader <= /w DiffractionController
//    ...

class SandboxPage extends StatelessWidget {
  const SandboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DiffractionOffset(
              offset: ValueNotifier(const Offset(0.0, 0.0)),
              child: Stack(
                children: [
                  const Card(),
                  Builder(
                    builder: (context) {
                      var size = MediaQuery.of(context).size;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => DiffractionOffset.of(context).translateY(1.0),
                        onHorizontalDragUpdate: (details) =>
                            DiffractionOffset.of(context).translateX(details.delta.dx / size.width),
                        onVerticalDragUpdate: (details) =>
                            DiffractionOffset.of(context).translateY(details.delta.dy / size.height),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Card extends StatelessWidget {
  const Card({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: Color(0xFF393939),
            width: 0.5,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1.6279,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return DiffractionSpiral(
                    size: Size.square(constraints.biggest.width),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiffractionSpiral extends StatelessWidget {
  const DiffractionSpiral({super.key, required this.size});

  final Size size;

  Widget buildEmpty(BuildContext context) {
    return SizedBox.fromSize(size: size);
  }

  @override
  Widget build(BuildContext context) {
    return ImageLoaderBuilder(
      assetKeys: const [
        "assets/textures/normal.png",
        "assets/textures/alpha.png",
      ],
      builder: (context, imgLoaderSnapshot) {
        if (imgLoaderSnapshot.hasData) {
          return FragmentProgramLoaderBuilder(
            assetKey: "shaders/diffraction.frag",
            builder: (context, fragmentProgramSnapshot) {
              if (fragmentProgramSnapshot.hasData) {
                var normalTexture = imgLoaderSnapshot.data![0];
                var alphaTexture = imgLoaderSnapshot.data![1];

                final textureScale = Matrix4.identity()
                  ..setEntry(0, 0, size.width / alphaTexture.width)
                  ..setEntry(1, 1, size.height / alphaTexture.height);

                var shader = fragmentProgramSnapshot.data!.fragmentShader()
                  ..setFloat(0, size.width)
                  ..setFloat(1, size.height)
                  ..setFloat(2, normalTexture.width.toDouble())
                  ..setFloat(3, normalTexture.height.toDouble())
                  ..setImageSampler(0, normalTexture);

                return ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bound) => ImageShader(
                    alphaTexture,
                    TileMode.clamp,
                    TileMode.clamp,
                    textureScale.storage,
                  ),
                  child: ValueListenableBuilder(
                    valueListenable: DiffractionOffset.of(context).offset,
                    builder: (context, value, child) {
                      return DiffractionPaint(
                        size: size,
                        shader: shader
                          ..setFloat(4, value.dx)
                          ..setFloat(5, value.dy),
                      );
                    },
                  ),
                );
              }

              return buildEmpty(context);
            },
          );
        }

        return buildEmpty(context);
      },
    );
  }
}

class DiffractionPaint extends StatelessWidget {
  const DiffractionPaint({
    super.key,
    required this.shader,
    required this.size,
  });

  final FragmentShader shader;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: ShaderPainter(shader: shader),
    );
  }
}

class DiffractionOffset extends InheritedWidget {
  const DiffractionOffset({super.key, required this.offset, required super.child});

  final ValueNotifier<Offset> offset;

  translate(double translateX, translateY) {
    offset.value = offset.value.translate(translateX, translateY);
  }

  translateX(double value) {
    offset.value = offset.value.translate(value, offset.value.dy);
  }

  translateY(double value) {
    offset.value = offset.value.translate(offset.value.dx, value);
  }

  static DiffractionOffset? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DiffractionOffset>();
  }

  static DiffractionOffset of(BuildContext context) {
    final DiffractionOffset? result = maybeOf(context);
    assert(result != null, 'No DiffractionOffset found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
