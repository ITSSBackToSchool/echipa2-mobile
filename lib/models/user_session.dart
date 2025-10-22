class UserSession {
  static String? userName;
  static String? token;
  static String? role;

  static void clear() {
    userName = null;
    token = null;
    role = null;
  }
}
