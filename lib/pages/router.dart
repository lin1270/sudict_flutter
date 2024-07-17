// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sudict/pages/about/index.dart';
import 'package:sudict/pages/book_reader/epub_reader/index.dart';
import 'package:sudict/pages/book_shelf/index.dart';
import 'package:sudict/pages/book_shelf/online_page/index.dart';
import 'package:sudict/pages/dizigui/index.dart';
import 'package:sudict/pages/enter_area/index.dart';
import 'package:sudict/pages/fj_convert/fjReflectPage.dart';
import 'package:sudict/pages/fj_convert/index.dart';
import 'package:sudict/pages/go_url/index.dart';
import 'package:sudict/pages/history/index.dart';
import 'package:sudict/pages/jgw/about_page.dart';
import 'package:sudict/pages/jgw/catalog_page.dart';
import 'package:sudict/pages/jgw/index.dart';
import 'package:sudict/pages/jgw/liushu_read_page.dart';
import 'package:sudict/pages/jgw/practice_page.dart';
import 'package:sudict/pages/jgw/search_page.dart';
import 'package:sudict/pages/jgw/setting_page.dart';
import 'package:sudict/pages/jingyuan/index.dart';
import 'package:sudict/pages/jingyuan/xiguicidi_catalog_page.dart';
import 'package:sudict/pages/jingyuan/xiguicidi_play_list_page.dart';
import 'package:sudict/pages/lookfor_words/index.dart';
import 'package:sudict/pages/online_study_resource/index.dart';
import 'package:sudict/pages/book_reader/pdf_reader/index.dart';
import 'package:sudict/pages/san_qian/index.dart';
import 'package:sudict/pages/san_qian/san_qian_read_page.dart';
import 'package:sudict/pages/setting/contact_me_page.dart';
import 'package:sudict/pages/setting/dict/add_web_dict_page.dart';
import 'package:sudict/pages/setting/dict/dict_group_setting.dart';
import 'package:sudict/pages/setting/dict/edit_group_dict_page.dart';
import 'package:sudict/pages/setting/dict/edit_user_group_page.dart';
import 'package:sudict/pages/setting/dict/edit_user_local_dict_page.dart';
import 'package:sudict/pages/setting/dict/index.dart';
import 'package:sudict/pages/setting/font_setting_page.dart';
import 'package:sudict/pages/setting/happy_donate_page.dart';
import 'package:sudict/pages/setting/index.dart';
import 'package:sudict/pages/setting/search_setting_page.dart';
import 'package:sudict/pages/shilv/analysis_page.dart';
import 'package:sudict/pages/shilv/index.dart';
import 'package:sudict/pages/shilv/pinshuiyun_page.dart';
import 'package:sudict/pages/thought_record/chart_page.dart';
import 'package:sudict/pages/thought_record/index.dart';

class CommonRoutePageParam {
  CommonRoutePageParam(this.path, this.param);
  String path = '';
  dynamic param;
}

class AppRouteName {
  AppRouteName._();

  static const about = '/about';
  static const goUrl = '/goUrl';

  static const setting = '/setting';
  static const settingFont = '/setting/font';
  static const settingSearch = '/setting/search';
  static const settingDict = '/setting/dict';
  static const settingDictGroup = '/setting/dict/group';
  static const settingEditUserGroup = '/setting/dict/editUserGroup';
  static const settingDictAddWebDict = '/setting/dict/group/addWebDict';
  static const settingDictEidtLocalDict = '/setting/dict/group/editLocalDict';
  static const settingEditGroupDict = '/setting/dict/group/editGroupDict';
  static const settingContactMe = '/setting/contactMe';
  static const settingHappyDonate = '/setting/happyDonate';

  static const history = '/history';
  static const lookforWords = '/lookforWords';
  static const onlineStudyResource = '/onlineStudyResource';

  static const fjConvert = '/fjConvert';
  static const fjConvertReflect = '/fjConvert/reflect';

  static const sanQian = '/sanQian';
  static const sanQianRead = '/sanQian/read';

  static const enterArea = '/enterArea';

  static const bookShelf = '/bookShelf';
  static const bookShelfOnlineBook = '/bookShelf/onlineBook';

  static const pdfReader = '/pdfReader';
  static const epubReader = '/epubReader';

  static const jgw = '/jgw';
  static const jgwAbout = '/jgw/about';
  static const jgwSetting = '/jgw/setting';
  static const jgwLiushuRead = '/jgw/liushuRead';
  static const jgwCatalog = '/jgw/catalog';
  static const jgwPrictice = '/jgw/prictice';
  static const jgwSearch = '/jgw/jgwSearch';

