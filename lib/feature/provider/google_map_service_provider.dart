import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_app/feature/homePage/model/google_map_model.dart';
import 'package:uber_app/feature/homePage/services/google_map_services.dart';

/// ✅ Google Map Services Provider
final googleMapServiceProvider = Provider((ref) => GoogleMapServices());

/// ✅ Place Predictions (Search Suggestions) Provider
final placePredictionsProvider =
    FutureProvider.family<List<Prediction>, String>((ref, input) async {
      return ref.watch(googleMapServiceProvider).getPlacePredictions(input);
    });

/// ✅ Route & Distance Provider
final directionsProvider = FutureProvider.family<RouteInfo?, LatLngPair>((
  ref,
  pair,
) async {
  return ref
      .watch(googleMapServiceProvider)
      .getDirections(origin: pair.origin, destination: pair.destination);
});

/// ✅ Polyline Provider to Draw Route on Map
final routePolylinesProvider = Provider.family<Set<Polyline>, LatLngPair>((
  ref,
  pair,
) {
  final routeAsync = ref.watch(directionsProvider(pair));
  return routeAsync.when(
    data: (route) {
      if (route != null && route.polylinePoints.isNotEmpty) {
        return {
          Polyline(
            polylineId: const PolylineId("route"),
            color: Colors.blue,
            width: 5,
            points:
                route.polylinePoints
                    .map((e) => LatLng(e.latitude, e.longitude))
                    .toList(),
          ),
        };
      } else {
        return {};
      }
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// ✅ Provider to Get `LatLng` from Place ID
final placeLatLngProvider = FutureProvider.family<LatLng, String>((
  ref,
  placeId,
) async {
  return ref.watch(googleMapServiceProvider).getLatLngFromPlaceId(placeId);
});

class LatLngPair {
  final LatLng origin;
  final LatLng destination;
  LatLngPair({required this.origin, required this.destination});
}
