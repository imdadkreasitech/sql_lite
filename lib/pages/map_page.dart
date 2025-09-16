import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location _locationC = Location();
  LatLng? _currentLocation;
  static const LatLng _pGooglePlex = LatLng(
    37.42796133580664,
    -122.085749655962,
  );
  static const LatLng _pApplePark = LatLng(
    37.33465721009499,
    -122.008964625081,
  );

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _currentLocation == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController.complete(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: _pGooglePlex,
                  zoom: 14.4746,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    position: _currentLocation!,
                    infoWindow: InfoWindow(
                      title: 'Current Location',
                      snippet: 'You are here',
                    ),
                  ),
                  Marker(
                    markerId: MarkerId('_sourceLocation'),
                    position: _pGooglePlex,
                    infoWindow: InfoWindow(
                      title: 'Google Plex',
                      snippet: 'Google Headquarters',
                    ),
                  ),
                  Marker(
                    markerId: MarkerId('_destinationLocation'),
                    position: _pApplePark,
                    infoWindow: InfoWindow(
                      title: 'Tugu Jogja',
                      snippet: 'Iconic Landmark of Yogyakarta',
                    ),
                  ),
                },
              ),
    );
  }

  @override
  void initState() {
    super.initState();
    getLocationUpdates().then((_) => getPolylinePoints());
  }

  Future<void> _cameraMove(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition position = CameraPosition(target: pos, zoom: 14.4746);

    await controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationC.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationC.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationC.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationC.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationC.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentLocation = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
          _cameraMove(_currentLocation!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints(
      apiKey: "AIzaSyAWNvFDBY9lqeLCRLYR6j9kv4cJc0Zh9UA",
    );
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(_pGooglePlex.latitude, _pGooglePlex.longitude),
        destination: PointLatLng(_pApplePark.latitude, _pApplePark.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      polylineCoordinates =
          result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
    }
    return polylineCoordinates;
  }
}
