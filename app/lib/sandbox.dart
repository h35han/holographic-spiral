import 'dart:ui';

import 'package:flutter/material.dart';

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
      decoration: const BoxDecoration(color: Colors.black),
      child: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Card(),
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
            // const DecoratedBox(
            //   decoration: BoxDecoration(
            //     gradient: LinearGradient(
            //       begin: Alignment.topCenter,
            //       end: Alignment.bottomCenter,
            //       colors: [Color(0xFF161616), Color(0xFF080808)],
            //     ),
            //   ),
            // ),

            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
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

                return ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (bound) => ImageShader(
                    alphaTexture,
                    TileMode.clamp,
                    TileMode.clamp,
                    textureScale.storage,
                  ),
                  child: CustomPaint(
                    size: size,
                    painter: ShaderPainter(
                      shader: fragmentProgramSnapshot.data!.fragmentShader()
                        ..setFloat(0, size.width)
                        ..setFloat(1, size.height)
                        ..setFloat(2, normalTexture.width.toDouble())
                        ..setFloat(3, normalTexture.height.toDouble())
                        ..setFloat(4, 1.0)
                        ..setFloat(5, .0)
                        ..setImageSampler(0, normalTexture),
                    ),
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

// class AnimatedPainterController extends ChangeNotifier {
//   final FragmentShader shader;
//
//   AnimatedPainterController({required this.shader});
//
//   setLightOffset(Offset offset) {
//     shader
//       ..setFloat(4, 100.0)
//       ..setFloat(5, 100.0);
//   }
// }
//
// class AnimatedPainter extends StatelessWidget {
//   const AnimatedPainter({super.key, required this.controller});
//
//   final AnimatedPainterController controller;
//
//   @override
//   Widget build(BuildContext context) {
//
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         return CustomPaint(
//           size: size,
//           painter: ShaderPainter(
//             shader: controller.shader
//               ..setFloat(0, size.width)
//               ..setFloat(1, size.width)
//               ..setFloat(2, normalTexture.width.toDouble())
//               ..setFloat(3, normalTexture.height.toDouble())
//               ..setImageSampler(0, normalTexture),
//           ),
//         );
//       },
//     );
//   }
// }
