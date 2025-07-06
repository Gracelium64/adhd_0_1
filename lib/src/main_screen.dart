import 'package:adhd_0_1/src/common/presentation/app_bg.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/auth_repository.dart';
import 'package:adhd_0_1/src/features/dailys/presentation/dailys.dart';
import 'package:adhd_0_1/src/features/deadlineys/presentation/deadlineys.dart';
import 'package:adhd_0_1/src/features/fidget_screen/presentation/fidget_screen.dart';
import 'package:adhd_0_1/src/features/fridge_lock/presentation/fridge_lock.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/prizes.dart';
import 'package:adhd_0_1/src/features/quest/presentation/quest.dart';
import 'package:adhd_0_1/src/features/settings/presentation/settings.dart';
import 'package:adhd_0_1/src/features/tutorial/presentation/tutorial.dart';
import 'package:adhd_0_1/src/features/weeklys/presentation/weeklys.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  final DataBaseRepository repository;
  final AuthRepository auth;

  const MainScreen(this.repository, this.auth, {super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageIndex = 1;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    List<Widget> pages = [
      Tutorial(widget.repository, widget.auth),
      Dailys(widget.repository),
      Weeklys(widget.repository),
      Deadlineys(widget.repository),
      Quest(widget.repository),
      FridgeLock(widget.repository, widget.auth),
      FidgetScreen(widget.repository),
      Prizes(widget.repository),
      Settings(widget.repository),
    ];

    return Stack(
      children: [
        AppBg(widget.repository),
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
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                            child: Image.asset('assets/img/sidebar/daily.png'),
                          ),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                            child: Image.asset('assets/img/sidebar/week.png'),
                          ),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/clock.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                            child: Image.asset('assets/img/sidebar/star.png'),
                          ),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/fridge.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                            child: Image.asset('assets/img/sidebar/fidget.png'),
                          ),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Image.asset('assets/img/sidebar/prize.png'),
                          label: Text(''),
                        ),
                        NavigationRailDestination(
                          padding: EdgeInsets.only(bottom: 8),
                          icon: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                            child: Image.asset(
                              'assets/img/sidebar/hamburger.png',
                            ),
                          ),
                          label: Text(''),
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: SizedBox(
                    height: screenSize.height / 1.12,
                    width: screenSize.width,
                    child: Center(child: pages[_pageIndex]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
