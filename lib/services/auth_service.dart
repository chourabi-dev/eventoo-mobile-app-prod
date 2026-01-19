import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/main.dart';
import 'package:mobile/services/config.dart';

class AuthService {
  ServiceEnv _env = ServiceEnv(); 
  static const _storage = FlutterSecureStorage();

  // ======================
  // CREATE ACCOUNT
  // ======================
  Future<dynamic> register({
    required String firstname,
    required String lastname,
    required String phone,
    required int countryID, 
    required String email,
    required String password,
    required String? sex,

    required String company,
    required String role
    
  }) async {
    final url = Uri.parse('${_env.endpoint}/api/auth/signup');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({ 
        'email': email,
        'password': password,  
        "firstName": firstname,
        "lastName": lastname,
        "phone": phone, 
        "country": countryID,
        "sexe": sex,
        "company": company,
        "role": role
      }),
    );

  }



  Future<dynamic> continueGoogleSignup({
    required String firstname,
    required String lastname,
    required String phone,
    required int countryID, 
    required String email, 
    required String? sex,
    required String? photoURL,

    required String company,
    required String role

    

    
  }) async {
    final url = Uri.parse('${_env.endpoint}/api/auth/signup/google');

    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({ 
        'email': email, 
        "firstName": firstname,
        "lastName": lastname,
        "phone": phone, 
        "country": countryID,
        "sexe": sex,
        "photoURL": photoURL,
        "company": company,
        "role": role
      }),
    );

  }
  


  Future<dynamic> updateInfo({
    required String firstname,
    required String lastname,
    required String phone,
    required int countryID,
    required String sexe,
    required String company,
    required String role,
    
  }) async {


    print(lastname);

    final url = Uri.parse('${_env.endpoint}/api/auth/update-info');

    String? token = await _storage.read(key: 'token');  
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({  
        "firstName": firstname,
        "lastName": lastname,
        "phone": phone, 
        "country": countryID,
        "sexe": sexe,
        "company": company,
        "role": role
      }),
    );

  }



  Future<http.Response> updateAccountFCM({
    required String fcm
  }) async {
    final url = Uri.parse('${_env.endpoint}/api/auth/update-fcm');

    String? token = await _storage.read(key: 'token');  
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({  
        "fcm": fcm
      }),
    );

  }
  







  

  // ======================
  // LOGIN
  // ======================
   Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${_env.endpoint}/api/auth/signin');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = data['token'];
      final user = jsonEncode(data['user']);

      await _storage.write(key: 'token', value: token);
      await _storage.write(key: 'user', value: user);

      return AuthResponse(
        success: true,
        message: 'Success',
        token: token,
        user: data['user'],
      );
    } else {
      return AuthResponse(
        success: false,
        message: data['message'] ?? 'Authentication failed',
      );
    }
  }


    Future<http.Response> deleteEventooAccount(String password) async {
    final url = Uri.parse('${_env.endpoint}/api/auth/delete-my-account'); 
    final lang = MyApp.currentLanguage;

    String? token = await _storage.read(key: 'token');  
    return http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': lang,
      },
      body: jsonEncode({
        'password': password
      }),
    );
  }





   Future<AuthResponse> loginWithGoogle({
    required String email
  }) async {
    final url = Uri.parse('${_env.endpoint}/api/auth/signin/google');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        
      },
      body: jsonEncode({
        'email': email,
        'google': true,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = data['token'];
      final user = jsonEncode(data['user']);

      await _storage.write(key: 'token', value: token);
      await _storage.write(key: 'user', value: user);

      return AuthResponse(
        success: true,
        message: 'Success',
        token: token,
        user: data['user'],
      );
    } else {
      return AuthResponse(
        success: false,
        message: data['message'] ?? 'Authentication failed',
      );
    }
  }
  

  // ======================
  // LOGOUT
  // ======================
  static Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');
  }

  // ======================
  // TOKEN MANAGEMENT
  // ======================
  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }


   Future<http.Response> getUserInfo() async {

    String? token = await _storage.read(key: 'token'); 
    
    final url = Uri.parse('${_env.endpoint}/api/auth/info'); 
    return  http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }, 
    ); 
  }



  Future<http.Response> sendVerifyEmail( String email ) async {
 
    final url = Uri.parse('https://eventoo.io/api/auth-eventoo-user/verify-eventoo-user-email'); 
    return  http.post(
      url,
      headers: {
        'Content-Type': 'application/json', 
      }, 
      body: jsonEncode({
        'email': email
      }),
    ); 
  }



  Future<http.Response> sendVerification( String email ) async {
 
    final url = Uri.parse('https://eventoo.io/api/auth-eventoo-user/reset-password'); 
    return  http.post(
      url,
      headers: {
        'Content-Type': 'application/json', 
      }, 
      body: jsonEncode({
        'email': email
      }),
    ); 
  }


  Future<http.Response> verifyResetCode( String email, String code ) async {

    String? token = await _storage.read(key: 'token'); 
    
    final url = Uri.parse('${_env.endpoint}/api/auth/verify-reset-code'); 
    return  http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }, 
      body: jsonEncode({
        'email': email,
        'code': code
      }),
    ); 
  }



  Future<http.Response> newPassword( String email, String code, String newPassword ) async {

    String? token = await _storage.read(key: 'token'); 
    
    final url = Uri.parse('${_env.endpoint}/api/auth/new-password'); 
    return  http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }, 
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword
      }),
    ); 
  }





 
}

// ======================
// AUTH RESPONSE MODEL
// ======================
class AuthResponse {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });
}
