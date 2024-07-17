import 'dart:ui';

class GoUrlPageParam {
  GoUrlPageParam(this.title, this.url, {this.backgroundColor, this.showBackButtonIfNoTitle = true});
  String title;
  String url;
  Color? backgroundColor;
  bool showBackButtonIfNoTitle;
}
