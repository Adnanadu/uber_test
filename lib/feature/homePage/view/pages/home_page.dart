import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_app/feature/homePage/model/google_map_model.dart';
import 'package:uber_app/feature/provider/google_map_service_provider.dart';
import '../widgets/customized_text_field.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  GoogleMapController? _googleMapController;
  Marker? origin;
  Marker? destination;
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  List<Prediction> fromSuggestions = [];
  List<Prediction> toSuggestions = [];

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(11.441197, 75.694731),
    zoom: 14.5,
  );

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  /// Fetch place predictions when user types
  void fetchPredictions(String input, bool isFrom) async {
    if (input.isEmpty) {
      setState(() {
        isFrom ? fromSuggestions = [] : toSuggestions = [];
      });
      return;
    }

    final predictions = await ref.read(placePredictionsProvider(input).future);
    setState(() {
      if (isFrom) {
        fromSuggestions = predictions;
      } else {
        toSuggestions = predictions;
      }
    });
  }

  /// Set marker when user selects a prediction
  void setLocation(Prediction prediction, bool isFrom) async {
    if (isFrom) {
      fromController.text = prediction.description;
      fromSuggestions.clear();
    } else {
      toController.text = prediction.description;
      toSuggestions.clear();
    }

    final placeLatLng = await ref.read(
      placeLatLngProvider(prediction.placeId).future,
    );

    setState(() {
      if (isFrom) {
        origin = Marker(
          markerId: const MarkerId("origin"),
          position: placeLatLng,
          infoWindow: const InfoWindow(title: "Pickup Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
      } else {
        destination = Marker(
          markerId: const MarkerId("destination"),
          position: placeLatLng,
          infoWindow: const InfoWindow(title: "Destination"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }
    });

    _googleMapController?.animateCamera(
      CameraUpdate.newLatLngZoom(placeLatLng, 14),
    );

    if (origin != null && destination != null) {
      ref.invalidate(directionsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final directionState = ref.watch(
      directionsProvider(
        LatLngPair(
          origin: origin?.position ?? const LatLng(0, 0),
          destination: destination?.position ?? const LatLng(0, 0),
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            markers: {
              if (origin != null) origin!,
              if (destination != null) destination!,
            },
            polylines: ref.watch(
              routePolylinesProvider(
                LatLngPair(
                  origin: origin?.position ?? const LatLng(0, 0),
                  destination: destination?.position ?? const LatLng(0, 0),
                ),
              ),
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) => _googleMapController = controller,
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
                  suggestions: fromSuggestions,
                ),
                CustomizedTextField(
                  text: 'Choose destination',
                  controller: toController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  onChanged: (input) => fetchPredictions(input, false),
                  onSuggestionSelected:
                      (prediction) => setLocation(prediction, false),
                  suggestions: toSuggestions,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(directionState),
    );
  }

  Widget _buildBottomNavigationBar(AsyncValue<RouteInfo?> directionState) {
    return directionState.when(
      data: (data) {
        if (data == null || data.distance == 0) {
          return _buildErrorContainer(
            "No route found! Please select valid locations.",
          );
        }
        return _buildFareInfo("${data.distance / 1000} km");
      },
      loading: () => _buildLoadingContainer(),
      error: (err, _) => _buildErrorContainer("Error: $err"),
    );
  }

  Widget _buildFareInfo(String distance) {
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
              _googleMapController?.animateCamera(
                CameraUpdate.newLatLngBounds(
                  LatLngBounds(
                    southwest: origin!.position,
                    northeast: destination!.position,
                  ),
                  50,
                ),
              );
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

  Widget _buildLoadingContainer() {
    return Container(
      height: 60,
      color: Colors.white,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