  static const shilv = '/shilv';
  static const shilvPingshuiyun = '/shilv/pingshuiyun';
  static const shilvAnalysis = '/shilv/analysis';

  static const jingyuan = '/jingyuan';
  static const jingyuanXiguicidiPlayList = '/jingyuan/playlist';
  static const jingyuanXiguicidiCatalog = '/jingyuan/catalog';

  static const thoughtRecord = '/thoughtRecord';
  static const thoughtRecordChart = '/thoughtRecord/chart';

  static const dizigui = '/dizigui';
}

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    AppRouteName.about: (context) => const AboutPage(),
    AppRouteName.goUrl: (context, {arguments}) => GoUrlPage(arguments: arguments),
    // --
    AppRouteName.setting: (context) => const SettingPage(),
    AppRouteName.settingFont: (context) => const FontSettingPage(),
    AppRouteName.settingDict: (context) => const DictSettingPage(),
    AppRouteName.settingDictGroup: (context, {arguments}) =>
        DictGroupSettingPage(arguments: arguments),
    AppRouteName.settingEditUserGroup: (context, {arguments}) =>
        EditUserGroupPage(arguments: arguments),
    AppRouteName.settingDictAddWebDict: (context, {arguments}) =>
        AddWebDictPage(arguments: arguments),
    AppRouteName.settingDictEidtLocalDict: (context, {arguments}) =>
        EditUserLocalDictPage(arguments: arguments),
    AppRouteName.settingEditGroupDict: (context, {arguments}) =>
        EditGroupDictPage(arguments: arguments),
    AppRouteName.settingContactMe: (context) => const ContactMePage(),
    AppRouteName.settingHappyDonate: (context) => const HappyDonatePage(),
    AppRouteName.settingSearch: (context) => const SearchSettingPage(),
    // --
    AppRouteName.history: (context) => const HistoryPage(),
    AppRouteName.lookforWords: (context) => const LookforWordsPage(),
    AppRouteName.onlineStudyResource: (context) => const OnlineStudyResourcePage(),
    // --
    AppRouteName.fjConvert: (context) => const FjConvertPage(),
    AppRouteName.fjConvertReflect: (context) => const FjReflectPage(),
    // --
    AppRouteName.sanQian: (context, {arguments}) => SanQianPage(arguments: arguments),
    AppRouteName.sanQianRead: (context, {arguments}) => SanQianReadPage(arguments: arguments),
    // --
    AppRouteName.enterArea: (context) => const EnterAreaPage(),
    // --
    AppRouteName.bookShelf: (context) => const BookShelfPage(),
    AppRouteName.bookShelfOnlineBook: (context) => const OnlineBookPage(),
    // --
    AppRouteName.pdfReader: (context, {arguments}) => PdfReaderPage(arguments: arguments),
    AppRouteName.epubReader: (context, {arguments}) => EpubReaderPage(arguments: arguments),
    // --
    AppRouteName.jgw: (context) => const JgwPage(),
    AppRouteName.jgwAbout: (context) => const JgwAboutPage(),
    AppRouteName.jgwSetting: (context) => const JgwSettingPage(),
    AppRouteName.jgwLiushuRead: (context, {arguments}) => LiushuReadPage(arguments: arguments),
    AppRouteName.jgwCatalog: (context) => const JgwCatalogPage(),
    AppRouteName.jgwPrictice: (context, {arguments}) => JgwPracticePage(isRandom: arguments),
    AppRouteName.jgwSearch: (context) => const JgwSearchPage(),
    // --
    AppRouteName.shilv: (context) => const ShilvPage(),
    AppRouteName.shilvPingshuiyun: (context) => const PingshuiyunPage(),
    AppRouteName.shilvAnalysis: (context, {arguments}) => ShilvAnalysisPage(content: arguments),
    // --
    AppRouteName.jingyuan: (context) => const JingYuanPage(),
    AppRouteName.jingyuanXiguicidiPlayList: (context) => const XiguicidiPlayListPage(),
    AppRouteName.jingyuanXiguicidiCatalog: (context) => const XiguicidiCatalogWidget(),
    // --
    AppRouteName.thoughtRecord: (context) => const ThoughtRecordPage(),
    AppRouteName.thoughtRecordChart: (context) => const ThoughtRecordChartPage(),
    // --
    AppRouteName.dizigui: (context) => const DiziguiPage(),
  };
}
