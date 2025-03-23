import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_app/env/env.dart';

class GoogleMapServices {
  // static final List<LatLng> _polylinePoints = [
  //   LatLng(11.441197, 75.694731),
  //   LatLng(11.441197, 75.694731),
  // ];

  Future<List<String>> getPlacePredictions(String input) async {
    final response = await Dio().get(
      "https://maps.googleapis.com/maps/api/place/autocomplete/json",
      queryParameters: {
        "input": input,
        "key": Env.apiKey,
        "components": "country:IN",
      },
    );

    return (response.data["predictions"] as List)
        .map((e) => e["description"].toString())
        .toList();
  }

  Future getRoute(LatLng from, LatLng to) async {
    final response = await Dio().get(
      "https://maps.googleapis.com/maps/api/directions/json",
      queryParameters: {
        "origin": "${from.latitude},${from.longitude}",
        "destination": "${to.latitude},${to.longitude}",
        "key": Env.apiKey,
      },
    );

    var points = response.data["routes"][0]["overview_polyline"]["points"];
    return points;
  }
}
