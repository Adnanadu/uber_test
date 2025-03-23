import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uber_app/feature/homePage/model/google_map_model.dart';
import 'package:uber_app/feature/provider/google_map_service_provider.dart';
import '../widgets/customized_text_field.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(11.441197, 75.694731),
    zoom: 14.5,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleMapController = useState<GoogleMapController?>(null);
    final fromController = useTextEditingController();
    final toController = useTextEditingController();
    final fromSuggestions = useState<List<Prediction>>([]);
    final toSuggestions = useState<List<Prediction>>([]);
    final originMarker = useState<Marker?>(null);
    final destinationMarker = useState<Marker?>(null);

    /// Fetch predictions when user types in the text fields
    void fetchPredictions(String input, bool isFrom) async {
      if (input.isEmpty) {
        if (isFrom) {
          fromSuggestions.value = [];
        } else {
          toSuggestions.value = [];
        }
        return;
      }
      final predictions = await ref.read(
        placePredictionsProvider(input).future,
      );
      if (isFrom) {
        fromSuggestions.value = predictions;
      } else {
        toSuggestions.value = predictions;
      }
    }

    /// Set location when a suggestion is selected
    void setLocation(Prediction prediction, bool isFrom) async {
      if (isFrom) {
        fromController.text = prediction.description;
        fromSuggestions.value = [];
      } else {
        toController.text = prediction.description;
        toSuggestions.value = [];
      }
      final placeLatLng = await ref.read(
        placeLatLngProvider(prediction.placeId).future,
      );
      if (isFrom) {
        originMarker.value = Marker(
          markerId: const MarkerId("origin"),
          position: placeLatLng,
          infoWindow: const InfoWindow(title: "Pickup Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
      } else {
        destinationMarker.value = Marker(
          markerId: const MarkerId("destination"),
          position: placeLatLng,
          infoWindow: const InfoWindow(title: "Destination"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }
      googleMapController.value?.animateCamera(
        CameraUpdate.newLatLngZoom(placeLatLng, 14),
      );
      // Invalidate directions when both locations are set
      if (originMarker.value != null && destinationMarker.value != null) {
        ref.invalidate(directionsProvider);
      }
    }

    final directionState = ref.watch(
      directionsProvider(
        LatLngPair(
          origin: originMarker.value?.position ?? const LatLng(0, 0),
          destination: destinationMarker.value?.position ?? const LatLng(0, 0),
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            markers: {
              if (originMarker.value != null) originMarker.value!,
              if (destinationMarker.value != null) destinationMarker.value!,
            },
            polylines: ref.watch(
              routePolylinesProvider(
                LatLngPair(
                  origin: originMarker.value?.position ?? const LatLng(0, 0),
                  destination:
                      destinationMarker.value?.position ?? const LatLng(0, 0),
                ),
              ),
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated:
                (controller) => googleMapController.value = controller,
          ),
          SafeArea(
            child: Column(
              children: [
                CustomizedTextField(
                  text: 'Search starting location',
                  controller: fromController,
                  padding: const EdgeInsets.all(16.0),
                  onChanged: (input) => fetchPredictions(input, true),
                  onSuggestionSelected:
                      (prediction) => setLocation(prediction, true),
                  suggestions: fromSuggestions.value,
                ),
                CustomizedTextField(
                  text: 'Choose destination',
                  controller: toController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  onChanged: (input) => fetchPredictions(input, false),
                  onSuggestionSelected:
                      (prediction) => setLocation(prediction, false),
                  suggestions: toSuggestions.value,
                ),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: _buildBottomNavigationBar(
      //   directionState,
      //   googleMapController.value,
      //   originMarker.value,
      //   destinationMarker.value,
      // ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.white,
        child: directionState.when(
          data: (data) {
            if (data == null || data.distance == 0) {
              return _buildErrorContainer(
                "No route found! Please select valid locations.",
              );
            }
            return _buildFareInfo(
              "${data.distance.toStringAsFixed(2)} km",
              googleMapController.value,
              originMarker.value,
              destinationMarker.value,
            );
          },
          loading: () => LinearProgressIndicator(),
          error: (err, _) => _buildErrorContainer("Error: $err"),
        ),
      ),
    );
  }

  Widget _buildFareInfo(
    String distance,
    GoogleMapController? controller,
    Marker? origin,
    Marker? destination,
  ) {
    double km = double.tryParse(distance.replaceAll(" km", "")) ?? 0;
    return Container(
      height: 150,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Total Distance: $distance"),
          const SizedBox(height: 8),
          _buildFareRow("Car", "assets/icons/car.png", km * 10),
          const SizedBox(height: 8),
          _buildFareRow("Bike", "assets/icons/motorcycle.png", km * 5),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (controller != null && origin != null && destination != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    LatLngBounds(
                      southwest: origin.position,
                      northeast: destination.position,
                    ),
                    50,
                  ),
                );
              }
            },
            child: const Text("Start Navigation"),
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String vehicle, String assetPath, double fare) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image(image: AssetImage(assetPath), height: 50),
        Text("$vehicle Fare: ₹${fare.toStringAsFixed(2)}"),
      ],
    );
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      height: 60,
      color: Colors.redAccent,
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
