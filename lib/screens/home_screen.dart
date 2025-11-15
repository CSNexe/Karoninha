import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:karoninha/mapStyleCustom.dart';
import 'package:karoninha/map_info.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> controllerGMap = Completer<GoogleMapController>();
  GoogleMapController? controllerGMapInstance;
  double paddingFromBottomGMap = 0;
  Position? userLivePosition;

  BitmapDescriptor? customUserLocationIcon;
  Marker? userLocationMarker;

  Set<Marker> markerSet = {};



  void loadCustomUserLocationIcon() {
    BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      "assets/images/img.png",
    ).then((icon) {
      customUserLocationIcon = icon;
    });
  }

  updateUserMarkerOnMpa(){
    LatLng userLatLng = LatLng(userLivePosition!.latitude, userLivePosition!.longitude);

    if (!markerSet.any((m)=> m.markerId.value == "userlocation")){

      markerSet.add(
        Marker(
          markerId: MarkerId("userlocation"),
          position: userLatLng,
          icon: customUserLocationIcon ?? BitmapDescriptor.defaultMarker,
        )
      );

      setState(() {});

    }
  }

  obtainGMapController() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      print("Permissions denied again.");
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permissions permanently denied.");
      await Geolocator.openAppSettings();
      return;
    }

    Position userCurrentPosition = await Geolocator.getCurrentPosition();
    userLivePosition = userCurrentPosition;
    LatLng latLngPosition = LatLng(userLivePosition!.latitude, userLivePosition!.longitude);

    CameraPosition cp = CameraPosition(target: latLngPosition, zoom: 16);

    controllerGMapInstance!.animateCamera(CameraUpdate.newCameraPosition(cp));

    updateUserMarkerOnMpa();

  }

  @override
  void initState() {
    super.initState();
    loadCustomUserLocationIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(top: 27, bottom: paddingFromBottomGMap),
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            markers: markerSet,
            initialCameraPosition: defaultLocation,
            style: mapStyleCustom,
            onMapCreated: (GoogleMapController mapControllerGoogle){
              controllerGMapInstance = mapControllerGoogle;
              controllerGMap.complete(mapControllerGoogle);

              setState(() {
                paddingFromBottomGMap = 302;
              });
            },
          ),

        ],
      ),
    );
  }
}
