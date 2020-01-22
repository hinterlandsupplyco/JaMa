import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:jama/ui/app_styles.dart';
import 'package:jama/ui/screens/home_screen.dart';
import 'package:line_icons/line_icons.dart';

import 'time_list_screen.dart';

class TabbedController extends StatefulWidget {
  TabbedController({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TabbedControllerState createState() => _TabbedControllerState();
}

class _TabbedControllerState extends State<TabbedController> {
  int selectedIndex = 0;

  PageController controller = PageController(keepPage: true);

  List<GButton> tabs = new List();
  final List<Widget> _children = [
    HomeScreen(),
    TimeListScreen(
      startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
      endDate: DateTime(DateTime.now().year, DateTime.now().month + 1, 1)
          .subtract(Duration(milliseconds: 1)),
    )
  ];

  @override
  void initState() {
    super.initState();

    var padding = EdgeInsets.symmetric(horizontal: 12, vertical: 5);
    double gap = 30;
    final iconInactiveColor = AppStyles.primaryColor;
    final iconColor = AppStyles.primaryColor;
    final textColor = AppStyles.primaryColor;
    final color = AppStyles.lightGrey;
    final double iconSize = 24;

    tabs.add(GButton(
      gap: gap,
      iconActiveColor: iconInactiveColor,
      iconColor: iconColor,
      textColor: textColor,
      color: color,
      iconSize: iconSize,
      padding: padding,
      icon: LineIcons.home,
      // textStyle: t.textStyle,
      text: 'Home',
    ));

    tabs.add(GButton(
      gap: gap,
      iconActiveColor: iconInactiveColor,
      iconColor: iconColor,
      textColor: textColor,
      color: color,
      iconSize: iconSize,
      padding: padding,
      icon: LineIcons.clock_o,
      // textStyle: t.textStyle,
      text: 'Time',
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBody: true,
        body: PageView.builder(
          onPageChanged: (page) {
            setState(() {
              selectedIndex = page;
            });
          },
          controller: controller,
          itemBuilder: (context, position) {
            return Container(
              child: _children[position],
            );
          },
          itemCount: tabs.length, // Can be null
        ),
        // backgroundColor: Colors.green,
        // body: Container(color: Colors.red,),
        bottomNavigationBar: SafeArea(
          bottom: false,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  spreadRadius: -10,
                  blurRadius: 60,
                  color: Colors.black.withOpacity(.20),
                  offset: Offset(0, 15))
            ]),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: GNav(
                  tabs: tabs,
                  selectedIndex: selectedIndex,
                  onTabChange: (index) {
                    print(index);
                    setState(() {
                      selectedIndex = index;
                    });
                    controller.jumpToPage(index);
                  }),
            ),
          ),
        ),
      ),
    );
  }
}