class SpotifyAPIPaths {
  static final List<String> _scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private',
    'user-modify-playback-state',
    'user-read-playback-state'
  ];

  static String requestAuthorization(
          String? clientId, String? redirectUri, String state) =>
      'https://accounts.spotify.com/authorize?client_id=$clientId&response_type=code&redirect_uri=$redirectUri&state=$state&scope=${_scopes.join('%20')}';

  static String requestToken = 'https://accounts.spotify.com/api/token';
  static String getCurrentUser = 'https://api.spotify.com/v1/me';
  static String getUserById(String? userId) =>
      'https://api.spotify.com/v1/users/$userId';

  static String play = 'https://api.spotify.com/v1/me/player/play';
  static String pause = 'https://api.spotify.com/v1/me/player/pause';
  static String player = 'https://api.spotify.com/v1/me/player';
}

class ServerAPIPaths {
  static String serverUrl = 'http://127.0.0.1:8000/';

  static String requestTokens = '$serverUrl/api/token';

  static String login = '$serverUrl/api/db/login/';
  static String register = '$serverUrl/api/db/register/';
  static String checkEmail = '$serverUrl/api/db/emailExists/';
}
