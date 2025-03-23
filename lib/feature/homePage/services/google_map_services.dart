import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/google_map_model.dart';
import '../../../env/env.dart'; // Ensure you have your API key in an Env class

// Google Map Services Class
class GoogleMapServices {
  final Dio _dio = Dio();

  /// Get Place Predictions
  Future<List<Prediction>> getPlacePredictions(String input) async {
    try {
      final response = await _dio.get(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json",
        queryParameters: {
          "input": input,
          "key": Env.apiKey,
          "components": "country:IN",
        },
      );

      if (response.statusCode == 200) {
        if (response.data["predictions"] != null) {
          return (response.data["predictions"] as List)
              .map((e) => Prediction.fromJson(e))
              .toList();
        } else {
          return []; // Return an empty list if no predictions
        }
      } else {
        throw Exception(
          "Failed to fetch predictions. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching predictions: $e");
    }
  }

  /// Get Directions & Distance
  Future<RouteInfo?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _dio.get(
        "https://maps.googleapis.com/maps/api/directions/json",
        queryParameters: {
          "origin": "${origin.latitude},${origin.longitude}",
          "destination": "${destination.latitude},${destination.longitude}",
          "key": Env.apiKey,
        },
      );

      if (response.statusCode == 200) {
        return RouteInfo.fromJson(response.data);
      } else {
        throw Exception(
          "Failed to fetch directions. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching directions: $e");
    }
  }

  /// Get LatLng from Place ID
  Future<LatLng> getLatLngFromPlaceId(String placeId) async {
    try {
      final response = await _dio.get(
        "https://maps.googleapis.com/maps/api/place/details/json",
        queryParameters: {"place_id": placeId, "key": Env.apiKey},
      );

      if (response.statusCode == 200 && response.data["result"] != null) {
        final location = response.data["result"]["geometry"]["location"];
        return LatLng(location["lat"], location["lng"]);
      } else {
        throw Exception(
          "Failed to fetch coordinates. Status code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error fetching coordinates: $e");
    }
  }
}
