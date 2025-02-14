import 'package:flutter/material.dart';

import 'package:edu_play/features/register/widgets/slider_control.dart';
import 'package:edu_play/features/register/widgets/slider_text.dart';

class SliderWidget extends StatelessWidget {
  const SliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SliderText(),
        SliderControl(),
      ],
    );
  }
}
