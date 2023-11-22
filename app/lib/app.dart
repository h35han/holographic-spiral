import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'showcase.dart';
import 'input.dart';
import 'spiral.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: ShowcaseView(),
    );
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
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: DiffractionOffset(
              listenable: listenable,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Card(),
              ),
            ),
          ),
        ],
      );
    }

    Widget child = switch (source) {
      InputSource.animated => AnimatedOffsetListenerWidget(builder: builder),
      InputSource.gesture => GestureDragOffsetListenableWidget(builder: builder),
      InputSource.gyro => GyroscopeListenableWidget(builder: builder),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            child,
            // TextButton(
            //   onPressed: () => setState(() => source = InputSource.gesture),
            //   child: const Text("Gesture"),
            // ),
            // TextButton(
            //   onPressed: () => setState(() => source = InputSource.animated),
            //   child: const Text("Animation"),
            // ),
            // TextButton(
            //   onPressed: () => setState(() => source = InputSource.gyro),
            //   child: const Text("Gyroscope"),
            // ),
          ],
        ),
      ),
    );
  }
}


