import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injazathr/app/routes.dart';
import 'package:injazathr/cubits/companyCubit.dart';
import 'package:injazathr/data/models/company.dart';
import 'package:injazathr/data/repositories/companyRepository.dart';
import 'package:injazathr/ui/widgets/customShimmerContainer.dart';
import 'package:injazathr/ui/widgets/errorContainer.dart';
import 'package:injazathr/ui/widgets/radialDecoration.dart';
import 'package:injazathr/ui/widgets/shimmerLoadingContainer.dart';
import 'package:injazathr/utils/hiveBoxKeys.dart';
import 'package:injazathr/utils/labelKeys.dart';
import 'package:injazathr/utils/uiUtils.dart';
import 'package:injazathr/ui/styles/colors.dart';
import 'package:shimmer/shimmer.dart';

import '../widgets/noDataContainer.dart';

class CompanyScreen extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  CompanyScreen({
    Key? key,
  }) : super(key: key);

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider(
            create: (context) => CompanyCubit(CompanyRepository()),
            // ignore: prefer_const_constructors
            child: CompanyScreen()));
  }

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));

  late final Animation<double> _patterntAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)));

  late final Animation<double> _formAnimation =
      Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)));
  late final List<Company> schools;
  var _isLoading = false;

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context.read<CompanyCubit>().fetchSchools();
      _animationController.forward();
    });

    super.initState();
  }

  Future<void> SetMainUrlBoxKey(String value) async {
    return Hive.box(mainUrlBoxKey).put(mainUrl, value);
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  Widget _buildSchoolDropdown() {
    return BlocConsumer<CompanyCubit, CompanyState>(
      listener: (context, state) {
        if (state is CompanyFetchSuccess) {
          schools = state.company;
        }
      },
      builder: (context, state) {
        //
        if (state is CompanyFetchSuccess) {
          //
          if (state.company.isEmpty) {
            return NoDataContainer(
                titleKey: UiUtils.getTranslatedLabel(context, noDataFoundKey));
          }
          //
          return Container(
            child: Center(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: UiUtils.getColorScheme(context).primary)),
                  child: DropdownSearch<String>(
                    //mode: Mode.MENU,
                    showSelectedItems: true,
                    items: state.company.map((e) => e.name).toList(),
                    popupBackgroundColor: pageBackgroundColor,

                    dropdownSearchDecoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
                      hintText: UiUtils.getTranslatedLabel(
                          context, searchYourCompanyKey),
                      hintStyle: TextStyle(color: secondaryColor),
                      border: const OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: secondaryColor),
                      ),
                    ),
                    onChanged: itemSelectionChanged,
                    showSearchBox: true,
                    emptyBuilder: (context, searchEntry) => Center(
                        child: Text(
                            UiUtils.getTranslatedLabel(context, noDataFoundKey),
                            style: TextStyle(color: secondaryColor))),

                    popupItemBuilder:
                        (BuildContext context, String item, bool isSelected) {
                      return Container(
                        padding: const EdgeInsets.all(10),
                        color: isSelected
                            ? primaryColor
                            : null, // Set selected item background color
                        child: Text(
                          item,
                          style: TextStyle(
                              color: isSelected
                                  ? primaryColor
                                  : secondaryColor // Set text color to white for selected item, black otherwise
                              ),
                        ),
                      );
                    },
                    searchFieldProps: TextFieldProps(
                      keyboardType: TextInputType.text,
                      cursorColor: primaryColor,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
                        hintText: UiUtils.getTranslatedLabel(
                            context, searchYourCompanyKey),
                        fillColor: primaryColor,
                        enabledBorder: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          );
        }
        if (state is CompanyFetchFailure) {
          return ErrorContainer(
              errorMessageCode: state.errorMessage,
              onTapRetry: () => context.read<CompanyCubit>().fetchSchools());
        }
        return _buildStudentListShimmerContainer();
      },
    );
  }

  Widget _buildSchoolForm() {
    return Align(
      alignment: Alignment.topLeft,
      child: FadeTransition(
        opacity: _formAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * (0.075),
                right: MediaQuery.of(context).size.width * (0.075),
              ),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Align(
                        alignment: Alignment.center,
                        child: FadeTransition(
                          opacity: _patterntAnimation,
                          child: SlideTransition(
                              position: _patterntAnimation.drive(Tween<Offset>(
                                  begin: const Offset(0.0, -1.0),
                                  end: Offset.zero)),
                              child: SvgPicture.asset(
                                  UiUtils.getImagePath("3.svg"))),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    _buildSchoolDropdown(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          _buildSchoolForm(),
        ],
      ),
    ));
  }

  Widget _buildStudentListShimmerContainer() {
    return Container(
      child: Shimmer.fromColors(
        baseColor: shimmerBaseColor,
        highlightColor: shimmerhighlightColor,
        child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: shimmerContentColor,
              borderRadius: BorderRadius.circular(
                  20), // radius of 10// green as background color
            )),
      ),
    );
  }

  void itemSelectionChanged(String? s) {
    for (var i = 0; i < schools.length; i++) {
      if (schools[i].name == s) {
        print(schools[i].name);
        // print(schools);
        //SetMainUrlBoxKey(schools[i].url);
        SetMainUrlBoxKey("http://192.168.100.70/hrm/public/api/");
        //SetMainUrlBoxKey("http://192.168.8.103/hrm/public/api/");

        // //fetchAppConfiguration();
        print(Hive.box(mainUrlBoxKey).get(mainUrl) ?? "");
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    }
  }
}
