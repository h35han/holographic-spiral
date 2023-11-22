import 'package:flutter/widgets.dart';

import 'spiral.dart';

/// A card widget featuring a fibonacci spiral with a diffraction
/// grating effect as the background.

class PaymentCard extends StatelessWidget {
  const PaymentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SpiralCard(
      foregroundBuilder: (context, constraints) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "🌵Cacti",
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "\$226.78",
                    style: TextStyle(
                      fontSize: 30,
                      color: Color(0xFFFFFFFF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SpiralCard extends StatelessWidget {
  const SpiralCard({super.key, required this.foregroundBuilder});

  final LayoutWidgetBuilder foregroundBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            width: 0.5,
            color: Color(0xFF393939),
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 1.6279,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: DiffractionSpiral(
                    size: Size.square(constraints.biggest.width),
                  ),
                ),
                foregroundBuilder(context, constraints),
              ],
            );
          },
        ),
      ),
    );
  }
}
