import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_notifications/local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:region_app/custom_expansion_tile.dart' as custom;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: new ThemeData(
          primaryColor: Colors.lightGreen,
        ),
        home: new Homepage(),
        debugShowCheckedModeBanner: false,
    );
  }
}

class Homepage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //index = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Lists'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            EntryItem(data[index], context),
        itemCount: data.length,
      ),
      floatingActionButton: new FancyFab(
      ),
    );
  }
}

class NewTaskForm extends StatefulWidget {
  String taskLocation = '';
  @override
  State<StatefulWidget> createState() {
    NewTaskFormState temp = new NewTaskFormState();
    temp.taskLocation = this.taskLocation;
    return temp;
  }
}

class NewTaskFormState extends State<NewTaskForm> {
  Entry _location = null;
  final titleController = TextEditingController();
  Entry dropdownValue = null;
  String taskLocation = '';

  static const AndroidNotificationChannel channel = const AndroidNotificationChannel(
    id: 'default_notifications11',
    name: 'CustomNotificationChannel',
    description: 'Grant this app the ability to show notifications',
    importance: AndroidNotificationChannelImportance.HIGH,
    vibratePattern: AndroidVibratePatterns.DEFAULT,
  );

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }
  void removeNotify(String payload) async {
    LocalNotifications.removeNotification(0);
  }

  void handleNotificationDismiss(String payload) async {
    LocalNotifications.removeNotification(0);
  }

  void handleNotificationComplete(String payload) async {
    LocalNotifications.removeNotification(0);
  }

  @override
  Widget build(BuildContext context) {
    _location = Entry(taskLocation);

    return new Scaffold (
      appBar: AppBar(
        title: Text("Add a New Task"),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
              context,
              new MaterialPageRoute(builder: (context) => Homepage())
          );
        },
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
                    icon: const Icon(Icons.check_box),
                    labelText: 'Task Name:'
                ),
                controller: titleController,
                autofocus: true,
              ),
              new FormField(
                builder: (FormFieldState state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.location_on),
                      labelText: 'Location',
                    ),
                    isEmpty: _location.title == '',
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton<Entry>(
                        value: getEntry(),//Entry(taskLocation),
                        isDense: true,
                        //hint: const Text("Choose a location"),
                        onChanged: (Entry newValue) {
                          //_location = newValue;
                          setState(() {
                            _location = newValue;
                            taskLocation = newValue.title;
                            state.didChange(newValue);
                          });
                        },
                        items: data.map((Entry value) {
                          return new DropdownMenuItem(
                            value: value,
                            child: Text(value.title),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    //color: Colors.amber,
                      child: const Text("Cancel"),
                      onPressed: () async {
                        Navigator.pushReplacement(
                            context,
                            new MaterialPageRoute(builder: (context) => Homepage())
                        );
                      }
                  ),
                  SizedBox(width: 30.0),
                  RaisedButton(
                    color: Colors.lightGreen,
                    child: const Text("Save"),
                    onPressed: () async {
                      if (_location.title != '' && titleController.text != '') {
                        addTask();
                        await LocalNotifications
                            .createAndroidNotificationChannel(channel: channel);
                        await LocalNotifications.createNotification(
                            id: 0,
                            title: 'Region',
                            content: _location.title + ': ' + titleController.text,
                            androidSettings: new AndroidSettings(
                              isOngoing: false,
                              channel: channel,
                              priority: AndroidNotificationPriority.HIGH,
                            ),
                            onNotificationClick: new NotificationAction(
                                actionText: 'some action',
                                launchesApp: true
                            ),
                        );
                      }
                      else {
                        Fluttertoast.showToast(
                          msg: "Please complete all fields",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }

  getEntry() {
    for (int i = 0; i < data.length; ++i) {
      if (data[i].title == _location.title) {
        return data[i];
      }
    }
    return null;
  }

  addTask() {
    int index = 0;//data.indexOf(Entry(_location));
    for (int i = 0; i < data.length; ++i) {
      if (data[i].title == _location.title) {
        index = i;
        break;
      }
    }
    data[index].addChild(titleController.text);
    Navigator.pushReplacement(
        context,
        new MaterialPageRoute(builder: (context) => Homepage()));
  }
}

class EditTaskPage extends StatefulWidget {
  Entry entry;
  Entry location;
  @override
  State<StatefulWidget> createState() {
    EditTaskPageState temp =  new EditTaskPageState();
    temp.entry = this.entry;
    temp.location = location;
    return temp;
  }
}

class EditTaskPageState extends State<EditTaskPage> {
  Entry _location = null;
  Entry location;
  Entry entry;
  final titleController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    if (titleController.text == '') {
      titleController.text = entry.title;
    }
    return new WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(builder: (context) => Homepage())
        );
      },
      child: new Scaffold (
        appBar: AppBar(
          title: Text("Edit Task"),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  icon: const Icon(Icons.check_box),
                  labelText: 'Task Name:'
                ),
                autofocus: true,
                controller: titleController,
              ),
              new FormField(
                builder: (FormFieldState state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      icon: const Icon(Icons.location_on),
                      labelText: 'Location',
                    ),
                    isEmpty: location == '',
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton<Entry>(
                        value: location,
                        isDense: true,
                        hint: const Text("Choose a location"),
                        onChanged: (Entry newValue) {
                          setState(() {
                            location = newValue;
                            state.didChange(newValue);
                          });
                        },
                        items: data.map((Entry value) {
                          return new DropdownMenuItem(
                            value: value,
                            child: new Text(value.title),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    //color: Colors.amber,
                      child: const Text("Cancel"),
                      onPressed: () async {
                        Navigator.pushReplacement(
                            context,
                            new MaterialPageRoute(builder: (context) => Homepage())
                        );
                      }
                  ),
                  SizedBox(width: 30.0),
                  RaisedButton(
                    color: Colors.lightGreen,
                    child: const Text("Save"),
                    onPressed: () async {
                      addTask();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  addTask() {
    deleteTask();
    int index = data.indexOf(location);
    data[index].addChild(titleController.text);
    //Navigator.pop(context);
    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => Homepage()));
  }

  void deleteTask() {
    String task = entry.title;
    for (int i = 0; i < data.length; ++i) {
      for (int j = 0; j < data[i].children.length; ++j) {
        if (data[i].children[j].title == task) {
          data[i].children.removeAt(j);
          setState(() {

          });
          return;
        }
      }
    }
  }
}

class AddLocationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddLocationPageState();
  }
}

class AddLocationPageState extends State<AddLocationPage> {
  final locationController = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  String locationText = "";
  LatLng _center = new LatLng(40.2518, -111.6493);
  bool showToast = true;

  Set<Marker> _markers = {};

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onMarkerTapped() {
    Fluttertoast.showToast(
      msg: "Drag and Drop Pin",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      //backgroundColor: Colors.lightGreen,
      //textColor: Colors.white,
      fontSize: 20.0,
    );
    showToast = false;
  }

  void _cancelPressed() {
    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(builder: (context) => new Homepage()),
    );
  }

  void addLocation() {
    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(builder: (context) => new Homepage()),
    );
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      showToast = true;
      _markers = {};
      _markers.add(Marker(
        markerId: MarkerId(_center.toString()),
        draggable: true,
        consumeTapEvents: true,
        position: _center,
        onTap: _onMarkerTapped,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    });
  }

  void _onSavedPressed() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Location Name'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                      icon: const Icon(Icons.check_box),
                      labelText: 'Location Name:'
                  ),
                  onChanged: (value) {
                    locationText = value;
                  },
                )
              )
            ],
          ),
          actions: <Widget>[
            RaisedButton(
              color: Colors.lightGreen,
              textColor: Colors.white,
              child: const Text("Save"),
              onPressed: () {
                if (locationText.trim() != '') {
                  if (locationExists()) {
                    Fluttertoast.showToast(
                      msg: "Please enter new location name",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                  else {
                    data.add(Entry(locationText.trim(), <Entry>[Entry('Add Task')]));
                    markerData.putIfAbsent(locationText.trim(), () => _markers.elementAt(0));
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      new MaterialPageRoute(
                          builder: (context) => new Homepage()),
                    );
                  }
                }
                else {
                Fluttertoast.showToast(
                  msg: "Please enter location name",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool locationExists() {
    for (int i = 0; i < data.length; ++i) {
      if (data[i].title == locationText.trim()) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (showToast) {
      Fluttertoast.showToast(
        msg: "Drag and Drop Pin",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        //backgroundColor: Colors.lightGreen,
        //textColor: Colors.white,
        fontSize: 20.0,
      );
      showToast = false;
    }
    if (_markers.isEmpty) {
      _onAddMarkerButtonPressed();
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(builder: (context) => Homepage())
        );
      },
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            textTheme: TextTheme(
              title: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            title: Text('Add Location'),
            centerTitle: true,
            backgroundColor: Colors.lightGreen,
          ),
          body: Stack(
            children : <Widget> [
              GoogleMap(
                //gestureRecognizers: ,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                compassEnabled: true,
                onCameraMove: _onCameraMove,
                initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
                ),
                markers: _markers,
              ),
              Padding (
                padding: const EdgeInsets.all(16.0),
                child: Align (
                  alignment: Alignment.bottomRight,
                  child: Column(
                    children: <Widget>[
                      FloatingActionButton(
                        onPressed: _cancelPressed,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        backgroundColor: Colors.amber,
                        child: const Icon(Icons.clear),
                      ),
                      SizedBox(height: 16.0),
                      FloatingActionButton(
                        onPressed: _onAddMarkerButtonPressed,
                        backgroundColor: Colors.lightGreen,
                        child: const Icon(Icons.add_location),
                      ),
                      SizedBox(height: 16.0),
                      FloatingActionButton(
                        onPressed: _onSavedPressed,
                        backgroundColor: Colors.lightGreen,
                        child: const Icon(Icons.save),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditLocationPage extends StatefulWidget {
  String locationName;
  @override
  State<StatefulWidget> createState() {
    EditLocationPageState temp = new EditLocationPageState();
    temp.locationName = locationName;
    return temp;
  }
}

class EditLocationPageState extends State<EditLocationPage> {
  String locationName;
  final locationController = TextEditingController();
  Completer<GoogleMapController> _controller = Completer();
  String locationText = "";
  LatLng _center;
  bool showToast = true;
  TextEditingController editController;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    try {
      _center = markerData[locationName].position;
    }
    catch (e){
      _center = new LatLng(40.2518, -111.6493);
    }
    _markers.add(markerData[locationName]);
    locationText = locationName;
    editController = new TextEditingController(text: locationText);
  }

  void _onCameraMove(CameraPosition position) {
    _center = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onMarkerTapped() {
    Fluttertoast.showToast(
      msg: "Drag and Drop Pin",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      fontSize: 20.0,
    );
    showToast = false;
  }

  void _cancelPressed() {
    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(builder: (context) => new Homepage()),
    );
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      showToast = true;
      _markers = {};
      _markers.add(Marker(
        markerId: MarkerId(_center.toString()),
        draggable: true,
        consumeTapEvents: true,
        position: _center,
        onTap: _onMarkerTapped,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    });
  }

  void _onSavedPressed() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Location Name'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                    autofocus: true,
                    controller: editController,
                    decoration: InputDecoration(
                        icon: const Icon(Icons.check_box),
                        labelText: 'Location Name:'
                    ),
                    onChanged: (value) {
                      locationText = value;
                    },
                  )
              )
            ],
          ),
          actions: <Widget>[
            RaisedButton(
              color: Colors.lightGreen,
              textColor: Colors.white,
              child: const Text("Save"),
              onPressed: () {
                if (locationText.trim() != '') {
                  for (int i = 0; i < data.length; ++i) {
                    if(data[i].title == locationName) {
                      data[i].title = locationText.trim();
                    }
                  }
                  markerData.remove(locationName);
                  markerData.putIfAbsent(locationText.trim(), () => _markers.elementAt(0));
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new Homepage()),
                  );
                }
                else {
                  Fluttertoast.showToast(
                    msg: "Please enter location name",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  bool locationExists() {
    for (int i = 0; i < data.length; ++i) {
      if (data[i].title == locationText.trim()) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (showToast) {
      Fluttertoast.showToast(
        msg: "Drag and Drop Pin",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        //backgroundColor: Colors.lightGreen,
        //textColor: Colors.white,
        fontSize: 20.0,
      );
      showToast = false;
    }
    if (_markers.isEmpty) {
      _onAddMarkerButtonPressed();
    }
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context,
            new MaterialPageRoute(builder: (context) => Homepage())
        );
      },
      child: new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            textTheme: TextTheme(
              title: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            title: Text('Edit Location: ' + locationName),
            centerTitle: true,
            backgroundColor: Colors.lightGreen,
          ),
          body: Stack(
            children : <Widget> [
              GoogleMap(
                //gestureRecognizers: ,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                compassEnabled: true,
                onCameraMove: _onCameraMove,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 16.0,
                ),
                markers: _markers,
              ),
              Padding (
                padding: const EdgeInsets.all(16.0),
                child: Align (
                  alignment: Alignment.bottomRight,
                  child: Column(
                    children: <Widget>[
                      FloatingActionButton(
                        onPressed: _cancelPressed,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        backgroundColor: Colors.amber,
                        child: const Icon(Icons.clear),
                      ),
                      SizedBox(height: 16.0),
                      FloatingActionButton(
                        onPressed: _onAddMarkerButtonPressed,
                        backgroundColor: Colors.lightGreen,
                        child: const Icon(Icons.add_location),
                      ),
                      SizedBox(height: 16.0),
                      FloatingActionButton(
                        onPressed: _onSavedPressed,
                        backgroundColor: Colors.lightGreen,
                        child: const Icon(Icons.save),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// One entry in the multilevel list displayed by this app.
class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);
  String title;
  final List<Entry> children;
  bool isComplete = false;
  addChild(String _title) {
    children.add(new Entry(_title));
  }
}

// The entire multilevel list displayed by this app.
List<Entry> data = <Entry>[
  Entry(
    'Home',
    <Entry>[
      Entry('Add Task'),
      Entry('Take out trash',),
      Entry('Put letter in mail'),
      Entry('Call mom'),
    ],
  ),
  Entry(
    'School',
    <Entry>[
      Entry('Add Task'),
      Entry('Print sunday school lesson'),
      Entry('Ask 356 TA about requirements'),
    ],
  ),
  Entry(
    'Work',
    <Entry>[
      Entry('Add Task'),
      Entry('Check for missing water bottle in confrence room'),
      Entry('Ask Sam for resturant recomendations'),
      Entry('Sticky Notes'),
    ],
  ),
];

// Displays one Entry. If the entry has children then it's displayed
// with an ExpansionTile.

Map<String, Marker> markerData = {};

class EntryItem extends StatefulWidget {
  final Entry entry;
  final BuildContext context;

  const EntryItem(this.entry, this.context);

  @override
  State<StatefulWidget> createState() {
    EntryItemState temp = new EntryItemState(this.entry, this.context);
    return temp;
  }

}

class EntryItemState extends State<EntryItem> {
  EntryItemState(this.entry, this.context);
  final Entry entry;
  final BuildContext context;
  int currIndex = 0;
  String latestLocation = '';


  void deleteTask(String task) {
    for (int i = 0; i < data.length; ++i) {
      for (int j = 0; j < data[i].children.length; ++j) {
        if (data[i].children[j].title == task) {
          data[i].children.removeAt(j);
          setState(() {

          });
          return;
        }
      }
    }
  }

  void deleteLocation(String locationName) {
    for (int i = 0; i < data.length; ++i) {
      if (data[i].title == locationName) {
        data.removeAt(i);
        break;
      }
    }
    markerData.remove(locationName);
    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        new MaterialPageRoute(
            builder: (context) => new Homepage()
        )
    );
  }

  void editLocationDialog(String locationName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Location: ' + locationName),
          content: Text(
            'Warning: Deleting location will delete all associated tasks',
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.redAccent,
              child: Text("Delete",
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () => deleteLocation(locationName)
            ),
            FlatButton(
              textColor: Colors.blueAccent,
              child: Text(
                "Edit",
                style: TextStyle(fontSize: 20.0),
              ),
              onPressed: () {
                Navigator.pop(context);
                EditLocationPage temp = new EditLocationPage();
                temp.locationName = locationName;
                Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => temp
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void editPressed(Entry entry, Entry location) {
    EditTaskPage temp = new EditTaskPage();
    temp.entry = entry;
    temp.location = location;
    Navigator.pushReplacement(
      context,
      new MaterialPageRoute(builder: (context) => temp),
    );
  }

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) {
      //this.currIndex = index;
      if (root.title == "Add Task") {
        return ListTile(
          selected: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 30.0),
          trailing: Icon(Icons.add),
          title: Text(root.title),
          onTap: () async {
            NewTaskForm temp = new NewTaskForm();
            temp.taskLocation = latestLocation;
            Navigator.pushReplacement(
              context,
              new MaterialPageRoute(builder: (context) => temp),
            );
          }
        );
      }
      return new Slidable(
        delegate: new SlidableDrawerDelegate(),
        actionExtentRatio: 0.25,
        child: new Container(
          color: Colors.white,
          child: new CheckboxListTile(
            value: root.isComplete,
            activeColor: Colors.amber,
            onChanged: (value) {
              setState(() {
                root.isComplete = value;
              });
            },
            title: Text(root.title),

          ),
        ),
        actions: <Widget>[
          new IconSlideAction(
            caption: 'Edit',
            color: Colors.blueAccent,
            icon: Icons.edit,
            onTap: () => editPressed(root, entry),
          )
        ],
        secondaryActions: <Widget>[
          new IconSlideAction(
            caption: 'Delete',
            color: Colors.redAccent,
            icon: Icons.delete,
            onTap: () => deleteTask(root.title),
          ),
        ],
      );
    }
    latestLocation = root.title;
    return GestureDetector(
      onLongPress: () => editLocationDialog(root.title),
      child: new custom.ExpansionTile(
        iconColor: Colors.black,
        headerBackgroundColor: Colors.white10,
        key: PageStorageKey<Entry>(root),
        title: Container(
          child: Text(
            root.title,
            style: TextStyle(
              color: Colors.black,
            ),
          ),

        ),
        children: root.children.map(_buildTiles).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;

  FancyFab({this.onPressed, this.tooltip, this.icon});

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab> with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: Colors.lightGreen,
      end: Colors.amber,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(builder: (context) => new NewTaskForm()),
          );
        },
        tooltip: 'Add',
        child: Icon(Icons.add_box),
      ),
    );
  }

  Widget add_location() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Colors.lightGreen,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            new MaterialPageRoute(builder: (context) => new AddLocationPage()),
          );
        },
        tooltip: 'Add Location',
        //heroTag: 'Add Location',
        child: Icon(Icons.add_location),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          icon: AnimatedIcons.menu_close,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: add(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: add_location(),
        ),
        toggle(),
      ],
    );
  }
}

void main() {
  markerData.putIfAbsent(
    "Home",
      () => new Marker(
      markerId: MarkerId("Home"),
      draggable: true,
      consumeTapEvents: true,
      position: new LatLng(40.259561, -111.659033),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    )
  );
  markerData.putIfAbsent(
    "Work",
      () => new Marker(
      markerId: MarkerId("Work"),
      draggable: true,
      consumeTapEvents: true,
      position: new LatLng(40.303349, -111.663896),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    )
  );
  markerData.putIfAbsent(
    "School",
      () => new Marker(
      markerId: MarkerId("School"),
      draggable: true,
      consumeTapEvents: true,
      position: new LatLng(40.2518, -111.6493),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    )
  );

  runApp(MyApp());
}
