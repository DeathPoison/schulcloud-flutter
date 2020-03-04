import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pedantic/pedantic.dart';
import 'package:schulcloud/app/app.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../bloc.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  WebViewController controller;

  bool _isLoading = false;
  String _ambientError;

  Future<void> _executeLogin(Future<void> Function() login) async {
    setState(() => _isLoading = true);

    try {
      await login();
      setState(() => _ambientError = null);

      // Logged in.
      unawaited(context.navigator.pushReplacement(TopLevelPageRoute(
        builder: (_) => SignedInScreen(),
      )));
    } on NoConnectionToServerError {
      _ambientError = context.s.signIn_form_errorNoConnection;
    } on AuthenticationError {
      _ambientError = context.s.signIn_form_errorAuth;
    } on TooManyRequestsError catch (error) {
      _ambientError = context.s.signIn_form_errorRateLimit(error.timeToWait);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginAsDemoStudent() =>
      _executeLogin(() => services.get<SignInBloc>().signInAsDemoStudent());

  Future<void> _loginAsDemoTeacher() =>
      _executeLogin(() => services.get<SignInBloc>().signInAsDemoTeacher());

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final s = context.s;

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 16),
      width: 400,
      child: Column(
        children: [
          SizedBox(height: 128),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: SvgPicture.asset(
              services
                  .get<AppConfig>()
                  .assetName(context, 'logo/logo_with_text.svg'),
              height: 64,
              alignment: Alignment.bottomCenter,
            ),
          ),
          SizedBox(height: 32),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: mediaQuery.size.height -
                  400 -
                  mediaQuery.padding.bottom -
                  mediaQuery.padding.top,
            ),
            child: WebView(
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (controller) => this.controller = controller,
                onPageFinished: (url) async {
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (controller) => this.controller = controller,
              onPageFinished: (url) async {
                final firstPathSegment = Uri.parse(url).pathSegments.first;
                if (firstPathSegment == 'login') {
                  // The JavaScript is meant to isolate the login section.
                  // Hopefully there will be an option to only get that in a
                  // non-hacky way in the future.
                  await controller.evaluateJavascript('''
                  var node = document.getElementById('loginarea');
                  var html = document.getElementsByTagName('html')[0];
                  html.removeChild(html.childNodes[2]);
                  html.appendChild(node);
                  document.getElementsByTagName('h2')[0].innerHTML = ''
                  ''');
                } else if (firstPathSegment == 'dashboard') {
                  final cookies =
                      await controller.evaluateJavascript('document.cookie');
                  // Yes, this is not elegant. You may complain about it when
                  // there is a nice way to get a single cookie via JavaScript.
                  final jwt = cookies
                      .split('; ')
                      .firstWhere((element) => element.startsWith('"jwt='))
                      .replaceAll('"', '')
                      .substring(4);

                  await services.storage.token.setValue(jwt);

                  unawaited(context.navigator.pushReplacement(
                      TopLevelPageRoute(builder: (_) => SignedInScreen())));
                }
              },
              initialUrl: services.get<AppConfig>().webUrl('login'),
            ),
          ),
          SizedBox(height: 32),
          Wrap(
            children: <Widget>[
              SecondaryButton(
                onPressed: _loginAsDemoStudent,
                child: Text(s.signIn_form_demo_student),
              ),
              SizedBox(width: 8),
              SecondaryButton(
                onPressed: _loginAsDemoTeacher,
                child: Text(s.signIn_form_demo_teacher),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
