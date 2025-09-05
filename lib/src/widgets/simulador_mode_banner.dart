import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posmobil/src/services/bluetooth_printer_service.dart';

class SimulatorModeBanner extends StatelessWidget {
  const SimulatorModeBanner({Key? key}) : super(key: key);

  bool get isSimulatedEnvironment {
    // Alternativa rápida: detecta si estás en Android y no en un dispositivo físico
    return Platform.isAndroid && Platform.environment.containsKey('ANDROID_EMULATOR_BUILD');
  }

  @override
  Widget build(BuildContext context) {
    if (!isSimulatedEnvironment) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Modo simulador activo: la impresión es simulada en consola.',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}