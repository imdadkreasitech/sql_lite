import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LiveLocationPage extends StatefulWidget {
  @override
  _LiveLocationPageState createState() => _LiveLocationPageState();
}

class _LiveLocationPageState extends State<LiveLocationPage> {
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndStart();
  }

  Future<void> _checkPermissionAndStart() async {
    // Check permission first
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requestedPermission = await Geolocator.requestPermission();
      if (requestedPermission != LocationPermission.whileInUse &&
          requestedPermission != LocationPermission.always) {
        return; // Permission not granted
      }
    }

    _startListening();
  }

  void _startListening() {
    final locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // ✅ Parameter yang benar
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        setState(() {
          _currentPosition = position;
        });
      },
      onError: (error) {
        print('Error in location stream: $error');
      },
    );
  }

  void _stopListening() {
    _positionStream?.cancel();
    setState(() {
      _positionStream = null;
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Live Location')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentPosition != null)
              Column(
                children: [
                  Text('Latitude: ${_currentPosition!.latitude}'),
                  Text(
                    'Longitude: ${_currentPosition!.longitude}',
                  ), // ✅ Fixed missing $
                  Text(
                    'Accuracy: ${_currentPosition!.accuracy?.toStringAsFixed(2)} m',
                  ),
                  Text(
                    'Speed: ${_currentPosition!.speed?.toStringAsFixed(2)} m/s',
                  ),
                ],
              )
            else
              Text('Menunggu lokasi...'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _positionStream == null
                      ? _checkPermissionAndStart
                      : _stopListening,
              child: Text(
                _positionStream == null ? 'Start Tracking' : 'Stop Tracking',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
