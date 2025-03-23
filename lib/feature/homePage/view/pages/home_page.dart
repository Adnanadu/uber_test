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

  List<String> fromSuggestions = [];
  List<String> toSuggestions = [];

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
        isFrom ? fromSuggestions.clear() : toSuggestions.clear();
      });
      return;
    }

    final predictions = await ref.read(placePredictionsProvider(input).future);
    setState(() {
      if (isFrom) {
        fromSuggestions = predictions.map((e) => e.description).toList();
      } else {
        toSuggestions = predictions.map((e) => e.description).toList();
      }
    });
  }

  /// Set marker when user selects a prediction
  void setLocation(String location, bool isFrom) {
    if (isFrom) {
      fromController.text = location;
      fromSuggestions.clear();
    } else {
      toController.text = location;
      toSuggestions.clear();
    }

    ref.invalidate(directionsProvider);
  }

  /// Add marker to the map
  void addMarker(LatLng pos) {
    setState(() {
      if (destination != null) {
        origin = Marker(
          markerId: const MarkerId("origin"),
          infoWindow: const InfoWindow(title: "Origin"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          position: pos,
        );
        destination = null;
      } else {
        destination = Marker(
          markerId: const MarkerId("destination"),
          infoWindow: const InfoWindow(title: "Destination"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        );
      }
    });

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
            onLongPress: addMarker,
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
                      (selection) => setLocation(selection, true),
                  suggestions: fromSuggestions,
                ),
                CustomizedTextField(
                  text: 'Choose destination',
                  controller: toController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  onChanged: (input) => fetchPredictions(input, false),
                  onSuggestionSelected:
                      (selection) => setLocation(selection, false),
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

  Widget _buildBottomNavigationBar(AsyncValue<RouteInfo> directionState) {
    return directionState.when(
      data:
          (data) =>
              data.distance.value == 0
                  ? _buildErrorContainer(
                    "No route found! Please select valid locations.",
                  )
                  : _buildFareInfo(data.distance.text),
      loading: () => _buildLoadingContainer(),
      error: (err, _) => _buildErrorContainer("Error: $err"),
    );
  }

  Widget _buildFareInfo(String distance) {
    double km = double.tryParse(distance.replaceAll(" km", "")) ?? 0;
    return Container(
      height: 150,
      color: Colors.white38,
      child: Column(
        children: [
          Text("Total Distance: $distance"),
          _buildFareRow("Car", "assets/icons/car.png", km * 10),
          _buildFareRow("Bike", "assets/icons/motorcycle.png", km * 5),
        ],
      ),
    );
  }

  Widget _buildFareRow(String vehicle, String assetPath, double fare) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Image(image: AssetImage(assetPath), height: 50),
        Text("$vehicle Fare: ₹$fare"),
        TextButton(onPressed: () {}, child: Text("Ride with $vehicle")),
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
      child: const Center(child: Text("Loading route... ⏳")),
    );
  }
}
