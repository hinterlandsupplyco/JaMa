import 'package:commons/commons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:jama/mixins/color_mixin.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/models/home_model.dart';
import 'package:jama/ui/screens/base_screen.dart';
import 'package:jama/ui/screens/time_screen.dart';
import 'package:jama/ui/widgets/goal_widget.dart';
import 'package:jama/ui/widgets/time_report_widget.dart';
import 'package:provider/provider.dart';
import 'package:slider_button/slider_button.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        floatingActionButton: SpeedDial(
          foregroundColor: AppStyles.secondaryBackground,
          backgroundColor: Colors.white,
          animatedIcon: AnimatedIcons.menu_close,
          marginBottom:
              MediaQuery.of(context).size.height - AppStyles.headerHeight - 28,
          overlayColor: HexColor.fromHex("#9F9F9F"),
          overlayOpacity: 0.7,
          orientation: SpeedDialOrientation.Down,
          children: [
            SpeedDialChild(
                child: Icon(Icons.add),
                label: "add time",
                labelStyle: AppStyles.heading4,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TimeScreen.createNew()));
                }),
            SpeedDialChild(
                child: Icon(Icons.access_alarms),
                label: "record time",
                labelStyle: AppStyles.heading4),
            SpeedDialChild(
                child: Icon(Icons.group_add),
                label: "add return visit",
                labelStyle: AppStyles.heading4),
          ],
        ),
        body: ChangeNotifierProvider<HomeModel>(
          create: (_) => HomeModel(),
          child: Consumer<HomeModel>(
            builder: (_, model, __) => Stack(
              children: <Widget>[
                
                // body - background color fill
                Positioned.fill(
                  top: AppStyles.headerHeight - MediaQuery.of(context).padding.top,
                  child: Container(
                    color: AppStyles.primaryBackground,
                  ),),

                // header
                Positioned(
                    top: AppStyles.topMargin,
                    width: MediaQuery.of(context).size.width,
                    height: AppStyles.headerHeight,
                    child: Padding(
                      padding: EdgeInsets.only(left: AppStyles.leftMargin),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Home",
                            style: AppStyles.heading1
                                .copyWith(color: Colors.white),
                          ),
                          Text(DateFormat("MMMM y").format(DateTime.now()),
                              style: AppStyles.heading4
                                  .copyWith(color: Colors.white))
                        ],
                      ),
                    )),

                // body
                Positioned.fill(
                  left: AppStyles.leftMargin,
                  top: AppStyles.headerHeight / 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TimeReportWidget(
                        allHours: model.allHours,
                        goalHours: model.goalHours,
                        placements: model.placements,
                        videos: model.videos,
                        returnVisits: model.returnVisits,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppStyles.topMargin),
                        child: SliderButton(
                          backgroundColor: AppStyles.secondaryBackground,
                          shimmer: false,
                          dismissible: false,
                          buttonColor: Colors.white,
                          highlightedColor: Colors.white,
                          baseColor: Colors.white,
                          width: MediaQuery.of(context).size.width -
                              (AppStyles.leftMargin * 2),
                          action: () {
                            // TODO: implement send report
                            infoDialog(context, "not yet implemented.");
                          },
                          label: Text(
                              "Send " +
                                  DateFormat("MMMM").format(DateTime.now()) +
                                  " Report",
                              style: AppStyles.heading2
                                  .copyWith(color: Colors.white)),
                          icon: Center(
                            child: Icon(
                              Icons.send,
                              color: AppStyles.secondaryBackground,
                            ),
                          ),
                        ),
                        ),
                      model.goals.length > 0
                          ? ListView.builder(
                              itemCount: model.goals.length,
                              itemBuilder: (context, index) {
                                return GoalWidget(goal: model.goals[index]);
                              },
                            )
                          : Center(
                              child: FlatButton(
                              color: AppStyles.lightGrey,
                              child: Text(
                                "add some goals",
                                style: AppStyles.heading4
                                    .copyWith(color: Colors.black),
                              ),
                              onPressed: () {
                                // TODO: how to enable goals?
                                
                              },
                            ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
