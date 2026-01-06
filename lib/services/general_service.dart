import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/services/config.dart';
import 'package:http/http.dart';

class GeneralGervice {
  ServiceEnv _env = ServiceEnv();
  static const _storage = FlutterSecureStorage();

  
 
  Future<Response> getCountriesList()  {
    final url = Uri.parse('${_env.endpoint}/api/general/countries'); 
    return get(
      url,
      headers: {
        'Content-Type': 'application/json',
      }, 
    ); 
  }

    Future<Response> getEvents() async  {
      final url = Uri.parse('${_env.endpoint}/api/events/list'); 
      String? token = await _storage.read(key: 'token');  
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token' 
        }, 
      ); 
  }
  

}