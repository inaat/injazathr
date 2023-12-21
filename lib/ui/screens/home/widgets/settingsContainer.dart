import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:injazathr/cubits/appLocalizationCubit.dart';
import 'package:injazathr/ui/screens/home/widgets/changeLanguageBottomsheetContainer.dart';
import 'package:injazathr/ui/widgets/clearDb.dart';
import 'package:injazathr/ui/widgets/customAppbar.dart';
import 'package:injazathr/ui/widgets/logoutButton.dart';
import 'package:injazathr/utils/appLanguages.dart';
import 'package:injazathr/utils/errorMessageKeysAndCodes.dart';
import 'package:injazathr/utils/labelKeys.dart';
import 'package:injazathr/utils/uiUtils.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({Key? key}) : super(key: key);

  void _shareApp(BuildContext context) async {
    final appUrl = "lllll";
    if (await canLaunchUrl(Uri.parse(appUrl))) {
      launchUrl(Uri.parse(appUrl));
    } else {
      // ignore: use_build_context_synchronously
      UiUtils.showBottomToastOverlay(
          context: context,
          errorMessage: UiUtils.getTranslatedLabel(
              context, ErrorMessageKeysAndCode.defaultErrorMessageKey),
          backgroundColor: Theme.of(context).colorScheme.error);
    }
  }

  Widget _buildAppbar(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: CustomAppBar(
          showBackButton: false,
          title: UiUtils.getTranslatedLabel(context, settingKey)),
    );
  }

  Widget _buildMoreSettingDetailsTile(
      {required String title,
      required Function onTap,
      required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: DecoratedBox(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.transparent)),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.8),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreSettingsContainer(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 15,
              width: 15,
              child: SvgPicture.asset(
                UiUtils.getImagePath("more_icon.svg"),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * (0.05),
            ),
            Text(
              UiUtils.getTranslatedLabel(context, moreKey),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Divider(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Widget _buildLanguageContainer(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              height: 25,
              width: 25,
              child: SvgPicture.asset(
                UiUtils.getImagePath("language.svg"),
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * (0.05),
            ),
            Text(
              UiUtils.getTranslatedLabel(context, appLanguageKey),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Divider(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
        ),
        GestureDetector(
          onTap: () {
            UiUtils.showBottomSheet(
                child: const ChangeLanguageBottomsheetContainer(),
                context: context);
          },
          child: Row(
            children: [
              BlocBuilder<AppLocalizationCubit, AppLocalizationState>(
                builder: (context, state) {
                  final String languageName = appLanguages
                      .where((element) =>
                          element.languageCode == state.language.languageCode)
                      .toList()
                      .first
                      .languageName;
                  return Text(
                    languageName,
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.8),
                        fontWeight: FontWeight.w400,
                        fontSize: 13.0),
                  );
                },
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(
                  bottom: UiUtils.getScrollViewBottomPadding(context),
                  start: MediaQuery.of(context).size.width * (0.075),
                  end: MediaQuery.of(context).size.width * (0.075),
                  top: UiUtils.getScrollViewTopPadding(
                      context: context,
                      appBarHeightPercentage:
                          UiUtils.appBarSmallerHeightPercentage)),
              child: Column(
                children: [
                  _buildLanguageContainer(context),
                  _buildMoreSettingsContainer(context),
                  const SizedBox(
                    height: 20.0,
                  ),
                  const LogoutButton(),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const ClearButton(),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Text("1",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontWeight: FontWeight.w500,
                          fontSize: 11.0),
                      textAlign: TextAlign.start),
                ],
              )),
        ),
        _buildAppbar(context),
      ],
    );
  }
}
