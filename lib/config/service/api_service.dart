import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String imageUrl = "https://web-production-3b88.up.railway.app//verificar-lugar";

  // Enviar imagen y recibir respuesta JSON
  static Future<Map<String, dynamic>?> uploadImage(File imageFile, double latitude, double longitude) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(imageUrl));
      request.files.add(await http.MultipartFile.fromPath('imagen', imageFile.path));
      
      // Agregar latitud y longitud al cuerpo de la solicitud
      request.fields['lat'] = latitude.toString();
      request.fields['lon'] = longitude.toString();

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

}
