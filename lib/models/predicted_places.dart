class PredictedPlaces {
  String? mainText;
  String? secondaryText;
  String? placeId;

  PredictedPlaces({
    this.mainText,
    this.secondaryText,
    this.placeId,
  });


  PredictedPlaces.fromJson(Map<String, dynamic> jsonData){
    mainText = jsonData["structured_formatting"]["main_text"];
    secondaryText = jsonData["structured_formatting"]["secondary_text"];
    placeId = jsonData["place_id"];
  }

}