import 'dart:convert';

Location locationFromJson(String str) {
  final jsonData = json.decode(str);
  return Location.fromJson(jsonData);
}

String locationToJson(Location data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class Location {
  String locationName;
  double longitude;
  double latitude;

  Location({
    this.locationName,
    this.longitude,
    this.latitude,
  });

  factory Location.fromJson(Map<String, dynamic> json){
    return Location(
      locationName: json["location_name"],
      longitude: json["longitude"],
      latitude: json["latitude"],
    );
  }

  Map<String, dynamic> toJson(){
    return ({
      "location_name": locationName,
      "longitude": longitude,
      "latitude": latitude,
    });
  }
}