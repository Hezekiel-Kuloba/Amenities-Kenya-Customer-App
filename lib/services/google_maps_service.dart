import 'package:amenities_kenya/models/supplier.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class GoogleMapsService {
  final String apiKey;
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';

  GoogleMapsService(this.apiKey);

  Future<List<Map<String, dynamic>>> getPlaceSuggestions(String input) async {
    final encodedInput = Uri.encodeQueryComponent(input);
    final url = Uri.parse(
      '$_baseUrl/place/autocomplete/json?input=$encodedInput&key=$apiKey&components=country:ke&language=en',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('Autocomplete response: ${json['status']} - ${json['predictions']}');
        if (json['status'] == 'OK' || json['status'] == 'ZERO_RESULTS') {
          return List<Map<String, dynamic>>.from(json['predictions']);
        }
        throw Exception('Failed to fetch suggestions: ${json['status']} - ${json['error_message'] ?? ''}');
      }
      throw Exception('HTTP error: ${response.statusCode}');
    } catch (e) {
      print('Error in getPlaceSuggestions: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      '$_baseUrl/place/details/json?place_id=$placeId&fields=formatted_address,geometry&key=$apiKey&language=en',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('Place details response: ${json['status']}');
        if (json['status'] == 'OK') {
          return json['result'] as Map<String, dynamic>;
        }
        throw Exception('Failed to fetch place details: ${json['status']} - ${json['error_message'] ?? ''}');
      }
      throw Exception('HTTP error: ${response.statusCode}');
    } catch (e) {
      print('Error in getPlaceDetails: $e');
      rethrow;
    }
  }

  Future<String> getAddressFromCoordinates(double lat, double lon) async {
    final url = Uri.parse(
      '$_baseUrl/geocode/json?latlng=$lat,$lon&key=$apiKey&language=en',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print('Geocode response: ${json['status']}');
        if (json['status'] == 'OK') {
          return json['results'][0]['formatted_address'] as String;
        }
        throw Exception('Failed to fetch address: ${json['status']} - ${json['error_message'] ?? ''}');
      }
      throw Exception('HTTP error: ${response.statusCode}');
    } catch (e) {
      print('Error in getAddressFromCoordinates: $e');
      rethrow;
    }
  }

  Future<Coordinates> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return Coordinates(lat: position.latitude, lon: position.longitude);
    } catch (e) {
      print('Error in getCurrentLocation: $e');
      rethrow;
    }
  }
}