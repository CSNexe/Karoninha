import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:karoninha/helper/gmap_functions.dart';
import 'package:karoninha/helper/helper_functions.dart';
import 'package:karoninha/mapStyleCustom.dart';
import 'package:karoninha/map_info.dart';
import 'package:karoninha/models/direction_details.dart';
import 'package:karoninha/screens/search_dropoff_locations_screen.dart';
import 'package:karoninha/widgets/user_drawer.dart';
import 'package:provider/provider.dart';

import '../manegeInfo/manage_info.dart';
import '../widgets/loading_dialog.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> controllerGMapCompleter = Completer<GoogleMapController>();
  GoogleMapController? controllerGMapInstance;
  double paddingFromBottomGMap = 0;
  Position? userLivePosition;

  BitmapDescriptor? customUserLocationIcon;
  Marker? userLocationMarker;

  Set<Marker> markerSet = {};

  bool drawerOpened = true;
    GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey<ScaffoldState>();

    HelperFunctions helperFunctions = HelperFunctions();

    double userLocationContainerHeight = 200;
    double carTypeContainerHeight = 0;

    DirectionDetails? directionDetailsForTrip;
    List<LatLng> polylineLatLng = [];
    Set<Polyline> pSet = {};
    Set<Circle> cSet = {};

  void loadCustomUserLocationIcon() {
    BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        "assets/images/img.png"
    ).then((icon){
      customUserLocationIcon = icon;
    });
  }

  updateUserMarkerOnMap() {
    LatLng userLatLng = LatLng(userLivePosition!.latitude, userLivePosition!.longitude);

    if (!markerSet.any((m) => m.markerId.value == "userLocation")) {

      markerSet.add(Marker(
        markerId: MarkerId("userLocation"),
        position: userLatLng,
        icon: customUserLocationIcon ?? BitmapDescriptor.defaultMarker,
      ));

      setState(() {});

    }
  }

  obtainUserLivePosition() async {

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("❌ Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      print("❌ Permission denied again.");
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      print("🚫 Permission permanently denied. Ask user to enable it from Settings.");
      await Geolocator.openAppSettings();
      return;
    }

    Position userCurrentPosition = await Geolocator.getCurrentPosition();
    userLivePosition = userCurrentPosition;

    LatLng latLngUserPosition = LatLng(userLivePosition!.latitude, userLivePosition!.longitude);

    CameraPosition cp = CameraPosition(target: latLngUserPosition, zoom: 16);

    controllerGMapInstance!.animateCamera(CameraUpdate.newCameraPosition(cp));

    await GMapFunctions.getHumanReadableAddressFromGeoGraphicCoOrdinates(userLivePosition!, context);
    updateUserMarkerOnMap();
  }

  carTypeDetailsContainer() {
    setState(() {
      userLocationContainerHeight = 0;
      carTypeContainerHeight = 266;
      drawerOpened = false;
    });

    fetchTripDirectionDetailsFromPickUpToDestination();
  }

  fetchTripDirectionDetailsFromPickUpToDestination() async {
    var pickUp = Provider.of<ManageInfo>(context, listen: false).pickUp;
    var dropOffDestination = Provider.of<ManageInfo>(context, listen: false).destinationDropOff;

    var pickupLatLng = LatLng(pickUp!.latPosition!, pickUp.lngPosition!);
    var dropOffDestinationLatLng = LatLng(dropOffDestination!.latPosition!, dropOffDestination.lngPosition!);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(),
    );

    var directionDetailsFromAPI =  await GMapFunctions.fetchDirectionDetailsFromAPI(pickupLatLng, dropOffDestinationLatLng);
    setState(() {
      directionDetailsForTrip = directionDetailsFromAPI;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints(apiKey: '');
    List<PointLatLng> latLngPolylinePoints = PolylinePoints.decodePolyline(directionDetailsForTrip!.encodedPointsForDrawingRoutes!);

    polylineLatLng.clear();
    if(latLngPolylinePoints.isNotEmpty) {
      latLngPolylinePoints.forEach((PointLatLng point){
        polylineLatLng.add(LatLng(point.latitude, point.longitude));
      });
    }

    print("polylineLatLng = " + polylineLatLng.toString());

    pSet.clear();
    setState(() {
      Polyline pLine = Polyline(
        polylineId: const PolylineId("pID"),
        color: Colors.white,
        points: polylineLatLng,
        jointType: JointType.round,
        width: 3,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      pSet.add(pLine);
    });

    //it will make sure that polyline is fit to the map
    LatLngBounds boundsLatLng;
    if(pickupLatLng.latitude > dropOffDestinationLatLng.latitude
        && pickupLatLng.longitude > dropOffDestinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: dropOffDestinationLatLng,
        northeast: pickupLatLng,
      );
    }
    else if(pickupLatLng.longitude > dropOffDestinationLatLng.longitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(pickupLatLng.latitude, dropOffDestinationLatLng.longitude),
        northeast: LatLng(dropOffDestinationLatLng.latitude, pickupLatLng.longitude),
      );
    }
    else if(pickupLatLng.latitude > dropOffDestinationLatLng.latitude)
    {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(dropOffDestinationLatLng.latitude, pickupLatLng.longitude),
        northeast: LatLng(pickupLatLng.latitude, dropOffDestinationLatLng.longitude),
      );
    }
    else
    {
      boundsLatLng = LatLngBounds(
        southwest: pickupLatLng,
        northeast: dropOffDestinationLatLng,
      );
    }

    controllerGMapInstance!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 72));

    Marker markerPickUpPoint = Marker(
      markerId: const MarkerId("ppMarkerID"),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: pickUp.placeName, snippet: "Pickup Point"),
    );

    Marker markerDropOffDestinationPoint = Marker(
      markerId: const MarkerId("dpMarkerID"),
      position: dropOffDestinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(title: dropOffDestination.placeName, snippet: "Destination Point"),
    );

    setState(() {
      markerSet.add(markerPickUpPoint);
      markerSet.add(markerDropOffDestinationPoint);
    });

    Circle circlePP = Circle(
      circleId: const CircleId('pCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 2,
      radius: 6,
      center: pickupLatLng,
      fillColor: Colors.white,
    );

    Circle circleDP = Circle(
      circleId: const CircleId('dCircleID'),
      strokeColor: Colors.blue,
      strokeWidth: 2,
      radius: 6,
      center: dropOffDestinationLatLng,
      fillColor: Colors.white,
    );

    setState(() {
      cSet.add(circlePP);
      cSet.add(circleDP);
    });
  }

  @override
  void initState() {
    super.initState();
    loadCustomUserLocationIcon();
    helperFunctions.retrieveUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldStateKey,
      drawer: UserDrawer(),
      body: Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(top: 27, bottom: paddingFromBottomGMap),
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            markers: markerSet,
            polylines: pSet,
            circles: cSet,
            initialCameraPosition: defaultLocation,
            style: mapStyleCustom,
            onMapCreated: (GoogleMapController mapControllerGoogle){
              controllerGMapInstance = mapControllerGoogle;
              controllerGMapCompleter.complete(controllerGMapInstance);

              setState(() {
                paddingFromBottomGMap = 302;
              });

              obtainUserLivePosition();
            },
          ),

          ///DRAWER ICON BUTTON
          Positioned(
            top: 38,
            left: 21,
            child: GestureDetector(
              onTap: (){
                if(drawerOpened == true){
                  scaffoldStateKey.currentState!.openDrawer();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        blurRadius: 6,
                        spreadRadius: 0.6,
                        offset: Offset(0.72, 0.72),
                      )
                    ]
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 21,
                  child: Icon(
                    color: Colors.white,
                    drawerOpened == true ? Icons.settings : Icons.close,
                  ),
                ),
              ),
            ),
          ),

          ///USER LOCATION CONTAINER
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: userLocationContainerHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(19),
                  topLeft: Radius.circular(19),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  children: [

                    const SizedBox(height: 11.0),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 17.0),

                    Row(
                      children: [

                        const Icon(Icons.location_history, color: Colors.white, size: 20),

                        const SizedBox(width: 12.0),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "My Live Location:",
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                Provider.of<ManageInfo>(context, listen: false).pickUp == null
                                    ? "fetching..."
                                    : Provider.of<ManageInfo>(context, listen: false).pickUp!.placeName ?? "",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 17.0),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey,
                    ),

                    const SizedBox(height: 17.0),

                    ElevatedButton(
                      onPressed: () async {
                        var dropOffLocResponse = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchDropOffLocationScreen()));

                        if(dropOffLocResponse == "destinationSelected") {
                          carTypeDetailsContainer();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        side: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      child: const Text(
                        "Ready to Go?",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),

          ///SELECT CAR TYPE CONTAINER
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: carTypeContainerHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white12,
                    blurRadius: 14.0,
                    spreadRadius: 0.4,
                    offset: Offset(.8, .8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [

                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey.shade400,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),

                          ///CARX
                          GestureDetector(
                            onTap: (){},
                            child: Column(
                              children: [

                                Container(
                                  width: 120,
                                  height: 50,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage("assets/images/uberx.png",),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                                Text("CarX", style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),),

                                SizedBox(height: 6,),

                                Text(
                                  directionDetailsForTrip != null ?
                                  "\$ " + helperFunctions.fareAmountCalculation(directionDetailsForTrip!, "CarX") : "fetching...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 2,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey.shade400,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),

                          ///CARXL
                          GestureDetector(
                            onTap: (){},
                            child: Column(
                              children: [

                                Container(
                                  width: 120,
                                  height: 50,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage("assets/images/uberxl.png",),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                                Text("CarXL", style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),),

                                SizedBox(height: 6,),

                                Text(
                                  directionDetailsForTrip != null ?
                                  "\$ " + helperFunctions.fareAmountCalculation(directionDetailsForTrip!, "CarXL") : "fetching...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 2,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey.shade400,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),

                          ///CARSUV
                          GestureDetector(
                            onTap: (){},
                            child: Column(
                              children: [

                                Container(
                                  width: 120,
                                  height: 50,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage("assets/images/uberSUV.png",),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                                Text("CarSUV", style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),),

                                SizedBox(height: 6,),

                                Text(
                                  directionDetailsForTrip != null ?
                                  "\$ " + helperFunctions.fareAmountCalculation(directionDetailsForTrip!, "CarSUV") : "fetching...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 2,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),

                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey.shade400,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),

                          ///SPORTSCAR
                          GestureDetector(
                            onTap: (){},
                            child: Column(
                              children: [

                                Container(
                                  width: 120,
                                  height: 50,
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: AssetImage("assets/images/sportscar.png",),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),

                                Text("SportsCar", style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),),

                                SizedBox(height: 6,),

                                Text(
                                  directionDetailsForTrip != null ?
                                  "\$ " + helperFunctions.fareAmountCalculation(directionDetailsForTrip!, "SportsCar") : "fetching...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 2,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              ],
                            ),
                          ),

                        ],
                      ),
                    ),

                    Divider(
                      thickness: 2,
                      color: Colors.grey,
                    ),

                    Text(
                      (directionDetailsForTrip != null) ? "Distance = ${directionDetailsForTrip!.distance}" : "fetching...",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Divider(
                      thickness: 2,
                      color: Colors.grey,
                    ),

                    Text(
                      (directionDetailsForTrip != null) ? "Duration = ${directionDetailsForTrip!.duration}" : "fetching...",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Divider(
                      thickness: 2,
                      color: Colors.grey,
                    ),

                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }


}
