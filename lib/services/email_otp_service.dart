import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';

class EmailOTPService {
  static const String serviceId = 'service_mtozs6m';
  static const String templateId = 'template_h2a01h2';
  static const String userId = '88LJ_EH_Ak_VFRsR1';

  static String generateOtp() {
    return randomNumeric(6);
  }

  static Future<bool> sendOtpEmail(String toEmail, String otpCode) async {
    const url = 'https://api.emailjs.com/api/v1.0/email/send';

    final now = DateTime.now();
    final expiryTime = now.add(Duration(minutes: 15));
    final formattedTime = "${expiryTime.hour.toString().padLeft(2, '0')}:${expiryTime.minute.toString().padLeft(2, '0')}";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': 'service_mtozs6m',
        'template_id': 'template_h2a01h2',
        'user_id': '88LJ_EH_Ak_VFRsR1',
        'template_params': {
          'email': toEmail,       // ✅ Matches {{email}}
          'passcode': otpCode,    // ✅ Matches {{passcode}}
          'time': formattedTime,  // ✅ Matches {{time}}
        },
      }),
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    return response.statusCode == 200;
  }
}
