import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GestureDragOffsetListenableWidget extends StatefulWidget {
  const GestureDragOffsetListenableWidget({super.key, required this.builder, this.child});

  final ValueWidgetBuilder<ValueNotifier<Offset>> builder;
  final Widget? child;

  @override
  State<GestureDragOffsetListenableWidget> createState() => _GestureDragOffsetListenableWidgetState();
}

class _GestureDragOffsetListenableWidgetState extends State<GestureDragOffsetListenableWidget> {
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

  @override
  void dispose() {
    listenable.dispose();
    super.dispose();
  }
}

class GyroscopeListenableWidget extends StatefulWidget {
  const GyroscopeListenableWidget({super.key, required this.builder, this.child});

  final ValueWidgetBuilder<ValueNotifier<Offset>> builder;
  final Widget? child;

  @override
  State<GyroscopeListenableWidget> createState() => _GyroscopeListenableWidgetState();
}

class _GyroscopeListenableWidgetState extends State<GyroscopeListenableWidget> {
  final ValueNotifier<Offset> listenable = ValueNotifier(Offset.zero);
  late StreamSubscription subscription;
  static const scale = 1;

  @override
  void initState() {
    subscription = gyroscopeEvents.listen(handleEvent, cancelOnError: true);
    super.initState();
  }

  handleEvent(GyroscopeEvent event) {
    listenable.value = Offset(event.x * scale, event.y * scale);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, listenable, widget.child);
  }

  @override
  void dispose() {
    listenable.dispose();
    subscription.cancel();
    super.dispose();
  }
}

class AnimatedOffsetListenerWidget extends StatefulWidget {
  const AnimatedOffsetListenerWidget({super.key, required this.builder, this.child});

  final ValueWidgetBuilder<Animation<Offset>> builder;
  final Widget? child;

  @override
  State<AnimatedOffsetListenerWidget> createState() => _AnimatedOffsetListenerWidgetState();
}

class _AnimatedOffsetListenerWidgetState extends State<AnimatedOffsetListenerWidget> with TickerProviderStateMixin {
  late AnimationController controller = AnimationController(vsync: this);

  @override
  void initState() {
    controller.repeat(
      reverse: true,
      period: const Duration(seconds: 2),
    );
    super.initState();
  }

  static Tween<Offset> tween = Tween<Offset>(
    begin: const Offset(-2.8, -.75),
    end: const Offset(2.8, .75),
  );

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      tween.animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOutQuad,
        )..dispose(),
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
