import 'package:flutter/material.dart';

import 'spiral.dart';
import 'marker.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(themeMode: ThemeMode.light, debugShowCheckedModeBanner: false, home: HomeView());
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureBuilder(
        builder: (context, listenable, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              DiffractionOffset(
                listenable: listenable,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Card(),
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: listenable,
                builder: (context, value, child) {
                  return OffsetMarker(
                    correction: const Offset(.5, .5),
                    value: value,
                    child: child,
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}

class Card extends StatelessWidget {
  const Card({super.key, this.markerVisibility = true});

  final bool markerVisibility;

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

class GestureBuilder extends StatelessWidget {
  const GestureBuilder({super.key, required this.builder, this.child});

  final ValueWidgetBuilder<ValueNotifier<Offset>> builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /// Gesture input converts into a [-1, 1] normalized vector
    /// [0, 0] is in the middle of the touch area
    convert(Offset offset) => Offset(
          // offset.dx / size.width,
          ((offset.dx / size.width) * scale - (scale / 2)),
          ((offset.dy / size.height) * scale - (scale / 2)),
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) => listenable.value = convert(details.localPosition),
      onPanDown: (details) => listenable.value = convert(details.localPosition),
      child: builder(context, listenable, child),
    );
  }

  static const scale = 5;
  static ValueNotifier<Offset> listenable = ValueNotifier(Offset.zero);
}
