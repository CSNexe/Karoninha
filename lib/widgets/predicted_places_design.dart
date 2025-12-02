import 'package:flutter/material.dart';
import 'package:karoninha/manegeInfo/manage_info.dart';
import 'package:karoninha/models/address.dart';
import 'package:karoninha/models/predicted_places.dart';
import 'package:karoninha/widgets/loading_dialog.dart';
import 'package:provider/provider.dart';

import '../helper/gmap_functions.dart';
import '../map_info.dart';


class PredictedPlacesDesign extends StatefulWidget {
  PredictedPlaces predictedPlace;
  PredictedPlacesDesign({super.key, required this.predictedPlace,});

  @override
  State<PredictedPlacesDesign> createState() => _PredictedPlacesDesignState();
}

class _PredictedPlacesDesignState extends State<PredictedPlacesDesign> {

  retrievePlaceDetails(String destinationPlaceID) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => LoadingDialog(),
    );

    String placeDetailsAPIUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$destinationPlaceID&key=$gMapKey";
    var placeDetailsAPIResponseData = await GMapFunctions.requestAPI(placeDetailsAPIUrl);

    Navigator.pop(context);

    if(placeDetailsAPIResponseData == "error")
    {
      return;
    }

    if(placeDetailsAPIResponseData["status"] == "OK")
    {
      Address address = Address();
      address.placeName = placeDetailsAPIResponseData["result"]["name"];
      address.latPosition = placeDetailsAPIResponseData["result"]["geometry"]["location"]["lat"];
      address.lngPosition = placeDetailsAPIResponseData["result"]["geometry"]["location"]["lng"];
      address.placeID = destinationPlaceID;

      Provider.of<ManageInfo>(context, listen: false).updateDestinationDropOffAddress(address);

      Navigator.pop(context, "destinationSelected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        retrievePlaceDetails(widget.predictedPlace.placeId.toString());
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
      ),
      child: Column(
        children: [

          SizedBox(height: 12,),

          Row(
            children: [
              Image.asset("assets/images/search.png", width: 35, height: 35,),

              SizedBox(width: 13,),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.predictedPlace.mainText.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),

                    SizedBox(height: 3,),

                    Text(
                      widget.predictedPlace.secondaryText.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 12,),

        ],
      ),
    );
  }
}