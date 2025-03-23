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
  Marker? origin;
  Marker? destination;

  void addMarker(LatLng pos) {
    if ((destination != null)) {
      setState(() {
        origin = Marker(
          markerId: const MarkerId("origin"),
          infoWindow: const InfoWindow(title: "Origin"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          position: pos,
        );
        destination = null;
      });
    } else {
      setState(() {
        destination = Marker(
          markerId: const MarkerId("destination"),
          infoWindow: const InfoWindow(title: "Destination"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        );
      });
    }
  }

  /// Text controllers for the initial location and destination location.

  final TextEditingController intialTextController = TextEditingController();
  final TextEditingController destinationTextController =
      TextEditingController();

  double calculateFare(double km, String vehicleType) {
    double carRate = 10.0; // ₹10 per km
    double bikeRate = 5.0; // ₹5 per km

    return vehicleType == "car" ? km * carRate : km * bikeRate;
  }

  final double distance = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Google Map
          GoogleMap(
            markers: const <Marker>{},
            onLongPress: addMarker,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated:
                (GoogleMapController controller) =>
                    _googleMapController = controller,
          ),

          /// intial location and destination location text fields
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

      floatingActionButton:
          (destinationTextController.text.isNotEmpty &&
                  intialTextController.text.isNotEmpty)
              ? null
              : FloatingActionButton(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                onPressed:
                    () => _googleMapController!.animateCamera(
                      CameraUpdate.newCameraPosition(_cameraPosition),
                    ),
                child: const Icon(Icons.center_focus_strong),
              ),
      bottomNavigationBar:
          (destinationTextController.text.isNotEmpty &&
                  intialTextController.text.isNotEmpty)
              ? Container(
                height: 150,
                color: Colors.white38,
                child: Column(
                  children: [
                    Text("Total Distance: $distance km"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image(
                          image: AssetImage("assets/icons/car.png"),
                          height: 50,
                        ),
                        Text("Car Fare: ₹${calculateFare(distance, "car")}"),
                        TextButton(
                          onPressed: () {},
                          child: Text("Ride with Car"),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image(
                          image: AssetImage("assets/icons/motorcycle.png"),
                          height: 50,
                        ),

                        Text("Bike Fare: ₹${calculateFare(distance, "bike")}"),
                        TextButton(
                          onPressed: () {},
                          child: Text("Ride with Bike"),
                        ),
                      ],
                    ),
                  ],
                ),
              )
              : null,
    );
  }
}
