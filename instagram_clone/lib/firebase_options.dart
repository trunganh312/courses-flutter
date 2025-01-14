// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDpiLccxeH1MR-binhDDToEXuT6UQVSyCA',
    appId: '1:410863172599:web:59c100724402a75bd08cf2',
    messagingSenderId: '410863172599',
    projectId: 'instagram-clone-aeeba',
    authDomain: 'instagram-clone-aeeba.firebaseapp.com',
    storageBucket: 'instagram-clone-aeeba.appspot.com',
    measurementId: 'G-6DXGSQBP3X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKNdC2o8SZWDvV-ciSXk_FTgcdKskguMM',
    appId: '1:410863172599:android:208634869b493d03d08cf2',
    messagingSenderId: '410863172599',
    projectId: 'instagram-clone-aeeba',
    storageBucket: 'instagram-clone-aeeba.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjF4kLHMFTWCEfmn_WdsYcvCbxWQbLVyE',
    appId: '1:410863172599:ios:afdd2ce3c060bbabd08cf2',
    messagingSenderId: '410863172599',
    projectId: 'instagram-clone-aeeba',
    storageBucket: 'instagram-clone-aeeba.appspot.com',
    iosBundleId: 'com.example.instagramClone',
  );
}
