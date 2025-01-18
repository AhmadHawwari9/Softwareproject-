import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class NotificationService {
  // Method to get an access token using a service account
  static Future<String> getAccessToken() async {
    try {
      const serviceAccountJson = r'''{
        "type": "service_account",
        "project_id": "softwareproject-cf82f",
        "private_key_id": "42e397e6bf9131f23889cc6a75dd880787dfbe45",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADAN...skipped...\n-----END PRIVATE KEY-----\n",
        "client_email": "testing@softwareproject-cf82f.iam.gserviceaccount.com",
        "client_id": "112712432921249110732",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/testing%40softwareproject-cf82f.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
      }''';

      List<String> scopes = [
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/firebase.database",
        "https://www.googleapis.com/auth/firebase.messaging"
      ];

      final client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      final credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );

      client.close();
      return credentials.accessToken.data;
    } catch (e) {
      print('Error obtaining access token: $e');
      rethrow; // Rethrow the exception to propagate the error.
    }
  }

  // Method to send a notification to a specific device token
  static Future<void> sendNotification(
      String deviceToken, String title, String body) async {
    try {
      final String accessToken = await getAccessToken();
      const String endpointFCM =
          'https://fcm.googleapis.com/v1/projects/softwareproject-cf82f/messages:send';

      final Map<String, dynamic> message = {
        "message": {
          "token": deviceToken,
          "notification": {"title": title, "body": body},
          "data": {"route": "serviceScreen"}
        }
      };

      final response = await http.post(
        Uri.parse(endpointFCM),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
