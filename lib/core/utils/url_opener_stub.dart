import 'package:flutter/services.dart';

Future<bool> openExternalUrl(String url) async {
  await Clipboard.setData(ClipboardData(text: url));
  return false;
}

Future<bool> printCurrentPage() async {
  return false;
}
