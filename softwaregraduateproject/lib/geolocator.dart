import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
class Geolocator1 extends StatefulWidget {
  const Geolocator1({super.key});

  @override
  State<Geolocator1> createState() => _State();
}

class _State extends State<Geolocator1> {
  StreamSubscription<Position>? positionStream;


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if(permission==LocationPermission.whileInUse){
      positionStream = Geolocator.getPositionStream().listen(
              (Position? position) {
            print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
          });
    }

  return await Geolocator.getCurrentPosition();
  }



  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
