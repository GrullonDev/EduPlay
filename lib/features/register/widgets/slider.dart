import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/register/widgets/slider_text.dart';
import 'package:edu_play/features/register/widgets/slider_control.dart';

class SliderWidget extends StatelessWidget {
  const SliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SliderText(),
        SliderControl(),
      ],
    );
  }
}
