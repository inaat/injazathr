import 'package:injazathr/cubits/appSettingsCubit.dart';
import 'package:injazathr/data/repositories/systemInfoRepository.dart';
import 'package:injazathr/ui/widgets/appSettingsBlocBuilder.dart';
import 'package:injazathr/ui/widgets/customAppbar.dart';
import 'package:injazathr/utils/labelKeys.dart';
import 'package:injazathr/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();

  static Route route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<AppSettingsCubit>(
              create: (context) => AppSettingsCubit(SystemRepository()),
              child: PrivacyPolicyScreen(),
            ));
  }
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final String privacyPolicyType = "privacy_policy";

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      context
          .read<AppSettingsCubit>()
          .fetchAppSettings(type: privacyPolicyType);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppSettingsBlocBuilder(
            appSettingsType: privacyPolicyType,
          ),
          CustomAppBar(
              title: UiUtils.getTranslatedLabel(context, privacyPolicyKey))
        ],
      ),
    );
  }
}
