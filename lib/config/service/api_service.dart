import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String imageUrl = "https://web-production-3b88.up.railway.app/verificar-lugar";
  static const String locationUrl = "https://web-production-3b88.up.railway.app/verificar-ubicacion";

  // Enviar imagen y recibir respuesta JSON
  static Future<Map<String, dynamic>?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(imageUrl));
      request.files.add(await http.MultipartFile.fromPath('imagen', imageFile.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return jsonDecode(responseData);
      } else {
        print("⚠️ Error al enviar la imagen. Código: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Error al subir la imagen: $e");
      return null;
    }
  }

  // Enviar ubicación (AHORA ES UN GET)
  static Future<String> sendLocation(double lat, double lon) async {
    try {
      final uri = Uri.parse("$locationUrl?lat=$lat&lon=$lon");
      var response = await http.get(uri);

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        double distancia = jsonData['distancia'];
        String mensaje = jsonData['mensaje'];

        return "📍 Distancia: ${distancia.toStringAsFixed(2)} metros.\n🔹 $mensaje";
      } else {
        return "⚠️ Error al enviar la ubicación. Código: ${response.statusCode}";
      }
    } catch (e) {
      return "❌ Error: $e";
    }
  }
}
