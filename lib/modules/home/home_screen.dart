import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constant_styles/styles.dart';
import 'package:my_cab/helper_providers/maps/my_location_info.dart';
import 'package:my_cab/modules/drawer/drawer.dart';
import 'package:my_cab/modules/home/addressSelctionView.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  GoogleMapController _mapController;

  double lat = 37.42796133580664;
  double long = -122.085749655962;
  Map<MarkerId, Marker> _markers = {};
  Future getMyCurrentLocation() async {
    Position position = await getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    setState(() {
      lat = position.latitude;
      long = position.longitude;
    });
    Provider.of<MyLocationInfo>(context, listen: false).getMyLat(lat);
    Provider.of<MyLocationInfo>(context, listen: false).getMyLong(long);
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 18.0,
        ),
      ),
    );

    Coordinates coordinates =
        Coordinates(position.latitude, position.longitude);
    var address =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    String addressName = address.first.addressLine;
    Provider.of<MyLocationInfo>(context, listen: false)
        .getMyAddressName(addressName);
    MarkerId markerId = MarkerId("Home");
    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, long),
      draggable: false,
      icon: BitmapDescriptor.defaultMarker,
    );
    setState(() {
      _markers[markerId] = marker;
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    var data = Provider.of<MyLocationInfo>(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75 < 400
            ? MediaQuery.of(context).size.width * 0.72
            : 350,
        child: Drawer(
          child: AppDrawer(
            selectItemName: 'Home',
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Positioned(
            top: 10.0,
            right: 0.0,
            left: 0,
            height: height,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(lat, long),
                zoom: 18.0,
              ),

              markers: Set.of(_markers.values),
              mapToolbarEnabled: true,
              // padding:
              //     EdgeInsets.only(left: 0.0, top: height * 0.2, right: 350.0),
              onMapCreated: (GoogleMapController controller) async {
                _mapController = controller;
                await getMyCurrentLocation();
              },
              onCameraMove: (updatePosition) {
                MarkerId markerId = MarkerId("Home");
                Marker updateMarker = _markers[markerId]
                    .copyWith(positionParam: updatePosition.target);
                print(updatePosition.target);

                setState(() {
                  _markers[markerId] = updateMarker;
                  data.myLat = updatePosition.target.latitude;
                  data.myLong = updatePosition.target.longitude;
                });
              },
              onCameraIdle: () async {
                print("Stopped");
                var coordinates = Coordinates(data.myLat ?? 37.42796133580664,
                    data.myLong ?? -122.085749655962);
                var address = await Geocoder.local
                    .findAddressesFromCoordinates(coordinates);
                setState(() {
                  data.addressName = address.first.addressLine;
                });
              },
            ),
          ),
          Positioned(
            bottom: height * 0.3,
            left: 8.0,
            child: Container(
              color: Colors.white,
              child: IconButton(
                icon: Icon(Icons.my_location),
                onPressed: () async {
                  await getMyCurrentLocation();
                },
                color: Colors.black,
                iconSize: 30.0,
              ),
            ),
          ),
          _getAppBarUI(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.3,
              child: AddressSelctionView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAppBarUI() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 8,
            right: 8,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                height: AppBar().preferredSize.height,
                width: AppBar().preferredSize.height,
                child: Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Card(
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                    child: Container(
                      color: staticGreenColor,
                      padding: EdgeInsets.all(2),
                      child: InkWell(
                        onTap: () {
                          _scaffoldKey.currentState.openDrawer();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32.0),
                          child: Image.asset(
                            "assets/profile_icon.png",
                            // color: Colors.blas,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum ProsseType {
  dropOff,
  mapPin,
  requset,
}
