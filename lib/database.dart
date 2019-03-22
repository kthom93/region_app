import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:region_app/locationModel.dart';
import 'package:region_app/taskModel.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return database;
    }

    _database = await initDB();

    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "DB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Tasks ("
          "task_name TEXT PRIMARY KEY,"
          "location_name TEXT FOREIGN KEY,"
          "completed INTEGER,"
          ")");
      await db.execute("CREATE TABLE Locations ("
          "location_name TEXT PRIMARY KEY,"
          "longitude REAL,"
          "latitude REAL,"
          ")");
    });
  }

  newTask(Task newTask) async {
    final db = await database;
    var res = await db.insert("Tasks", newTask.toJson());
    return res;
  }

  newLocation(Location newLocation) async {
    final db = await database;
    var res = await db.insert("Locations", newLocation.toJson());
    return res;
  }

  getAllTasks () async {
    final db = await database;
    var res = await db.query("Tasks");
    List<Task> list = res.isNotEmpty ? res.map((c) => Task.fromJson(c)).toList() : [];
    return list;
  }

  getTask (taskName) async {
    final db = await database;
    var res = await db.query("Tasks", where: "task_name = ?", whereArgs: [taskName]);
    return res.isNotEmpty ? Task.fromJson(res.first) : Null;
  }

  getTasksWithLocation (locationName) async {
    final db = await database;
    var res = await db.query("Tasks", where: "location_name = ?", whereArgs: [locationName]);
    return res.isNotEmpty ? Task.fromJson(res.first) : Null;
  }

  getAllLocation() async {
    final db = await database;
    var res = await db.query("Locations");
    List<Location> list = res.isNotEmpty ? res.map((c) => Location.fromJson(c)).toList() : [];
    return list;
  }

  getLocation (String locationName) async {
    final db = await database;
    var res = await db.query("Locations", where: "location_name = ?", whereArgs: [locationName]);
    return res.isNotEmpty ? Location.fromJson(res.first) : Null;
  }

  updateTask(Task newTask) async {
    final db = await database;
    var res = await db.update("Tasks", newTask.toJson(), where: "task_name = ?", whereArgs: [newTask.taskName]);
    return res;
  }

  updateLocation(Location newLocation) async {
    final db = await database;
    var res = await db.update("Locations", newLocation.toJson(), where: "location_name = ?", whereArgs: [newLocation.locationName]);
    return res;
  }

  deleteTask(String taskName) async {
    final db = await database;
    var res = await db.delete("Tasks", where: "task_name = ?", whereArgs: [taskName]);
  }

  deleteLocation(String locationName) async {
    final db = await database;
    db.delete("Locations", where: "location_name = ?", whereArgs: [locationName]);
  }

  deleteAllTasks() async {
    final db = await database;
    db.rawDelete("Delete * from Tasks");
  }

  deleteAllLocations() async {
    final db = await database;
    db.rawDelete("Delete * from Locations");
  }

}