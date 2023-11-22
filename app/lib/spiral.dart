import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Diffraction Grating
/// https://en.wikipedia.org/wiki/Diffraction_grating
///
/// Diffraction gratings are optical devices that consist of a large number of evenly
/// spaced parallel slits or rulings. When white light, which is a combination of all
/// colors of the spectrum, interacts with a diffraction grating, it undergoes both
/// diffraction and dispersion
///
/// When white light interacts with a diffraction grating, the combination of diffraction
/// and dispersion causes the light to spread out into its individual colors,
/// creating a beautiful and distinct spectrum
///
/// This widget emulates the diffraction grating effect using GLSL.
/// By leveraging the power of GLSL, it recreates the intricate patterns and
/// dispersion of light seen in optical gratings. The result is a visually
/// engaging experience that brings the optical phenomenon to digital interfaces,
/// showcasing the dynamic play of light in a compact and captivating display.

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
                  // blendMode: BlendMode.dst,
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

class ShaderPainter extends CustomPainter {
  final FragmentShader shader;

  ShaderPainter({required this.shader});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..shader = shader;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class DiffractionOffset extends InheritedWidget {
  const DiffractionOffset({super.key, required this.listenable, required super.child});

  /// [listenable] Offset must ba a normalized vector
  final ValueListenable<Offset> listenable;

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

typedef ShaderWidgetBuilder = AsyncWidgetBuilder<FragmentProgram>;

class FragmentProgramLoaderBuilder extends StatelessWidget {
  const FragmentProgramLoaderBuilder({super.key, required this.assetKey, required this.builder});

  final String assetKey;
  final ShaderWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FragmentProgram.fromAsset(assetKey),
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

Future<ui.Image> imageFromAsset(String assetKey) => ImmutableBuffer.fromAsset(assetKey).then(
      (buffer) => instantiateImageCodecFromBuffer(buffer).then(
        (codec) => codec.getNextFrame().then((frameInfo) => frameInfo.image),
      ),
    );
