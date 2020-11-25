import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_cab/Language/appLocalizations.dart';
import 'package:my_cab/constance/constance.dart';
import 'package:my_cab/constant_styles/styles.dart';
import 'package:my_cab/helper_providers/client_providers/client_info_provider.dart';
import 'package:my_cab/models/auth_model/user_info.dart';
import 'package:provider/provider.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    var data = Provider.of<ClientInfoProvider>(context);
    return Scaffold(
      backgroundColor: backGroundColors,
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 160,
                color: staticGreenColor,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 16,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 14, left: 14),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 14, left: 14, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(AppLocalizations.of('My Account'),
                            style: headLineStyle.copyWith(color: Colors.white)),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 26,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.asset("assets/profile_icon.png"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(0),
              children: <Widget>[
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
                MyAccountInfo(
                  headText: AppLocalizations.of('Level'),
                  subtext: AppLocalizations.of('Gold member'),
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
                SizedBox(
                  height: 16,
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
                FutureBuilder(
                    future: data.getClientInfo(),
                    builder: (context, AsyncSnapshot<ClientInfo> snapshot) {
                      if (snapshot.data == null) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return MyAccountInfo(
                        headText: AppLocalizations.of('Name'),
                        subtext: snapshot.data.name,
                      );
                    }),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                MyAccountInfo(
                  headText: AppLocalizations.of('Email'),
                  subtext: AppLocalizations.of('account@gmail.com'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                MyAccountInfo(
                  headText: AppLocalizations.of('Gender'),
                  subtext: AppLocalizations.of('Female'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showCupertinoModalPopup<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return _buildBottomPicker(
                          CupertinoDatePicker(
                            use24hFormat: true,
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: DateTime.now(),
                            onDateTimeChanged: (DateTime newDateTime) {},
                            maximumYear: 2021,
                            minimumYear: 1995,
                          ),
                        );
                      },
                    );
                  },
                  child: MyAccountInfo(
                    headText: AppLocalizations.of('Birthday'),
                    subtext: AppLocalizations.of('April 16, 1988'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Container(
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
                MyAccountInfo(
                  headText: AppLocalizations.of('Phone Number'),
                  subtext: AppLocalizations.of('+84 905 07 99 13'),
                ),
                Container(
                  height: 1,
                  color: Theme.of(context).dividerColor,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: 240,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }
}

class MyAccountInfo extends StatelessWidget {
  final String headText;
  final String subtext;

  const MyAccountInfo({Key key, this.headText, this.subtext}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(right: 10, left: 14, top: 8, bottom: 8),
        child: Row(
          children: <Widget>[
            Text(
              headText,
              style: headLineStyle.copyWith(fontSize: 16.0),
            ),
            Expanded(child: SizedBox()),
            Text(
              subtext,
              style: describtionStyle.copyWith(
                color: Colors.black38,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 2,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: staticGreenColor,
            ),
          ],
        ),
      ),
    );
  }
}
