abstract class WebViewProxyDelegate {
  void onWebViewProxyInited(); // view is created, loadUrl must be called in this function
  bool onWebViewProxyNavigate(String url); // true - continue.  false - interrupt.
  void onWebViewProxySearch(String selectedString); // search context menu item.
  // Future<WebResourceResponse?> onWebViewProxyInterceptUrl(String url);
}
