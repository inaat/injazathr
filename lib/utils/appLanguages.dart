//by default language of the app

import 'package:hive_flutter/hive_flutter.dart';
import 'package:injazathr/data/models/appLanguage.dart';
import 'package:injazathr/utils/hiveBoxKeys.dart';

const String defaultLanguageCode = "en";

String languageCode =
    Hive.box(settingsBoxKey).get(currentLanguageCodeKey) ?? defaultLanguageCode;
//Add language code in this list
//visit this to find languageCode for your respective language
//https://developers.google.com/admin-sdk/directory/v1/languages
const List<AppLanguage> appLanguages = [
  //Please add language code here and language name
  AppLanguage(languageCode: "en", languageName: "English"),
  AppLanguage(languageCode: "hi", languageName: "हिन्दी - Hindi"),
  AppLanguage(languageCode: "ur", languageName: "اردو - Urdu"),
];
