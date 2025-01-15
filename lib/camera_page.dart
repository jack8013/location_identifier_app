import 'package:camera/camera.dart';
import 'package:mountain_app/main.dart';
import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'dart:async';
import 'package:flutter/services.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final List<double> matrix;
  CameraPage({
    super.key,
    this.cameras,
    required this.matrix,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final String CHANNEL = "com.example.mountain_app/focalLength";
  late final MethodChannel _channel = MethodChannel(CHANNEL);
  late CameraController controller;
  XFile? image;

  bool servicestatus = false;
  bool haspermission = false;
  String long = "", lat = "";
  double geoheading = 0.0;
  late final matrix = getOrientedRotationMatrix();
  late final coords = getPixelCoords();

  String altitude = "";
  double altitude2 = 0.0;

  late Timer _timer;
  List<double> _matrix = [];
  List<double> _coords = [10.0, 10.0];
  List<Point> _pixelPoints = [];
  List<Point> closestPoints = [];
  double maxDistance = 25.0;
  bool showAllPoints = true;
  late Future<double> latJava;

  int permissionCheckCount = 0;
  @override
  void initState() {
    super.initState();
    checkPerms();
    _timer = Timer.periodic(const Duration(milliseconds: 500), _updateMatrix);
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      try {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              debugPrint('User denied camera access.');
              break;
            default:
              debugPrint('Handle other errors.');
              break;
          }
        }
      } catch (error) {
        debugPrint('Error while handling camera initialization error: $error');
      }
    });
    getCameraIntrinsicParams(cameras.first.name);
    latJava = getLatitude();
  }

  @override
  void dispose() {
    controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    startSensor();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    getLocation(width, height);
    if (!controller.value.isInitialized) {
      return const SizedBox(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset localPosition = box.globalToLocal(details.globalPosition);
        setState(() {
          _coords = [localPosition.dx, localPosition.dy];
        });
      },
      child: Scaffold(
        body: Stack(
          children: [
            CameraPreview(controller),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  margin: const EdgeInsets.all(15.0),
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Latitude: $lat',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Longitude: $long',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Altitude: ${altitude2.toStringAsFixed(1)}',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final selectedDistance = await showDialog<double>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Visibility'),
                                  content: StatefulBuilder(builder:
                                      (BuildContext context,
                                          StateSetter setState) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CheckboxListTile(
                                          title: const Text(
                                              'Show Peaks With No Elevation Info'),
                                          value: showAllPoints,
                                          onChanged: (value) {
                                            setState(() {
                                              showAllPoints = value!;
                                            });
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Low (25km)'),
                                          onTap: () {
                                            Navigator.of(context).pop(25.0);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('Medium (50km)'),
                                          onTap: () {
                                            Navigator.of(context).pop(50.0);
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('High (100km)'),
                                          onTap: () {
                                            Navigator.of(context).pop(100.0);
                                          },
                                        ),
                                      ],
                                    );
                                  }),
                                );
                              },
                            );
                            if (selectedDistance != null) {
                              setState(() {
                                maxDistance = selectedDistance;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.settings),
                              const SizedBox(width: 4.0),
                              Text(
                                'Current visibility: $maxDistance km',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: _pixelPoints
                      .where(
                    (point) =>
                        point.x != 0 &&
                        point.y != 0 &&
                        point.x >= 0 &&
                        point.x <= width &&
                        point.y >= 0 &&
                        point.y <= height &&
                        point.dist <= maxDistance &&
                        (showAllPoints || point.ele != 0),
                  )
                      .map(
                    (point) {
                      if (point.ele != 0) {
                        return Text(
                          "${point.name}(${point.ele}m): Distance ${point.dist} km",
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        return Text("${point.name}: Distance ${point.dist} km",
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                            )); // Return an empty container for points with elevation 0
                      }
                    },
                  ).toList(),
                ),
              ),
            ),
            ..._pixelPoints
                .where(
                  (point) =>
                      point.x != 0 &&
                      point.y != 0 &&
                      point.x >= 0 &&
                      point.x <= width &&
                      point.y >= 0 &&
                      point.y <= height &&
                      point.dist <= maxDistance &&
                      (showAllPoints || point.ele != 0),
                )
                .map(
                  (point) => Positioned(
                    left: point.x,
                    top: point.y,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.0, 
                            )
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Transform.rotate(
                            angle: 45 * (3.14 / 180),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(
                                  8.0, 20.0, 70.0, 8.0),
                              color: Colors.transparent,
                              alignment: Alignment.topLeft,
                              child: Stack(
                                children: [
                                  Text(
                                    point.name,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                        ..style = PaintingStyle.stroke
                                        ..strokeWidth = 1.0
                                        ..color = Colors.white,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Text(
                                      point.name,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }

  checkPerms() async {
    loc.Location location = loc.Location();

    bool _serviceEnabled;
    loc.PermissionStatus _permissionGranted;
    loc.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == loc.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }

  Future<void> startSensor() async {
    try {
      await _channel.invokeMethod('startSensor');
    } on PlatformException catch (e) {
      print("Failed to start sensor: '${e.message}'.");
    }
  }

  void _updateMatrix(Timer timer) async {
    final coords = await _channel.invokeMethod('getPixelCoords');
    final pixelPoints = await fetchPointsFromJava();
    setState(() {
      _coords = coords;
      _pixelPoints = pixelPoints;
    });
  }

  Future<List<double>> getOrientedRotationMatrix() async {
    try {
      final List<dynamic> result =
          await _channel.invokeMethod('getOrientedRotationMatrix');
      final List<double> matrix = result.cast<double>();
      return matrix;
    } on PlatformException catch (e) {
      print("Failed to call getOrientedRotationMatrix: '${e.message}'.");
      return <double>[];
    }
  }

  Future<List<double>> getPixelCoords() async {
    try {
      final List<dynamic> result =
          await _channel.invokeMethod('getPixelCoords');
      final List<double> coords = result.cast<double>();
      return coords;
    } on PlatformException catch (e) {
      print("Failed to call getOrientedRotationMatrix: '${e.message}'.");
      return <double>[];
    }
  }

  Future<List<Point>> fetchPointsFromJava() async {
    try {
      List<dynamic> result = await _channel.invokeMethod('sendPointstoDart');
      List<Point> points = result.map((pointData) {
        String name = pointData['name'];
        double x = pointData['x'];
        double y = pointData['y'];
        double dist = pointData['dist'];
        int ele = pointData['ele'];
        return Point(name: name, x: x, y: y, dist: dist, ele: ele);
      }).toList();

      return points;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<double> getLatitude() async {
    const platform = MethodChannel('com.example.mountain_app/focalLength');
    try {
      final double latitude = await platform.invokeMethod('getLatitude');
      return latitude;
    } catch (e) {
      print('Error getting latitude: $e');
      return 0.0;
    }
  }

  Future<void> getCameraIntrinsicParams(String cameraId) async {
    debugPrint("here");
    try {
      final List<dynamic> result = await _channel.invokeMethod(
          'getCameraIntrinsicParams', <String, dynamic>{'cameraId': cameraId});
      List<double> intrinsicParams = result.cast<double>().toList();
      debugPrint('Camera intrinsic parameters: $intrinsicParams');
    } on PlatformException catch (e) {
      print("Failed to call getCameraIntrinsicParams: '${e.message}'.");
    }
  }

  void sendLocation(double latitude, double longitude, double altitude,
      int width, int height) async {
    try {
      await _channel.invokeMethod('sendLocation', {
        "latitude": latitude,
        "longitude": longitude,
        "altitude": altitude,
        "width": width,
        "height": height
      });
    } on PlatformException catch (e) {
      print("Failed to send location: '${e.message}'.");
    }
  }

  getLocation(double width, double height) async {
    loc.Location location = new loc.Location();
    loc.LocationData _locationData;

    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      // Use current location
      _locationData = currentLocation;
      lat = _locationData.latitude.toString();
      long = _locationData.longitude.toString();
      altitude = _locationData.altitude.toString();
      altitude2 = _locationData.altitude!;

      sendLocation(double.parse(lat), double.parse(long),
          double.parse(altitude), width.round(), height.round());
      if (mounted) {
        setState(() {});
      }
    });
  }
}

// Pixel points
class Point {
  final String name;
  final double x;
  final double y;
  final double dist;
  final int ele;

  Point(
      {required this.name,
      required this.x,
      required this.y,
      required this.dist,
      required this.ele});

  String getName() {
    return name;
  }

  double getX() {
    return x;
  }

  double getY() {
    return y;
  }

  double getDist() {
    return dist;
  }

  int getEle() {
    return ele;
  }
}
