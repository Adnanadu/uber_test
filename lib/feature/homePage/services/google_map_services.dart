import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/google_map_model.dart';
import '../../../env/env.dart';

// Google Map Services Class
class GoogleMapServices {
  final Dio _dio = Dio();

  /// Get LatLng from a Place ID
Future<LatLng> getLatLngFromPlaceId(String placeId) async {
  try {
    final response = await _dio.get(
      "https://maps.googleapis.com/maps/api/place/details/json",
      queryParameters: {
        "place_id": placeId,
        "key": Env.apiKey,
      },
    );

    if (response.statusCode == 200 &&
        response.data["result"] != null &&
        response.data["result"]["geometry"] != null) {
      final location = response.data["result"]["geometry"]["location"];
      return LatLng(location["lat"], location["lng"]);
    } else {
      throw Exception("Failed to fetch place details");
    }
  } catch (e) {
    print("Error fetching place details: $e");
    throw Exception("Error fetching place details: $e");
  }
}


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
        return (response.data["predictions"] as List)
            .map((e) => Prediction.fromJson(e))
            .toList();
      } else {
        throw Exception("Failed to fetch predictions");
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
      // print("Fetching directions from $origin to $destination..."); // ✅ Debug log

      final response = await _dio.get(
        "https://maps.googleapis.com/maps/api/directions/json",
        queryParameters: {
          "origin": "${origin.latitude},${origin.longitude}",
          "destination": "${destination.latitude},${destination.longitude}",
          "key": Env.apiKey,
        },
      );

      // print("API Response: ${response.data}"); // ✅ Debug log

      if (response.statusCode == 200 && response.data["routes"].isNotEmpty) {
        return RouteInfo.fromJson(
          response.data["routes"][0],
        ); // ✅ Return parsed object
      } else {
        // print("Error: No valid routes found!"); // ✅ Debug log
        return null; // Return null instead of throwing an error
      }
    } catch (e) {
      // print("Error fetching directions: $e"); // ✅ Debug log
      return null; // Return null instead of crashing the app
    }
  }
}
