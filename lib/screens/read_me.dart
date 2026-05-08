import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A screen that will contain game instructions, credits, or other
/// supplementary information for the player.
///
/// Currently displays a placeholder; replace the body content with the
/// actual readme / help text before shipping.
class ReadMe extends StatefulWidget {
  const ReadMe({super.key});

  @override
  State<ReadMe> createState() => ReadMeState();
}

class ReadMeState extends State<ReadMe> {
  
  /// controller to view the project wiki from the web
  final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse("https://docs.google.com/document/d/1h2Z_hUe-yG7tg1wrDSrGjNImLIGe7AQLBSUyIven2Po/edit?usp=sharing"));

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Appbar(
      context: context,
      header: Text('READ ME', style: headerTextStyle),
    ),
    drawer: const Sidebar(),
    body: SafeArea(
      child: Center(
        child: WebViewWidget(controller: _controller),
      ),
    ),
  );
}