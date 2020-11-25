import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_cab/Language/appLocalizations.dart';
import 'package:my_cab/constance/themes.dart';
import 'package:my_cab/constant_styles/styles.dart';
import 'package:my_cab/modules/rating/rating_screen.dart';
import 'package:my_cab/modules/widgets/cardWidget.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColors,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
              color: Colors.blue,
            ),
            Text(
              "History",
              style: headLineStyle.copyWith(
                  color: Colors.black, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          Image.asset(
            "assets/images/setting_effect.PNG",
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: 0, right: 14, left: 14),
                    child: Column(
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            gotorating();
                          },
                          child: CardWidget(
                            fromAddress:
                                AppLocalizations.of('465 Swift Village'),
                            toAddress: AppLocalizations.of(
                                '105 William St, Chicago, US'),
                            price: "Le 00.00",
                            status: AppLocalizations.of('Completed'),
                            statusColor: HexColor("#3638FE"),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  gotorating() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingScreen(),
      ),
    );
  }
}
