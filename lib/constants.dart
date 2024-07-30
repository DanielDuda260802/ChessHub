class Constants {
  static const String homeScreen = '/homeScreen';
  static const String gameScreen = '/gameScreen';
  static const String landingScreen = '/landingScreen';
  static const String settingScreen = 'settingsScreen';
  static const String aboutScreen = '/aboutScreen';
  static const String gameStartScreen = '/gameStartScreen';
  static const String gameTempoScreen = '/gameTimeScreen';
  static const String loginScreen = '/loginScreen';
  static const String signUpScreen = '/signUpScreen';
  static const String userDetailScreen = '/userDetailScreen';

  static const String custom = 'Custom';

  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String image = 'image';
  static const String createdAt = 'createdAt';
}

enum PlayerColor {
  white,
  black,
}

enum GameDifficulty {
  easy,
  medium,
  hard,
}

enum SignType {
  emailAndPassword,
  quest,
  google,
  facebook,
}
