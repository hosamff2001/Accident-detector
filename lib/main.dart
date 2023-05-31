import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors/sensors.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<double> accelerometers = [0, 0, 0];
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  bool Detecting = false;
  late Timer timer;
  double acceler = 0;
  String accidentTime = "", latitude = "", longitude = "";
  var controller;

  @override
  void initState() {
    super.initState();
    controller = MapController();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        accelerometers = <double>[event.x, event.y, event.z];
        var temp = sqrt(pow(accelerometers[0], 2) +
            pow(accelerometers[1], 2) +
            pow(accelerometers[2], 2));
        var substract = (temp - acceler).abs();
        if (substract > 30) {
          //35
          Detecting = true;
          findTheLocation();
        } else {
          acceler = temp;
        }
      });
    }));
  }

  void findTheLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    accidentTime = DateTime.now().toString();
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Detecting
            ? Color.fromARGB(255, 255, 17, 0)
            : Color.fromARGB(255, 100, 178, 127),
        appBarTheme: AppBarTheme(backgroundColor: Colors.white, elevation: 8),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Detecting Accident',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            Detecting
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        accidentTime = '';
                        latitude = '';
                        longitude = '';
                        Detecting = false;
                      });
                    },
                    icon: Icon(Icons.reply_outlined),
                    color: Colors.black,
                  )
                : Container()
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (Detecting == false) noAccident() else accidentd(),
              Spacer(),
              Text(
                  'Accelerometer: [${accelerometers[0].round()},${accelerometers[1].round()},${accelerometers[2].round()}]'),
            ],
          ),
        ),
      ),
    );
  }

  Widget noAccident() {
    return Column(
      children: [
        Icon(
          Icons.drive_eta,
          size: 250,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Safe Mode",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Icon(
              Icons.tag_faces_outlined,
              size: 35,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "There No Accident",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.thumb_up_outlined,
                  size: 50,
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget accidentd() {
    return Column(
      children: [
        Icon(
          Icons.car_crash_outlined,
          size: 250,
        ),
        Text(
          '',
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: Colors.amber),
        ),
        SizedBox(
          height: 25,
        ),
        if (accidentTime != "")
          Text(
            'Accident date : ${accidentTime.split(" ")[0]} / Time : ${accidentTime.split(" ")[1].substring(0, 8)}',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Colors.amber, fontSize: 18),
          ),
        SizedBox(
          height: 15,
        ),
        if (longitude != "" && latitude != "")
          Column(
            children: [
              Text(
                'Accident location',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: Colors.amber, fontSize: 18),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'latitude = ${latitude} ',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.amber, fontSize: 18),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'longitude= $longitude',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: Colors.amber, fontSize: 18),
                ),
              ),
              SizedBox(
                width: 400,
                height: 300,
                child: FlutterMap(
                  mapController: controller,
                  options: MapOptions(
                    center: LatLng(29.307652, 30.846704),
                    swPanBoundary: LatLng(29.2691, 30.8062),
                    nePanBoundary: LatLng(29.3429, 30.8818),
                  ),
                  children: [
                  
                    TileLayer(
                      tileProvider: AssetTileProvider(),
                      urlTemplate: 'Fayom/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                      point: LatLng(
                          double.parse(latitude), double.parse(longitude)),
                      builder: (context) => const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 35.0,
                      ),
                    ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}
