import 'dart:convert';

//Location locationFromJson(String str) {
//  final jsonData = json.decode(str);
//  return Location.fromJson(jsonData);
//}
//
//String locationToJson(Location data) {
//  final dyn = data.toJson();
//  return json.encode(dyn);
//}
//
class LocationData {
  String locationName;
  double latitude;
  double longitude;

  LocationData(locationName, latitude, longitude) {
    this.locationName = locationName;
    this.latitude = latitude;
    this.longitude = longitude;
  }

//  factory Location.fromJson(Map<String, dynamic> json){
//    return Location(
//      locationName: json["location_name"],
//      longitude: json["longitude"],
//      latitude: json["latitude"],
//    );
//  }
//
//  Map<String, dynamic> toJson(){
//    return ({
//      "location_name": locationName,
//      "longitude": longitude,
//      "latitude": latitude,
//    });
//  }
}