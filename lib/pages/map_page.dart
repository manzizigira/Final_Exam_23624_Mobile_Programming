import 'dart:async';
import 'dart:math' as math;
import 'package:calculatorapp/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class GoogleMapPage extends StatefulWidget {
  const GoogleMapPage({super.key});

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  final locationController = Location();
  static const googlePlex = LatLng(37.4223, -122.0848);
  static const mountainView = LatLng(37.3861, -122.0839);
  LatLng? currentPosition;
  LatLng? previousPosition;
  Map<PolylineId, Polyline> polylines = {};
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  StreamSubscription<LocationData>? locationSubscription;

  bool insidePredefinedArea = false;
  bool outsidePredefinedArea = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await initializeMap());
    initializeNotifications();
    requestPermissions();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeMap() async {
    await fetchLocationUpdates();
    final coordinates = await fetchPolylinePoints();
    generatePolylineFromPoints(coordinates);
  }

  void initializeNotifications() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      // Handle notification tap
    });

    const androidNotificationChannel = AndroidNotificationChannel(
      'geofence_channel',
      'Geofence Notifications',
      description: 'This channel is used for geofence notifications',
      importance: Importance.max,
    );

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<void> requestPermissions() async {
    final PermissionStatus permission =
        await locationController.requestPermission();
    if (permission != PermissionStatus.granted) {
      // Handle permission not granted
      return;
    }

    final bool serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      final bool serviceRequested = await locationController.requestService();
      if (!serviceRequested) {
        // Handle service not enabled
        return;
      }
    }

    if (await locationController.hasPermission() ==
        PermissionStatus.deniedForever) {
      // Handle denied forever
      return;
    }

    // Check background location permission for Android 10+
    if (await locationController.hasPermission() != PermissionStatus.granted) {
      final PermissionStatus backgroundPermission =
          await locationController.requestPermission();
      if (backgroundPermission != PermissionStatus.granted) {
        // Handle background permission not granted
        return;
      }
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Geofencing'),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        body: currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: googlePlex,
                  zoom: 13,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('currentLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: currentPosition!,
                  ),
                  const Marker(
                    markerId: MarkerId('sourceLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: googlePlex,
                  ),
                  const Marker(
                    markerId: MarkerId('destinationLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: mountainView,
                  ),
                },
                polylines: Set<Polyline>.of(polylines.values),
              ),
      );

  Future<void> fetchLocationUpdates() async {
    locationSubscription =
        locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        previousPosition = currentPosition;
        if (mounted) {
          setState(() {
            currentPosition =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
          });

          // Debug prints
          print('Previous Position: $previousPosition');
          print('Current Position: $currentPosition');

          // Only check geofence if the position changes significantly
          if (previousPosition == null ||
              calculateDistance(previousPosition!, currentPosition!) > 10) {
            checkGeofence(currentPosition!);
            checkIfExitedPredefinedArea(currentPosition!);
          }
        }
      }
    });
  }

  void checkGeofence(LatLng currentPosition) {
    const predefinedAreaCenter = googlePlex;
    const predefinedAreaRadius = 500.0; // Radius in meters

    final isInside = calculateDistance(currentPosition, predefinedAreaCenter) <
        predefinedAreaRadius;

    // Debug print
    print('Current Position: $currentPosition');
    print(
        'Distance to predefined center: ${calculateDistance(currentPosition, predefinedAreaCenter)}');
    print('Is inside predefined area: $isInside');

    if (isInside && !insidePredefinedArea) {
      insidePredefinedArea = true;
      _showNotification(
          'Geofence Alert', 'You have entered the predefined area');
    }
    if (!isInside && insidePredefinedArea) {
      insidePredefinedArea = false;
    }
  }

  void checkIfExitedPredefinedArea(LatLng currentPosition) {
    const predefinedAreaCenter = mountainView;
    const predefinedAreaRadius = 20.0; // Radius in meters

    final isOutside = calculateDistance(currentPosition, predefinedAreaCenter) >
        predefinedAreaRadius;

    // Check if the user has reached the destination (mountainView)
    final hasReachedDestination =
        calculateDistance(currentPosition, predefinedAreaCenter) <
            predefinedAreaRadius;

    // Debug print
    print('Current Position: $currentPosition');
    print(
        'Distance to predefined center: ${calculateDistance(currentPosition, predefinedAreaCenter)}');
    print('Is outside predefined area: $isOutside');

    if (isOutside && !outsidePredefinedArea) {
      outsidePredefinedArea = true;
      _showNotification(
          'Geofence Alert', 'You have exited the predefined area');
    }
    if (!isOutside && outsidePredefinedArea) {
      outsidePredefinedArea = false;
    }

    // Trigger notification if the user has reached the destination
    if (hasReachedDestination && !outsidePredefinedArea) {
      outsidePredefinedArea = true;
      _showNotification(
          'Geofence Alert', 'You have exited the predefined area');
    }
  }

  double calculateDistance(LatLng start, LatLng end) {
    const earthRadius = 6371000; // Earth's radius in meters
    final dLat = (end.latitude - start.latitude) * (math.pi / 180.0);
    final dLon = (end.longitude - start.longitude) * (math.pi / 180.0);
    final lat1 = start.latitude * (math.pi / 180.0);
    final lat2 = end.latitude * (math.pi / 180.0);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(lat1) *
            math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  Future<List<LatLng>> fetchPolylinePoints() async {
    final polylinePoints = PolylinePoints();
    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleMapsApiKey,
      PointLatLng(googlePlex.latitude, googlePlex.longitude),
      PointLatLng(mountainView.latitude, mountainView.longitude),
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generatePolylineFromPoints(
      List<LatLng> polylineCoordinates) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );

    setState(() => polylines[id] = polyline);
  }
}
