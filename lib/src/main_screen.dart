import 'package:adhd_0_1/src/common/app_bg.dart';
import 'package:adhd_0_1/src/features/dailys/presentation/dailys.dart';
import 'package:adhd_0_1/src/common/screens/deadlineys.dart';
import 'package:adhd_0_1/src/common/screens/fidget.dart';
import 'package:adhd_0_1/src/common/screens/fridge_lock.dart';
import 'package:adhd_0_1/src/common/screens/prizes.dart';
import 'package:adhd_0_1/src/common/screens/quest.dart';
import 'package:adhd_0_1/src/common/screens/settings.dart';
import 'package:adhd_0_1/src/common/screens/tutorial.dart';
import 'package:adhd_0_1/src/common/screens/weeklys.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 1;

  List<Widget> pages = [
    Tutorial(),
    Dailys(),
    Weeklys(),
    Deadlineys(),
    Quest(),
    FridgeLock(),
    Fidget(),
    Prizes(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBg(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: 50,

                    height: double.infinity,
                    child: NavigationRail(
                      leading: SizedBox(height: 40),
                      selectedIndex: _pageIndex,
                      indicatorColor: Palette.highlight,

                      indicatorShape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      onDestinationSelected: (int index) {
                        setState(() {
                          _pageIndex = index;
                        });
                      },
                      backgroundColor: Colors.transparent,
                      destinations: <NavigationRailDestination>[
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset(
                            'assets/img/sidebar/oi.png',
                            width: 30,
                          ),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/daily.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/week.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/clock.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/star.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/fridge.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/fidget.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/prize.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/hamburger.png'),
                          label: Text(''),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(child: Center(child: pages[_pageIndex])),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
