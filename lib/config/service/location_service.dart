import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el GPS está activado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ El servicio de ubicación está desactivado.");
      return null; // GPS apagado
    }

    // Verifica permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print("⚠️ Permiso de ubicación denegado, solicitando...");
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ El usuario denegó el permiso de ubicación.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("❌ El usuario bloqueó permanentemente el permiso de ubicación.");
      return null;
    }

    // Obtiene la ubicación actual
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print("📍 Ubicación obtenida: ${position.latitude}, ${position.longitude}");
      return position;
    } catch (e) {
      print("❌ Error al obtener la ubicación: $e");
      return null;
    }
  }
}
