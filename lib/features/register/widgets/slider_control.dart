import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/register/bloc/register_bloc.dart';

class SliderControl extends StatelessWidget {
  const SliderControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterProvider>(
      builder: (context, provider, __) {
        int sliderValue = provider.sliderValue ??
            5; // Usar un valor predeterminado si sliderValue es nulo
        return Slider(
          value: sliderValue.toDouble(),
          min: 5,
          max: 17,
          divisions: 12,
          label: sliderValue.toString(),
          onChanged: (value) {
            provider.setSliderValue(value.toInt());
            provider
                .toggleSlider(true); // Asegurarse de que el slider esté activo
          },
        );
      },
    );
  }
}
