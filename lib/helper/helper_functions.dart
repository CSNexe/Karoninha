import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:karoninha/models/direction_details.dart';

import '../user_info.dart';
import '../widgets/snackbar.dart';

class HelperFunctions{

  retrieveUserData(BuildContext context) async {
    DatabaseReference usersReference = FirebaseDatabase.instance.ref().child("allUsers").child(FirebaseAuth.instance.currentUser!.uid);

    await usersReference.once().then((onValue){
      if(onValue.snapshot.value != null){
        nameOfUser = (onValue.snapshot.value as Map)["name"];
        phoneOfUser = (onValue.snapshot.value as Map)["phone"];
        emailOfUser = (onValue.snapshot.value as Map)["email"];
      } else {
        displaySnackBar("your record not found.", context);
      }
    });
  }

  fareAmountCalculation(DirectionDetails directionDetails, String carType) {
    double perKmCharges = 0.8;
    double perMinuteCharges = 0.5;
    double baseFareCharges = 2.5;

    double traveledDistanceFareAmount = (directionDetails.distanceValue! / 1000) * perKmCharges;
    double durationSpendFareAmount = (directionDetails.durationValue! / 60) * perMinuteCharges;

    if(carType == "CarX") {
      double totalFareAmount = (traveledDistanceFareAmount + durationSpendFareAmount + baseFareCharges);
      return totalFareAmount.toStringAsFixed(1);
    } else if(carType == "CarXL") {
      double totalFareAmount = (traveledDistanceFareAmount + durationSpendFareAmount + baseFareCharges) * 2;
      return totalFareAmount.toStringAsFixed(1);
    } else if(carType == "CarSUV") {
      double totalFareAmount = (traveledDistanceFareAmount + durationSpendFareAmount + baseFareCharges) * 3;
      return totalFareAmount.toStringAsFixed(1);
    } else if(carType == "SportsCar") {
      double totalFareAmount = (traveledDistanceFareAmount + durationSpendFareAmount + baseFareCharges) * 5;
      return totalFareAmount.toStringAsFixed(1);
    }
  }

}