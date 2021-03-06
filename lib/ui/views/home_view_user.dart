import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:oauroadmap/services/map_request.dart';
import 'package:oauroadmap/viewmodels/home_view_model.dart';
import 'package:provider_architecture/viewmodel_provider.dart';

const kGoogleApiKey = 'API_Key';

List<LatLng> result = <LatLng>[];

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class HomeViewUser extends StatefulWidget {
  @override
  HomeViewUserState createState() => HomeViewUserState();
}

class HomeViewUserState extends State<HomeViewUser> {
  loc.LocationData _startLocation;
  loc.LocationData _currentLocation;

  StreamSubscription<loc.LocationData> _locationSubscription;
  loc.Location _locationService = loc.Location();
  bool _permission = false;

  CameraPosition _currentCameraPosition;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyLines = {};
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  Set<Polyline> get polyLines => _polyLines;
  Set<Marker> get markers => _markers;
  Mode _mode = Mode.overlay;
  String error;
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(0, 0),
    zoom: 4.0,
  );

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  @override
  void dispose() {
    _locationSubscription.cancel();

    super.dispose();
  }

  initPlatformState() async {
    final GoogleMapController controller = await _controller.future;
    await _locationService.changeSettings(
        accuracy: loc.LocationAccuracy.HIGH, interval: 1000);

    loc.LocationData location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");
      if (serviceStatus) {
        _permission = await _locationService.requestPermission();
        print("Permission: $_permission");
        if (_permission) {
          location = await _locationService.getLocation();
          LatLng latLng = LatLng(location.latitude, location.longitude);
          _addMarker(latLng, 'Current location');
          // startLocationMarker(latLng);

          _locationSubscription = _locationService
              .onLocationChanged()
              .listen((loc.LocationData result) {
            _currentCameraPosition = CameraPosition(
              target: LatLng(result.latitude, result.longitude),
              zoom: 18.0,
            );

            // controller.animateCamera(
            //     CameraUpdate.newCameraPosition(_currentCameraPosition));

            if (mounted) {
              setState(() {
                _currentLocation = result;
              });
            }
          });
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if (serviceStatusResult) {
          initPlatformState();
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      location = null;
    }

    setState(() {
      _startLocation = location;
    });
  }

  List<LatLng> _convertToLatLng(List points) {
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  void sendRequest(Prediction p) async {
    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    LatLng destination = LatLng(lat, lng);
    Map route = await routeCoordinates(destination);
    LatLng currentLatLng =
        LatLng(_startLocation.latitude, _startLocation.longitude);

    createRoute(route["overview_polyline"]["points"]);

    _addMarker(currentLatLng, 'Current location');
    _addMarker(destination, p.description);
    print('sendRequest is working');
  }

  Future<Map> routeCoordinates(LatLng destination) {
    LatLng currentLatLng =
        LatLng(_startLocation.latitude, _startLocation.longitude);
    return _googleMapsServices.getRouteCoordinates(currentLatLng, destination);
  }

  void createRoute(String encondedPoly) {
    LatLng currentLatLng =
        LatLng(_startLocation.latitude, _startLocation.longitude);
    _polyLines.add(
      Polyline(
        polylineId: PolylineId(currentLatLng.toString()),
        width: 3,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.green,
      ),
    );
  }

  void _addMarker(LatLng location, String address) {
    var markerId = Random().nextInt(1000);
    _markers.clear();
    _markers.add(
      Marker(
          markerId: MarkerId('$markerId'),
          position: location,
          infoWindow: InfoWindow(title: address, snippet: ""),
          icon: BitmapDescriptor.defaultMarker),
    );
  }

  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    // print(lList.toString());

    return lList;
  }

  void onError(PlacesAutocompleteResponse response) {}

  Future<void> _handlePressPrediction() async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    _markers.clear();
    LatLng currentLatLng =
        LatLng(_startLocation.latitude, _startLocation.longitude);
    _addMarker(currentLatLng, 'Current location');

    Prediction p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: _mode,
        language: "en",
        logo: Image.asset(
          '',
          scale: 2000,
        ),
        // components: [Component(Component.country, "ng")],
        location: Location(7.518475, 4.521020),
        radius: 2360,
        strictbounds: true);

    PlacesDetailsResponse detail = await _places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;
    LatLng destination = LatLng(lat, lng);
    Map route = await routeCoordinates(destination);

    sendRequest(p);

    _showModalBottomSheet(route, p);
  }

  Future<void> _showModalBottomSheet(Map route, Prediction p) {
    return showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          double dist =
              double.parse(route["legs"][0]["distance"]["text"].split(' ')[0]);

          String desc = p.description;
          return Container(
            decoration: BoxDecoration(
              border: Border.all(width: 3.0),
              // borderRadius: BorderRadius.circular(15),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Text(
                      'Direction from ${route["legs"][0]["start_address"].toString()} to $desc.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Lato',
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'Instruction: From your current location (${route["legs"][0]["start_address"].toString()}), look for nearest bus stop then take a bike to $desc.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Lato',
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Duration: ${route["legs"][0]["duration"]["text"].toString()}',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Lato',
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Distance: ${route["legs"][0]["distance"]["text"]}',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Lato',
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        dist > 3.5 && dist <= 4.5
                            ? 'Price:  100 naira'
                            : dist > 2.5 && dist <= 3.5
                                ? 'Price:  60 naira'
                                : 'Price:  50 naira',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Lato',
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Text(
                      'Note: You can also turn-off your location and follow the blue line on the map to get your detailed direction',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Lato',
                        fontSize: 18.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelProvider<HomeViewModel>.withConsumer(
      viewModel: HomeViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.location_on),
          title: Text("OAU Road Map"),
          actions: <Widget>[
            IconButton(
              tooltip: 'Log out',
              icon: Icon(Icons.power_settings_new),
              onPressed: () {
                model.logout();
              },
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                result.clear();
                _handlePressPrediction();
              },
              child: Container(
                margin: EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                width: double.infinity,
                height: 40.0,
                decoration:
                    BoxDecoration(border: Border.all(), color: Colors.white),
                child: Center(
                  child: Text(
                    'Search places',
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  _buildGoogleMap(context),
                  buildContainer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      // myLocationButtonEnabled: true,
      myLocationEnabled: true,
      polylines: polyLines,
      // compassEnabled: true,
      initialCameraPosition: _initialCameraPosition,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: _markers,
    );
  }

  Widget buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/awolowohall.jpg', 7.521181, 4.515394,
                  "Awolowo hall"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/computeraud.jpg', 7.518031, 4.528672,
                  "Computer Auditorium"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/healthsciences.jpg', 7.5177371,
                  4.524863, "College of health sciences"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/pharmacy.jpg', 7.516680, 4.527170,
                  "Faculty of pharmacy"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/chemlect.jpg', 7.519361, 4.528650,
                  "Chemical engineering lecture theatre"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/micro.jpg', 7.518903, 4.525700,
                  "Microbiology department"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/senate.jpg', 7.518547, 4.523263,
                  "Senate building"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/amphi.jpg', 7.519352, 4.521995,
                  "Amphitheatre"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/law.jpg', 7.520918, 4.522417,
                  "Faculty of Law"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/agric.jpg', 7.522087, 4.526310,
                  "Faculty of Agricultre"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/faj.jpg', 7.518151, 4.518346,
                  "Adekunle Fajuyi hall"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/moz.jpg', 7.522980, 4.514420,
                  "Mozambique hall"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/angola.jpg', 7.521788, 4.512338,
                  "Angola hall"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/moremi.jpg', 7.520257, 4.518947,
                  "Moremi hall"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/lib.jpg', 7.519619, 4.522810,
                  "Hezekiah Oluwasanmi Library"),
            ),
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes('assets/images/ajose.jpg', 7.521448, 4.526565,
                  "Ajose lecture theatre"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boxes(String _image, double lat, double long, String address) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Container(
        child: new FittedBox(
          child: Material(
              color: Colors.white,
              elevation: 14.0,
              borderRadius: BorderRadius.circular(24.0),
              shadowColor: Color(0x802196F3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 180,
                    height: 200,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(24.0),
                      child: Image(
                        fit: BoxFit.fill,
                        image: AssetImage(_image),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: myDetailsContainer1(address),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }

  Widget myDetailsContainer1(String restaurantName) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
              child: Text(
            restaurantName,
            style: TextStyle(
                color: Color(0xff6200ee),
                fontSize: 24.0,
                fontWeight: FontWeight.bold),
          )),
        ),
      ],
    );
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, long),
      zoom: 18,
      tilt: 50.0,
      bearing: 45.0,
    )));
  }
}
