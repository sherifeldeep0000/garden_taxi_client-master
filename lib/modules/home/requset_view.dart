import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:my_cab/Language/appLocalizations.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constant_styles/styles.dart';
import 'package:my_cab/helper_providers/client_providers/client_info_provider.dart';
import 'package:my_cab/helper_providers/maps/destination_info.dart';
import 'package:my_cab/helper_providers/maps/directionDetails.dart';
import 'package:my_cab/helper_providers/maps/directionStorage.dart';
import 'package:my_cab/helper_providers/maps/my_location_info.dart';
import 'package:my_cab/models/trip_canceled.dart';

import 'package:my_cab/modules/home/promoCodeView.dart';
import 'package:my_cab/constance/global.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequsetView extends StatefulWidget {
  @override
  _RequsetViewState createState() => _RequsetViewState();
}

class _RequsetViewState extends State<RequsetView> {
  GoogleMapController _mapController;

  @override
  void dispose() {
    _mapController.dispose();

    print("Disposed");
    super.dispose();
  }

  List<LatLng> polyLineCoordinates = [];
  Set<Polyline> _polyLines = {};
  Set<Marker> _markers = {};
  double myLat = 37.42796133580664,
      myLong = -122.085749655962,
      endLat = 37.42796133580664,
      endLong = -122.085749655962;
  void getPolyLinedetails() async {
    setState(() {
      myLat = Provider.of<MyLocationInfo>(context, listen: false).myLat;
      myLong = Provider.of<MyLocationInfo>(context, listen: false).myLong;
      endLat =
          Provider.of<DstinationInfo>(context, listen: false).latDestination;
      endLong =
          Provider.of<DstinationInfo>(context, listen: false).longDestination;
    });

    var thisDeatils = await DirectionDetailsInfo.getDirections(
      startPosition: LatLng(myLat, myLong),
      endPosition: LatLng(endLat, endLong),
      context: context,
    );
    PolylinePoints polylinePoints = PolylinePoints();
    String points =
        Provider.of<DirectionStorage>(context, listen: false).encodedPoints;
    polyLineCoordinates.clear();
    List<PointLatLng> results = polylinePoints.decodePolyline(points);
    if (results.isNotEmpty) {
      results.forEach((element) {
        polyLineCoordinates.add(
          LatLng(element.latitude, element.longitude),
        );
      });
    }
    _polyLines.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId(
          "polyId",
        ),
        color: Colors.blue,
        width: 4,
        points: polyLineCoordinates,
      );
      _polyLines.add(polyline);
    });
    LatLngBounds bounds;
    if (myLat > endLat && myLong > endLong) {
      bounds = LatLngBounds(
        southwest: LatLng(endLat, endLong),
        northeast: LatLng(myLat, myLong),
      );
    } else if (myLong > endLong) {
      bounds = LatLngBounds(
        southwest: LatLng(myLat, endLong),
        northeast: LatLng(endLat, myLong),
      );
    } else if (myLat > endLat) {
      bounds = LatLngBounds(
        southwest: LatLng(endLat, myLong),
        northeast: LatLng(myLat, endLong),
      );
    } else {
      bounds = LatLngBounds(
        southwest: LatLng(myLat, myLong),
        northeast: LatLng(endLat, endLong),
      );
    }

    String placeNameDstination =
        Provider.of<DstinationInfo>(context, listen: false)
            .placeNameDestination;
    String myPlaceName =
        Provider.of<MyLocationInfo>(context, listen: false).addressName;
    Marker myLocation = Marker(
      markerId: MarkerId("My Location"),
      position: LatLng(myLat, myLong),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: myPlaceName, snippet: "My Location"),
    );
    Marker endLocation = Marker(
      markerId: MarkerId("end Location"),
      position: LatLng(endLat, endLong),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: placeNameDstination, snippet: "My Destination"),
    );
    setState(() {
      _markers.add(myLocation);
      _markers.add(endLocation);
    });
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70.0),
    );
    DirectionDetailsInfo.estimateFare(thisDeatils, context);
  }

  void notificationToDriver() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tokenLogin = prefs.getString("userToken");
    String tokenRegsiter = prefs.getString("registerToken");
    int clientId = prefs.getInt("clinetId");
    String clientName = prefs.getString("ClientName");
    print(clientName);
    print(clientId);

    //print("my Token Is ${tokenLogin ?? tokenRegsiter}");
    //print("id sss  ahaaa  $clientId");

    var inside = Provider.of<ClientInfoProvider>(context, listen: false).inside;
    var outSide =
        Provider.of<ClientInfoProvider>(context, listen: false).outSide;

    var myLat = Provider.of<MyLocationInfo>(context, listen: false).myLat;
    var myLong = Provider.of<MyLocationInfo>(context, listen: false).myLong;

    var latDes =
        Provider.of<DstinationInfo>(context, listen: false).latDestination;
    var longDes =
        Provider.of<DstinationInfo>(context, listen: false).longDestination;
    var tripFares =
        Provider.of<DirectionStorage>(context, listen: false).totlaPrice;
    // print(tokenRegsiter);
    String url = "https://gardentaxi.net/Back_End/public/api/tripe/register?";

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(
        {
          "client": {
            "id": clientId.toString(),
            "name": clientName,
            "startPoint": {
              "lat": myLat.toString(),
              "long": myLong.toString(),
              // "lat": "30.4761909",
              // "long": "31.0361089"
            },
            "endPoint": {
              "lat": latDes.toString(),
              "long": longDes.toString(),
            },
            "cost": tripFares.toString(),
            "in_ahram": inside ?? outSide,
          }
        },
      ),
    );
    if (response.statusCode == 200) {
      print("true");
      var dataDecoded = jsonDecode(response.body);
      var id = dataDecoded['data']['user_id'];
      print("idsssssssss ::: $id");
      print(dataDecoded);
    } else {
      print("fails");
    }
  }

  Future<TripCanceled> tripCanceled() async {
    var inside = Provider.of<ClientInfoProvider>(context, listen: false).inside;
    var outSide =
        Provider.of<ClientInfoProvider>(context, listen: false).outSide;

    var myLat = Provider.of<MyLocationInfo>(context, listen: false).myLat;
    var myLong = Provider.of<MyLocationInfo>(context, listen: false).myLong;

    var latDes =
        Provider.of<DstinationInfo>(context, listen: false).latDestination;
    var longDes =
        Provider.of<DstinationInfo>(context, listen: false).longDestination;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    int clientId = prefs.getInt("clinetId");
    TripCanceled cancel;
    // put Id at the Last api
    String url = "https://gardentaxi.net/Back_End/public/api/tripe/cancel/47";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      cancel = TripCanceled(
        //put Here Driver Id and trip Id,
        // driverId: 1,
        // tripId: 1,
        clientId: clientId,
        startPointLat: myLat,
        startPointLong: myLong,
        endPointLat: latDes,
        endPointLong: longDes,
        insideOrOutSide: inside ?? outSide,
      );
    }
    print("haaaa ${cancel.clientId}");
    return cancel;
  }

  @override
  Widget build(BuildContext context) {
    var tripFares = Provider.of<DirectionStorage>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.42796133580664, -122.085749655962),
              zoom: 18.0,
            ),
            polylines: _polyLines,
            markers: _markers,
            onMapCreated: (controller) {
              _mapController = controller;
              getPolyLinedetails();
            },
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top,
                          left: 8,
                          right: 8),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            height: AppBar().preferredSize.height,
                            width: AppBar().preferredSize.height,
                            child: InkWell(
                              onTap: () async {},
                              child: Icon(Icons.arrow_back, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SizedBox(),
                ),
                !isConfrimDriver
                    ? Card(
                        elevation: 16,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              color: staticGreenColor,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.car,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            AppLocalizations.of('Just go'),
                                            style: describtionStyle.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            AppLocalizations.of('Near by you'),
                                            style: describtionStyle.copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          tripFares.totlaPrice.toString() +
                                                  " LE" ??
                                              "loading",
                                          style: describtionStyle.copyWith(
                                            color: Colors.white,
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          tripFares.durationValue.toString() +
                                                  " Min" ??
                                              "loading",
                                          style: describtionStyle.copyWith(
                                            color: Colors.white,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: Theme.of(context).disabledColor,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: 16, bottom: 16, left: 8, right: 8),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {},
                                      child: Column(
                                        children: <Widget>[
                                          Icon(
                                            Icons.account_balance_wallet,
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              AppLocalizations.of('Payment'),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    color: Theme.of(context).dividerColor,
                                    width: 1,
                                    height: 48,
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              elevation: 0,
                                              backgroundColor:
                                                  Colors.transparent,
                                              contentPadding: EdgeInsets.all(0),
                                              content: PromoCodeView(),
                                            );
                                          },
                                        );
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Icon(
                                            Icons.loyalty,
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              AppLocalizations.of('Promo code'),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .copyWith(
                                                    // fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    color: Theme.of(context).dividerColor,
                                    width: 1,
                                    height: 48,
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {},
                                      child: Column(
                                        children: <Widget>[
                                          Icon(
                                            Icons.more_horiz,
                                            color:
                                                Theme.of(context).disabledColor,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              AppLocalizations.of('Options'),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .copyWith(
                                                    // fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .disabledColor,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 24, right: 24, bottom: 16, top: 8),
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: staticGreenColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(24.0)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: Theme.of(context).dividerColor,
                                      blurRadius: 8,
                                      offset: Offset(4, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(24.0)),
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      setState(() {
                                        isConfrimDriver = true;
                                      });
                                      notificationToDriver();
                                    },
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of('Request'),
                                        style: buttonsText,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).padding.bottom,
                            )
                          ],
                        ),
                      )
                    : confirmDriverBox(
                        context: context,
                        distance: tripFares.distanceText,
                        time: tripFares.durationText,
                        price: tripFares.totlaPrice.toString()),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool isConfrimDriver = false;

  Widget confirmDriverBox(
      {context, String distance, String time, String price}) {
    return Padding(
      padding: EdgeInsets.only(right: 10, left: 10, bottom: 10),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.only(right: 24, left: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    new BoxShadow(
                      color: globals.isLight
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.2),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 0,
            left: 0,
            bottom: 16,
            child: Padding(
              padding: const EdgeInsets.only(right: 12, left: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    new BoxShadow(
                      color: globals.isLight
                          ? Colors.black.withOpacity(0.2)
                          : Colors.white.withOpacity(0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 24),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  new BoxShadow(
                    color: globals.isLight
                        ? Colors.black.withOpacity(0.2)
                        : Colors.white.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Theme.of(context).dividerColor.withOpacity(0.03),
                      padding: EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              "assets/profile_icon.png",
                              height: 50,
                              width: 50,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of('Gregory Smith'),
                                style: headLineStyle.copyWith(fontSize: 15.0),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                            ],
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 0.5,
                      color: Theme.of(context).dividerColor,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: 14, left: 14, top: 10, bottom: 10),
                    ),
                    Divider(
                      height: 0.5,
                      color: Colors.black12,
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: 14, left: 14, top: 10, bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.car,
                            size: 24,
                            color: staticGreenColor,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          SizedBox(
                            width: 32,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of('DISTANCE'),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.4),
                                    ),
                              ),
                              Text(
                                distance,
                                style: describtionStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              )
                            ],
                          ),
                          Expanded(child: SizedBox()),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of('TIME'),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.4),
                                    ),
                              ),
                              Text(
                                time,
                                style: describtionStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              )
                            ],
                          ),
                          Expanded(child: SizedBox()),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                AppLocalizations.of('PRICE'),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .dividerColor
                                          .withOpacity(0.4),
                                    ),
                              ),
                              Text(
                                price,
                                style: describtionStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 16, right: 16, bottom: 16, top: 8),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: staticGreenColor,
                          borderRadius: BorderRadius.all(Radius.circular(24.0)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Theme.of(context).dividerColor,
                              blurRadius: 8,
                              offset: Offset(4, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.all(Radius.circular(24.0)),
                            highlightColor: Colors.transparent,
                            onTap: () {
                              tripCanceled();
                            },
                            child: Center(
                              child: Text(
                                AppLocalizations.of('Cancel Request'),
                                style: buttonsText,
                              ),
                            ),
                          ),
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
    );
  }

  bool isConfirm = false;
}
