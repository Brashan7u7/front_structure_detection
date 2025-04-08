import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scanner_flow/config/service/api_service.dart';
import 'package:scanner_flow/config/service/image_picker_service.dart';
import 'package:scanner_flow/config/service/location_service.dart';
import 'package:scanner_flow/presentation/widget/image_display.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile;

  // Tomar foto
  Future<void> _takePhoto() async {
    final pickedFile = await ImagePickerService.pickImage();
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  // Enviar imagen y verificar resultado
  Future<void> _sendPhoto() async {
    if (_imageFile == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📤 Enviando imagen al modelo...")),
    );

    try {
      // Obtener la ubicación actual
      var position = await LocationService.getCurrentLocation();
      if (position == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠️ No se pudo obtener la ubicación."),
          ),
        );
        return;
      }

      // Enviar imagen y ubicación
      var response = await ApiService.uploadImage(
        _imageFile!,
        position.latitude,
        position.longitude,
      );

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ No se recibió respuesta del servidor.")),
        );
        return;
      }

      // Mostrar resultados en un diálogo
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Resultado del Modelo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📌 Resultado: ${response["resultado"]}"),
                Text("🏫 Clase detectada: ${response["clase_detectada"]}"),
                Text("🎯 Confianza: ${(response["confianza"] * 100).toStringAsFixed(2)}%"),
                Text("📏 Distancia: ${response["distancia_metros"]} metros"),
                Text("🔢 Estado: ${response["estado"]}"),
                Text("💬 Detalles: ${response["mensaje_detallado"]}"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cerrar"),
              ),
            ],
          );
        },
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.primary, colors.secondary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageDisplay(imageFile: _imageFile),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _takePhoto,
                child: const Text('Tomar Foto'),
              ),
              const SizedBox(height: 15),
              if (_imageFile != null)
                ElevatedButton(
                  onPressed: _sendPhoto,
                  child: const Text('Enviar al Modelo'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
