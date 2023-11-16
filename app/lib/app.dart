import 'package:flutter/foundation.dart';
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

enum InputSource { gesture, gyro, animated }

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late InputSource source;

  @override
  void initState() {
    source = InputSource.animated;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    builder(BuildContext context, ValueListenable<Offset> listenable, _) {
      return Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.passthrough,
        children: [
          DiffractionOffset(
            listenable: listenable,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Card(),
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
          ),
        ],
      );
    }

    Widget child = switch (source) {
      InputSource.animated => AnimatedOffsetListenerProvider(builder: builder),
      InputSource.gesture => GestureDragOffsetListenableProvider(builder: builder),
      _ => AnimatedOffsetListenerProvider(builder: builder)
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            child,
            TextButton(onPressed: () => setState(() => source = InputSource.gesture), child: const Text("Gesture")),
            TextButton(onPressed: () => setState(() => source = InputSource.animated), child: const Text("Animation")),
          ],
        ),
      ),
    );
  }
}

class Card extends StatelessWidget {
  const Card({super.key, this.markerVisibility = true});

  final bool markerVisibility;

  Widget buildOverlayElements(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "🫀Cash",
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
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

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
            buildOverlayElements(context),
          ],
        ),
      ),
    );
  }
}

class GestureDragOffsetListenableProvider extends StatefulWidget {
  const GestureDragOffsetListenableProvider({super.key, required this.builder, this.child});

  final ValueWidgetBuilder<ValueNotifier<Offset>> builder;
  final Widget? child;

  @override
  State<GestureDragOffsetListenableProvider> createState() => _GestureDragOffsetListenableProviderState();
}

class _GestureDragOffsetListenableProviderState extends State<GestureDragOffsetListenableProvider> {
  final ValueNotifier<Offset> listenable = ValueNotifier(Offset.zero);
  static const scale = 5;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    /// Gesture input converts into a [-1, 1] normalized vector
    /// [0, 0] is in the center of the touch area
    convert(Offset offset) => Offset(
          (offset.dx / size.width) * scale - (scale / 2),
          (offset.dy / size.height) * scale - (scale / 2),
        );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (details) => listenable.value = convert(details.localPosition),
      onPanDown: (details) => listenable.value = convert(details.localPosition),
      child: widget.builder(context, listenable, widget.child),
    );
  }
}

class AnimatedOffsetListenerProvider extends StatefulWidget {
  const AnimatedOffsetListenerProvider({super.key, required this.builder, this.child});

  final ValueWidgetBuilder<Animation<Offset>> builder;
  final Widget? child;

  @override
  State<AnimatedOffsetListenerProvider> createState() => _AnimatedOffsetListenerProviderState();
}

class _AnimatedOffsetListenerProviderState extends State<AnimatedOffsetListenerProvider>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this)
      ..repeat(
        reverse: true,
        period: const Duration(seconds: 3),
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      Tween<Offset>(begin: const Offset(-2, .0), end: const Offset(2, 1)).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOutQuad)..dispose(),
      ),
      widget.child,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
