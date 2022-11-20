import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellbeing/providers_and_settings/general_providers.dart';
import 'package:wellbeing/providers_and_settings/keys_for_save_and_load.dart';
import 'package:wellbeing/providers_and_settings/data_loader.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wellbeing/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';


final Provider<void> loadDataProvider = Provider((ref) async {
  final DataSetup dataSetup = DataSetup(ref.read);
  dataSetup.loadDataOnUserChange();
});

class DataSetup {
  DataSetup(this.stateReader);

  final Reader stateReader;
  User? user;

  void loadDataOnUserChange() async {
    FirebaseAuth auth = await startFirebaseAuthentification();

    auth
      .idTokenChanges()  // also triggers on app startup
      .listen((User? loadedUser) {
        user = loadedUser;
        onUserChange();
      });
  }

  Future<FirebaseAuth> startFirebaseAuthentification() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final FirebaseAuth auth = FirebaseAuth.instance;
    return auth;
  }

  void onUserChange() async {
    if (user == null) {
      noUser();
    } else {
      userLogin();
    }
  }

  void noUser() {
    stateReader(userIsLoggedInProvider.state).state = false;
    stateReader(userIdFirebaseProvider.state).state = null;
  }

  void userLogin() async {
    final DataLoader dataLoader = DataLoader(stateReader);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? firebaseUserIdFromSharedPreferences = prefs.getString(firebaseUserIdKey);
    final String userIdFromFirebase = user!.uid;  // force not null: function is only called after user == null

    if (firebaseUserIdFromSharedPreferences == null) { // save afterwards
      dataLoader.loadAndCombineSharedPreferencesAndFirebaseWithId(userIdFromFirebase);
    } else {
      dataLoader.loadFromFirebaseWithId(userIdFromFirebase);
    }

    stateReader(userIsLoggedInProvider.state).state = true;
    stateReader(userIdFirebaseProvider.state).state = user!.uid;  // force not null: function is only called after user == null
  }
}






