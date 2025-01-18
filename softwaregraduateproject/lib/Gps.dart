import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GPSMapPage extends StatefulWidget {
  final LatLng initialPosition;

  GPSMapPage({required this.initialPosition});

  @override
  _GPSMapPageState createState() => _GPSMapPageState();
}

class _GPSMapPageState extends State<GPSMapPage> {
  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.initialPosition;
    _markers.add(
      Marker(
        markerId: MarkerId('initialLocation'),
        position: _currentPosition,
        infoWindow: InfoWindow(title: 'Initial Location'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Map with GPS', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14.0,
            ),
            myLocationEnabled: false,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers,
          ),
        ],
      ),
    );
  }
}