import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_app/feature/homePage/model/google_map_model.dart';
import 'package:uber_app/feature/homePage/services/google_map_services.dart';

// Provider for Google Map Services
final googleMapServiceProvider = Provider((ref) => GoogleMapServices());

// Provider for Place Predictions (Search Suggestions)
final placePredictionsProvider =
    FutureProvider.family<List<Prediction>, String>((ref, input) async {
      final service = ref.watch(googleMapServiceProvider);
      return service.getPlacePredictions(input);
    });

// Provider for Distance & Route Info
final directionsProvider = FutureProvider.family<RouteInfo, LatLngPair>((
  ref,
  pair,
) async {
  final service = ref.watch(googleMapServiceProvider);
  final routeInfo = await service.getDirections(
    origin: pair.origin,
    destination: pair.destination,
  );

  if (routeInfo == null) {
    // print("⚠️ No valid route found! Returning default.");
    return RouteInfo(
      distance: Distance(text: "0 km", value: 0),
      duration: DurationInfo(text: "0 min", value: 0),
    ); // ✅ Return default object instead of null
  }
  return routeInfo;
});

// Class to Hold LatLng Data
class LatLngPair {
  final LatLng origin;
  final LatLng destination;
  LatLngPair({required this.origin, required this.destination});
}

final placeLatLngProvider = FutureProvider.family<LatLng, String>((
  ref,
  placeId,
) async {
  final service = ref.watch(googleMapServiceProvider);
  return service.getLatLngFromPlaceId(placeId);
});
