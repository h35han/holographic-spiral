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
  @override
  Widget build(BuildContext context) {
    return Material(
      child: AnimatedOffsetListenerWidget(
        builder: (context, listenable, _) {
          return SafeArea(
            child: DiffractionOffset(
              listenable: listenable,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    PaymentCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
