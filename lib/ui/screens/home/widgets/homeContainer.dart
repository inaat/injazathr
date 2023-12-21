import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:injazathr/cubits/authCubit.dart';
import 'package:injazathr/ui/screens/home/widgets/checkAttendance.dart';
import 'package:injazathr/ui/widgets/customShimmerContainer.dart';
import 'package:injazathr/ui/widgets/internetListenerWidget.dart';
import 'package:injazathr/ui/widgets/radialDecoration.dart';
import 'package:injazathr/ui/widgets/screenTopBackgroundContainer.dart';
import 'package:injazathr/ui/widgets/shimmerLoadingContainer.dart';
import 'package:injazathr/utils/labelKeys.dart';
import 'package:injazathr/utils/localdb.dart';
import 'package:injazathr/utils/uiUtils.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer({Key? key}) : super(key: key);

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {});
    super.initState();
  }

  TextStyle _titleFontStyle() {
    return TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontSize: 17.0,
        fontWeight: FontWeight.w600);
  }

  Widget _buildTopProfileContainer(BuildContext context) {
    return ScreenTopBackgroundContainer(
      padding: const EdgeInsets.all(0),
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Stack(
          children: [
            //Bordered circles
            PositionedDirectional(
              top: MediaQuery.of(context).size.width * (-0.15),
              start: MediaQuery.of(context).size.width * (-0.225),
              child: Container(
                padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.1)),
                    shape: BoxShape.circle),
                width: MediaQuery.of(context).size.width * (0.6),
                height: MediaQuery.of(context).size.width * (0.6),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.1)),
                      shape: BoxShape.circle),
                ),
              ),
            ),

            //bottom fill circle
            PositionedDirectional(
              bottom: MediaQuery.of(context).size.width * (-0.15),
              end: MediaQuery.of(context).size.width * (-0.15),
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.1),
                    shape: BoxShape.circle),
                width: MediaQuery.of(context).size.width * (0.4),
                height: MediaQuery.of(context).size.width * (0.4),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsetsDirectional.only(
                    start: boxConstraints.maxWidth * (0.075),
                    bottom: boxConstraints.maxHeight * (0.2)),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(context
                                  .read<AuthCubit>()
                                  .getUserDetails()
                                  .image)),
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 2.0,
                              color:
                                  Theme.of(context).scaffoldBackgroundColor)),
                      width: boxConstraints.maxWidth * (0.175),
                      height: boxConstraints.maxWidth * (0.175),
                    ),
                    SizedBox(
                      width: boxConstraints.maxWidth * (0.05),
                    ),
                    Expanded(
                        child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context
                                  .read<AuthCubit>()
                                  .getUserDetails()
                                  .employeeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                            ),
                          ],
                        )
                      ],
                    ))
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildClassShimmerLoading(BoxConstraints boxConstraints) {
    return ShimmerLoadingContainer(
        child: CustomShimmerContainer(
      height: 80,
      borderRadius: 10,
      width: boxConstraints.maxWidth * (0.45),
    ));
  }

  Widget _buildMenuContainer(
      {required String iconPath,
      required String title,
      required String route}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
        child: Container(
          height: 80,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                width: 1.0,
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.25),
              )),
          child: LayoutBuilder(builder: (context, boxConstraints) {
            return Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  height: 60,
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSecondary
                          .withOpacity(0.225),
                      borderRadius: BorderRadius.circular(15.0)),
                  width: boxConstraints.maxWidth * (0.225),
                  child: SvgPicture.asset(iconPath),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Text(
                  title,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15),
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  radius: 17.5,
                  child: Icon(
                    Icons.arrow_forward,
                    size: 22.5,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                const SizedBox(
                  width: 15.0,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: RadialDecoration(),
      child: InternetListenerWidget(
        onInternetConnectionBack: () {},
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * (0.075),
                    right: MediaQuery.of(context).size.width * (0.075),
                    bottom: UiUtils.getScrollViewBottomPadding(context),
                    top: UiUtils.getScrollViewTopPadding(
                        context: context,
                        appBarHeightPercentage:
                            UiUtils.appBarBiggerHeightPercentage)),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Column(
                        children: [
                          CheckAttendance(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: _buildTopProfileContainer(context),
            ),
          ],
        ),
      ),
    );
  }
}
