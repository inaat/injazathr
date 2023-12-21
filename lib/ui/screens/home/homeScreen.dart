import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injazathr/cubits/attendanceCubit.dart';
import 'package:injazathr/data/repositories/attendanceRepository.dart';
import 'package:injazathr/ui/screens/home/widgets/bottomNavigationItemContainer.dart';
import 'package:injazathr/ui/screens/home/widgets/homeContainer.dart';
import 'package:injazathr/ui/screens/home/widgets/profileContainer.dart';
import 'package:injazathr/ui/screens/home/widgets/settingsContainer.dart';
import 'package:injazathr/ui/styles/colors.dart';
import 'package:injazathr/ui/widgets/radialDecoration.dart';
import 'package:injazathr/utils/labelKeys.dart';
import 'package:injazathr/utils/uiUtils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider(
              create: (context) => AttendanceCubit(AttendanceRepository()),
              child: const HomeScreen(),
            ));
  }
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500));

  late final Animation<double> _bottomNavAndTopProfileAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController, curve: Curves.easeInOut));

  late final List<AnimationController> _bottomNavItemTitlesAnimationController =
      [];

  late int _currentSelectedBottomNavIndex = 0;

  final List<BottomNavItem> _bottomNavItems = [
    BottomNavItem(
        activeImageUrl: UiUtils.getImagePath("home_active_icon.svg"),
        disableImageUrl: UiUtils.getImagePath("home_icon.svg"),
        title: homeKey),
    // BottomNavItem(
    //     activeImageUrl: UiUtils.getImagePath("schedule_active.svg"),
    //     disableImageUrl: UiUtils.getImagePath("schedule.svg"),
    //     title: scheduleKey),
    BottomNavItem(
        activeImageUrl: UiUtils.getImagePath("profile_active.svg"),
        disableImageUrl: UiUtils.getImagePath("profile.svg"),
        title: profileKey),
    BottomNavItem(
        activeImageUrl: UiUtils.getImagePath("setting_active.svg"),
        disableImageUrl: UiUtils.getImagePath("setting.svg"),
        title: settingKey),
  ];

  @override
  void initState() {
    super.initState();
    initAnimations();
    _animationController.forward();

    /// _createBottomBannerAd();
  }

  void initAnimations() {
    for (var i = 0; i < _bottomNavItems.length; i++) {
      _bottomNavItemTitlesAnimationController.add(AnimationController(
          value: i == _currentSelectedBottomNavIndex ? 0.0 : 1.0,
          vsync: this,
          duration: const Duration(milliseconds: 400)));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    //_bottomBannerAd.dispose();

    for (var animationController in _bottomNavItemTitlesAnimationController) {
      animationController.dispose();
    }
    super.dispose();
  }

  void _changeBottomNavItem(int index) async {
    _bottomNavItemTitlesAnimationController[_currentSelectedBottomNavIndex]
        .forward();
    //change current selected bottom index
    setState(() {
      _currentSelectedBottomNavIndex = index;
    });
    _bottomNavItemTitlesAnimationController[_currentSelectedBottomNavIndex]
        .reverse();
  }

  Widget _buildBottomNavigationContainer() {
    return FadeTransition(
      opacity: _bottomNavAndTopProfileAnimation,
      child: SlideTransition(
        position: _bottomNavAndTopProfileAnimation.drive(
            Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero)),
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * (0.075) * (0.075),
          ),
          margin: EdgeInsets.only(
            bottom: UiUtils.bottomNavigationBottomMargin,
          ),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color:
                    UiUtils.getColorScheme(context).secondary.withOpacity(0.15),
                offset: const Offset(2.5, 2.5),
                blurRadius: 20,
                spreadRadius: 0)
          ], color: primaryColor, borderRadius: BorderRadius.circular(10.0)),
          width: MediaQuery.of(context).size.width * (0.8),
          height: MediaQuery.of(context).size.height *
              UiUtils.bottomNavigationHeightPercentage,
          child: LayoutBuilder(builder: (context, boxConstraints) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _bottomNavItems.map((bottomNavItem) {
                int index = _bottomNavItems
                    .indexWhere((e) => e.title == bottomNavItem.title);
                return BottomNavItemContainer(
                    onTap: _changeBottomNavItem,
                    boxConstraints: boxConstraints,
                    currentIndex: _currentSelectedBottomNavIndex,
                    bottomNavItem: _bottomNavItems[index],
                    animationController:
                        _bottomNavItemTitlesAnimationController[index],
                    index: index);
              }).toList(),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //  decoration: RadialDecoration(),
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: _currentSelectedBottomNavIndex,
              children: [
                const HomeContainer(),
                ProfileContainer(),
                const SettingsContainer(),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomNavigationContainer(),
            ),
          ],
        ),
      ),
    );
  }
}
