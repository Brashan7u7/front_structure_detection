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
  String? _resultado;
  double? _score;

  // Tomar foto
  Future<void> _takePhoto() async {
    final pickedFile = await ImagePickerService.pickImage();
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _resultado = null;
        _score = null;
      });
    }
  }

  // Mostrar modal de éxito
  void _showSuccessModal(BuildContext context, String locationMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  '¡Lugar Correcto!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  locationMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                if (_imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imageFile!,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // Enviar imagen y verificar resultado
  Future<void> _sendPhoto() async {
    if (_imageFile == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📤 Enviando imagen al modelo...")),
    );

    try {
      var response = await ApiService.uploadImage(_imageFile!);

      if (response == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ No se recibió respuesta del servidor."),
          ),
        );
        return;
      }

      setState(() {
        _resultado = response["resultado"] as String? ?? "Desconocido";
        _score = (response["score"] as num?)?.toDouble();
      });

      if (_score != null && _score! > 0.9) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✅ $_resultado (Score: ${_score!.toStringAsFixed(4)})"
          ),
        ),
      );

        var position = await LocationService.getCurrentLocation();
        if (position == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("⚠️ No se pudo obtener la ubicación."),
            ),
          );
          return;
        }

        String locationMessage = await ApiService.sendLocation(
          position.latitude,
          position.longitude,
        );
        
        // Mostrar modal en lugar de SnackBar
        _showSuccessModal(context, locationMessage);
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🚫 No es el lugar correcto. Intenta otra foto 📷"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
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
              if (_resultado != null && _score != null)
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "📌 $_resultado\n🎯 Precisión: ${(_score! * 100).toStringAsFixed(4)}%",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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