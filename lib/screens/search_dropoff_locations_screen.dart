import 'package:flutter/material.dart';
import 'package:karoninha/helper/gmap_functions.dart';
import 'package:karoninha/manegeInfo/manage_info.dart';
import 'package:karoninha/map_info.dart';
import 'package:karoninha/models/predicted_places.dart';
import 'package:provider/provider.dart';

import '../widgets/predicted_places_design.dart';

class SearchDropOffLocationScreen extends StatefulWidget {
  const SearchDropOffLocationScreen({super.key});

  @override
  State<SearchDropOffLocationScreen> createState() => _SearchDropOffLocationScreenState();
}

class _SearchDropOffLocationScreenState extends State<SearchDropOffLocationScreen> {
  List<PredictedPlaces> predictedPlacesListForDestination = [];
  TextEditingController pickUpLocController = TextEditingController();
  TextEditingController dropOffLocController = TextEditingController();


  placesAutoCompleteSearch(String getUserInputText) async {
    String textInputByUser = getUserInputText;

    if(textInputByUser.length > 2){
      String urlPlacesAutoCompleteAPI = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$textInputByUser&key=$gMapKey&components=country:AE";
      var placesAPIResponseData = await GMapFunctions.requestAPI(urlPlacesAutoCompleteAPI);

      if(placesAPIResponseData == "error"){
        return;
      }

      if(placesAPIResponseData["status"] == "OK"){
        var jsonPredictedPlacesDataFromAPI = placesAPIResponseData["predictions"];
        var predictedPlacesDataFromAPI = (jsonPredictedPlacesDataFromAPI as List).map((predictedPlace) => PredictedPlaces.fromJson(predictedPlace)).toList();

        setState(() {
          predictedPlacesListForDestination = predictedPlacesDataFromAPI;
        });
      }
    }

  }



  @override
  Widget build(BuildContext context) {
    String userPickupAddress = Provider.of<ManageInfo>(context, listen: false).pickUp!.userAddressInReadableFormat ?? "";
    pickUpLocController.text = userPickupAddress;

    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: ListView(
        padding: EdgeInsets.zero,
        children: [

          Card(
            margin: EdgeInsets.zero,
            child: Container(
              height: 230,
              color: Colors.black,
              child: Padding(
                padding: EdgeInsets.only(left: 12, top: 46, right: 16, bottom: 14),
                child: Column(
                  children: [

                    SizedBox(height: 6),

                    Row(
                      children: [
                        Image.asset("assets/images/img.png", width: 40, height: 40,),
                        SizedBox(width: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: TextField(
                                controller: pickUpLocController,
                                enabled: false,
                                decoration: const InputDecoration(
                                  hintText: "Pickup Address",
                                  fillColor: Colors.white12,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    Stack(
                      children: [
                        GestureDetector(
                          onTap: ()=> Navigator.pop(context),
                          child: Image.asset("assets/images/back.png", width: 30, height: 30),
                        ),
                        Center(
                          child: Text(
                            "Search Drop-Off Location",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "MontserratBold",
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    Row(
                      children: [
                        Image.asset("assets/images/destinationmark.png", width: 40, height: 40,),
                        SizedBox(width: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: TextField(
                                controller: dropOffLocController,
                                onChanged: (getUserInputText) => placesAutoCompleteSearch(getUserInputText),
                                decoration: const InputDecoration(
                                  hintText: "search here...",
                                  fillColor: Colors.white12,
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(left: 11, top: 9, bottom: 9),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(height: 12,),
          
          predictedPlacesListForDestination.length > 0
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/choose.png", width: 50, height: 50),
                  SizedBox(width: 5),
                  Center(
                    child: Text(
                      "Choose",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
          )
          : Container(),

          SizedBox(height: 12,),

          if(predictedPlacesListForDestination.isNotEmpty)
            ...predictedPlacesListForDestination.map((prediction){
              return Card(
                color: Colors.black,
                child: PredictedPlacesDesign(predictedPlace: prediction),
              );
            }).toList(),
        ],
      ),
    );
  }
}