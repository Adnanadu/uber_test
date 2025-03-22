import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_app/feature/homePage/view/widgets/customized_text_field.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// The controller for the Google Map.
  GoogleMapController? _googleMapController;

  @override
  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  ///intial location of the map when the app is opened
  void initialLocation() {
    _googleMapController!.animateCamera(
      CameraUpdate.newCameraPosition(_initialCameraPosition),
    );
  }

  /// The initial camera position for the map.
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(11.441197, 75.694731),
    zoom: 14.4746,
  );

  /// The position of the map "camera" in the real world.
  static const CameraPosition _cameraPosition = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(11.441197, 75.694731),
    tilt: 59.440717697143555,
    zoom: 14.151926040649414,
  );
  final TextEditingController intialTextController = TextEditingController();
  final TextEditingController destinationTextController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            markers: const <Marker>{},
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated:
                (GoogleMapController controller) =>
                    _googleMapController = controller,
          ),
          SafeArea(
            child: Column(
              children: [
                CustomizedTextField(
                  text: 'search here',
                  controller: intialTextController,
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: 8,
                  ),
                ),
                CustomizedTextField(
                  text: 'choose destination',
                  controller: destinationTextController,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed:
            () => _googleMapController!.animateCamera(
              CameraUpdate.newCameraPosition(_cameraPosition),
            ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
