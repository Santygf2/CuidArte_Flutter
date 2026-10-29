import 'package:web/web.dart' as web;

Future<bool> openExternalUrl(String url) async {
  web.window.open(url, '_blank');
  return true;
}

Future<bool> printCurrentPage() async {
  web.window.print();
  return true;
}
