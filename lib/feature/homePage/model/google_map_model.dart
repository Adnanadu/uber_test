import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

// Function to parse JSON data
GoogleMapModel googleMapModelFromJson(String str) =>
    GoogleMapModel.fromJson(json.decode(str));

String googleMapModelToJson(GoogleMapModel data) => json.encode(data.toJson());

// Main Model Class
class GoogleMapModel {
  final List<Prediction> predictions;
  final List<RouteInfo> routes;
  final String status;

  GoogleMapModel({
    required this.predictions,
    required this.routes,
    required this.status,
  });

  factory GoogleMapModel.fromJson(Map<String, dynamic> json) {
    return GoogleMapModel(
      predictions:
          (json["predictions"] as List?)
              ?.map((e) => Prediction.fromJson(e))
              .toList() ??
          [],
      routes:
          (json["routes"] as List?)
              ?.map((e) => RouteInfo.fromJson(e))
              .toList() ??
          [],
      status: json["status"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "predictions": predictions.map((e) => e.toJson()).toList(),
    "routes": routes.map((e) => e.toJson()).toList(),
    "status": status,
  };
}

// Prediction Model (for place search)
class Prediction {
  final String description;
  final String placeId;

  Prediction({required this.description, required this.placeId});

  factory Prediction.fromJson(Map<String, dynamic> json) =>
      Prediction(description: json["description"], placeId: json["place_id"]);

  Map<String, dynamic> toJson() => {
    "description": description,
    "place_id": placeId,
  };
}

// Route Info Model (for distance and duration)

class RouteInfo {
  final double distance;
  final double duration;
  final List<LatLng> polylinePoints; // ✅ Add this!

  RouteInfo({
    required this.distance,
    required this.duration,
    required this.polylinePoints, // ✅ Add this!
  });

  Map<String, dynamic> toJson() => {
    "distance": distance,
    "duration": duration,
    "polylinePoints": polylinePoints.map((point) => {"lat": point.latitude, "lng": point.longitude}).toList(),
  };

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    return RouteInfo(
      distance: json["routes"][0]["legs"][0]["distance"]["value"] / 1000.0,
      duration: json["routes"][0]["legs"][0]["duration"]["value"] / 60.0,
      polylinePoints: _decodePolyline(json["routes"][0]["overview_polyline"]["points"]), // ✅ Extract polyline points
    );
  }

  static List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylineCoordinates;
  }
}


// Distance Model (km details
class Distance {
  final String text;
  final int value; // meters

  Distance({required this.text, required this.value});

  factory Distance.fromJson(Map<String, dynamic> json) =>
      Distance(text: json["text"], value: json["value"]);

  Map<String, dynamic> toJson() => {"text": text, "value": value};
}

// Duration Model (time details)
class DurationInfo {
  final String text;
  final int value; // seconds

  DurationInfo({required this.text, required this.value});

  factory DurationInfo.fromJson(Map<String, dynamic> json) =>
      DurationInfo(text: json["text"], value: json["value"]);

  Map<String, dynamic> toJson() => {"text": text, "value": value};
}
