import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'card.dart';
import 'input.dart';
import 'spiral.dart';

class ShowcaseView extends StatefulWidget {
  const ShowcaseView({super.key});

  @override
  State<ShowcaseView> createState() => _ShowcaseViewState();
}

class _ShowcaseViewState extends State<ShowcaseView> {
  late InputSource source = InputSource.animated;

  Widget buildOffsetElement(BuildContext context, ValueListenable<Offset> listenable) {
    return DiffractionOffset(
      listenable: listenable,
      child: const PaymentCard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child = switch (source) {
      InputSource.animated => AnimatedOffsetListenerWidget(
          builder: (context, listenable, _) => buildOffsetElement(context, listenable),
        ),
      InputSource.gesture => GestureDragOffsetListenableWidget(
          builder: (context, listenable, _) => buildOffsetElement(context, listenable),
        ),
      InputSource.gyro => GyroscopeListenableWidget(
          builder: (context, listenable, _) => buildOffsetElement(context, listenable),
        ),
    };

    return Material(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              child,
              SourceSelector(
                value: source,
                onChange: (value) => setState(() => source = value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SourceSelector extends StatelessWidget {
  const SourceSelector({super.key, required this.value, required this.onChange});

  final InputSource value;
  final Function(InputSource value) onChange;

  @override
  Widget build(BuildContext context) {
    String? hint = getSourceHint(value);
    return DropdownButtonHideUnderline(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Choose Animation Source",
            style: Theme.of(context).textTheme.labelMedium,
          ),
          DropdownButton<InputSource>(
            isExpanded: true,
            value: value,
            items: InputSource.values
                .map(
                  (source) => DropdownMenuItem(
                    value: source,
                    child: Text(sourceToString(source)),
                  ),
                )
                .toList(),
            onChanged: (v0) => onChange(v0 ?? value),
          ),
          if (hint != null) Text(hint, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  static String sourceToString(InputSource value) => switch (value) {
        InputSource.animated => "Animated",
        InputSource.gesture => "Gesture",
        InputSource.gyro => "Gyroscope",
      };

  static String? getSourceHint(InputSource value) => switch (value) {
        InputSource.gesture => "Drag across the card to adjust the offset.",
        InputSource.gyro => "Tilt your device to adjust the offset.",
        _ => null,
      };
}
