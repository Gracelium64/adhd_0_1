import 'package:adhd_0_1/src/common/presentation/app_bg.dart';
import 'package:adhd_0_1/src/data/databaserepository.dart';
import 'package:adhd_0_1/src/data/domain/reset_scheduler.dart';
import 'package:adhd_0_1/src/features/tasks_dailys/presentation/dailys.dart';
import 'package:adhd_0_1/src/features/tasks_deadlineys/presentation/deadlineys.dart';
import 'package:adhd_0_1/src/features/fidget_screen/presentation/fidget_screen.dart';
import 'package:adhd_0_1/src/features/fridge_lock/presentation/fridge_lock.dart';
import 'package:adhd_0_1/src/features/prizes/presentation/prizes.dart';
import 'package:adhd_0_1/src/features/tasks_quest/presentation/quest.dart';
import 'package:adhd_0_1/src/features/settings/presentation/settings.dart';
import 'package:adhd_0_1/src/features/tutorial/presentation/tutorial.dart';
import 'package:adhd_0_1/src/features/tasks_weeklys/presentation/weeklys.dart';
import 'package:adhd_0_1/src/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  final bool showTutorial;

  const MainScreen({super.key, this.showTutorial = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  OverlayPortalController overlayController = OverlayPortalController();
  int _pageIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showTutorial) {
        overlayController.show();
      }
    });
    performResetsIfNeeded();
  }

  void performResetsIfNeeded() async {
    final repository = context.read<DataBaseRepository>();
    final resetScheduler = ResetScheduler(repository);
    await resetScheduler.performResetsIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<DataBaseRepository>();

    Size screenSize = MediaQuery.of(context).size;

    List<Widget> pages = [
      Tutorial(overlayController),
      Dailys(),
      Weeklys(),
      Deadlineys(),
      Quest(),
      FridgeLock(),
      FidgetScreen(),
      Prizes(),
      Settings(),
    ];

    return Stack(
      children: [
        AppBg(repository),
        OverlayPortal(
          controller: overlayController,
          overlayChildBuilder: (context) => Tutorial(overlayController),
          child: SizedBox.shrink(),
        ),
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
                        if (index == 0) {
                          overlayController.toggle();
                        } else {
                          setState(() => _pageIndex = index);
                        }
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
