import 'dart:convert';

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
  final Distance distance;
  final DurationInfo duration;

  RouteInfo({required this.distance, required this.duration});

  factory RouteInfo.fromJson(Map<String, dynamic> json) => RouteInfo(
    distance: Distance.fromJson(json["legs"][0]["distance"]),
    duration: DurationInfo.fromJson(json["legs"][0]["duration"]),
  );

  Map<String, dynamic> toJson() => {
    "distance": distance.toJson(),
    "duration": duration.toJson(),
  };
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
