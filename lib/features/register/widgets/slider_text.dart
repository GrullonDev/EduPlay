import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';

class SliderText extends StatelessWidget {
  const SliderText({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterProvider>(
      builder: (context, provider, child) {
        return Text(
          'Edad: ${provider.isSliderActive ? provider.age : 'Seleccione una edad'}',
          style: const TextStyle(fontSize: 24),
        );
      },
    );
  }
}
