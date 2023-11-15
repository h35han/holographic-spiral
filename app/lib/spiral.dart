import 'dart:ui';

import 'package:flutter/material.dart';

import 'builder.dart';
import 'painter.dart';

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
      builder: (context, imageLoaderSnapshot) {
        if (imageLoaderSnapshot.hasData) {
          return FragmentProgramLoaderBuilder(
            assetKey: "shaders/diffraction.frag",
            builder: (context, fragmentProgramLoaderSnapshot) {
              if (fragmentProgramLoaderSnapshot.hasData) {
                final normalTexture = imageLoaderSnapshot.data![0];
                final alphaTexture = imageLoaderSnapshot.data![1];

                final textureScale = Matrix4.identity()
                  ..setEntry(0, 0, size.width / alphaTexture.width)
                  ..setEntry(1, 1, size.height / alphaTexture.height);

                final shader = fragmentProgramLoaderSnapshot.data!.fragmentShader()
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
                    valueListenable: DiffractionOffset.of(context).listenable,
                    builder: (context, value, child) {
                      return DiffractionPaint(
                        size: size,
                        shader: shader

                          /// [0.5, 0.5] is in the middle of the diffraction effect
                          ..setFloat(4, value.dx + .5)
                          ..setFloat(5, value.dy + .5),
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
  const DiffractionOffset({super.key, required this.listenable, required super.child});

  /// [listenable] Offset must ba a normalized vector
  final ValueNotifier<Offset> listenable;

  setOffset(Offset value) {
    listenable.value = value;
  }

  translate(double translateX, translateY) {
    listenable.value = listenable.value.translate(translateX, translateY);
  }

  translateX(double value) {
    listenable.value = listenable.value.translate(value, listenable.value.dy);
  }

  translateY(double value) {
    listenable.value = listenable.value.translate(listenable.value.dx, value);
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
