import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _clientIDWeb =
      '633455376067-6okh12jonhh5s10s5t2e90p68govqi7t.apps.googleusercontent.com';
  static final _googleSignIn = GoogleSignIn(clientId: _clientIDWeb);

  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
}
