class UserSession {
  static int? userId;
  static String? userName;
  static String? token;
  static String? role;

  static void setSession(Map<String, dynamic> data) {
    userId = data['id'];
    userName = data['userName'];
    token = data['token'];

  }

  static void clear() {
    userId = null;
    userName = null;
    token = null;
    role = null;
  }
}
