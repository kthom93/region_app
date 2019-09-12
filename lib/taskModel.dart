//import 'dart:convert';
//
//Task taskFromJson(String str) {
//  final jsonData = json.decode(str);
//  return Task.fromJson(jsonData);
//}
//
//String taskToJson(Task data) {
//  final dyn = data.toJson();
//  return json.encode(dyn);
//}
//
//class Task {
//  String taskName;
//  String locationName;
//  int completed;
//
//  Task({
//    this.taskName,
//    this.locationName,
//    this.completed,
//  });
//
//  factory Task.fromJson(Map<String, dynamic> json) {
//    return Task(
//      taskName: json["task_name"],
//      locationName: json["location_name"],
//      completed: json["completed"],
//    );
//  }
//
//  Map<String, dynamic> toJson() {
//    return ({
//      "task_name": taskName,
//      "location_name": locationName,
//      "completed": completed,
//    });
//  }
//}