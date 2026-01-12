import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:mobile/main.dart';
import 'package:mobile/services/config.dart';
import 'dart:ui' as ui;



/// Service for handling event-related API calls
class EventService {
  final ServiceEnv _env = ServiceEnv();
  static const _storage = FlutterSecureStorage();
  
    
  Future<Response> getEventRegistrationForm(String profileID) async {
   
    
    final lang = MyApp.currentLanguage; 
    final url = Uri.parse('${_env.endpoint}/api/events/get-event-form/profile/$profileID');
    String? token = await _storage.read(key: 'token');
    
    return get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': lang,
      },
    );
  }


  Future<StreamedResponse> uploadImage(File imageFile) async {

    String? userTEXT = await _storage.read(key: 'user'); 
      
    dynamic user = jsonDecode(userTEXT!);

    print("TRYING TO CHANGE PHOTO FOR PARTICIPANT N°");
    print(user['id']);

    final uri = Uri.parse('https://eventoo.io/eventoo-platform/account/update/upload-photo/mobile-app/${ user["id"] }');

    print(uri.toString()); 
    final request = MultipartRequest('POST', uri);
    request.files.add(
      await MultipartFile.fromPath(
        'photo',
        imageFile.path,
      ),
    );

    // Example auth header
    // request.headers['Authorization'] = 'Bearer ${token}';

    return request.send();
 
  }



    Future<StreamedResponse> updateEventProfilePhoto(File imageFile) async {

    String? participantID = await _storage.read(key: 'participantId'); 

    print("TRYING TO CHANGE PHOTO FOR PARTICIPANT N°");
    print( participantID );

    final uri = Uri.parse('https://eventoo.io/eventoo-platform/event-update-profile-photo/upload-photo/mobile-app/${ participantID }');

    print(uri.toString()); 

    final request = MultipartRequest('POST', uri);
    request.files.add(
      await MultipartFile.fromPath(
        'photo',
        imageFile.path,
      ),
    );

    // Example auth header
    // request.headers['Authorization'] = 'Bearer ${token}';

    return request.send();
 
  }

  


  


    Future<Response> getParticipantTypes(String eventId) async {
    
    final lang = MyApp.currentLanguage; 
    final url = Uri.parse('${_env.endpoint}/api/events/participant-types/$eventId');
    String? token = await _storage.read(key: 'token');
    
    return get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': lang,
      },
    );
  }

  /// Create event account with form data
  /// 
  /// Submits registration data and creates account
  Future<Response> createEventAccount({
    required String profileID,
    required Map<String, dynamic> formData,
  }) async { 
     
    final url = Uri.parse('${_env.endpoint}/api/events/api/events-register/$profileID');
    String? token = await _storage.read(key: 'token');
    
    return post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'eventId': profileID,
        'formData': formData,
      }),
    );
  }



  Future<Response> authToEvent({
    required int eventID
  }) async { 
     
    final url = Uri.parse('${_env.endpoint}/api/events/auth-event');
    String? token = await _storage.read(key: 'token');
    
    return post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'eventID': eventID
      }),
    );
  }



  
  Future<Response> getCurrentConnectedEventDetails() async {
    final url = Uri.parse('${_env.endpoint}/api/events/current-event'); 

    String? token = await _storage.read(key: 'token'); 
    String? participantID = await _storage.read(key: 'participantId'); 

    print("TRYING TO AUTH PARTICIPANT N°");
    print(participantID);
    
 
    return post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'participantID': participantID
      }),
    );
  }








  /// Get event details
  Future<Response> getEventDetails(String eventId) async {
    final url = Uri.parse('${_env.endpoint}/api/events/$eventId');
    String? token = await _storage.read(key: 'token'); 
    return get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Get user's event registrations
  Future<Response> getUserEventRegistrations() async {
    final url = Uri.parse('${_env.endpoint}/api/events/event-registrations');
    String? token = await _storage.read(key: 'token');
    
    return get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

    Future<Response> getCurrentEvents() async {
      final url = Uri.parse('${_env.endpoint}/api/events/currents');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    }

    
    Future<Response> getCalendarDetails( String participantID) async {
      print("PARTICIPANTID");
      print(participantID);
      
      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/calendar/details');
      String? token = await _storage.read(key: 'token');
      
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
        'participantID': participantID
      }),
      );
    }
 


     Future<Response> sendRoomProgramChatMessage( int programID, String message ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/calendar/send-chat-message');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
        'programID': programID,
        'message': message,
        'participantID': participantID
      }),
      );
    }



    
     Future<Response> sendDirectMessage( int target, String content) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/messaging/direct');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
          'me': participantID,
          'target': target,
          'content':content
        }),
      );
    }



    
     Future<Response> getUnreadedMessages() async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/messaging/fetch/unreaded/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }




    Future<Response> fetchMessagesProgramRoom( int programID ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/calendar/chat/room/${programID}/participant/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }


    Future<Response> getNotifications( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/events/notifications/participant/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }
 

    Future<Response> updateNotification( int id ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/events/notifications/update');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
        'id': id
      }),
      );
    }



    Future<Response> updateSecondaryInfo(  dynamic data ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/participants/update-secondary-info');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
        'participand_id': participantID,
        'data':data
      }),
      );
    }



    Future<Response> addParticipantToMyFavoutites(  int id, String notice ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/participants/add-to-my-favourites');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
        'me': participantID,
        'target':id,
        'notice':notice
      }),
      );
    }




    Future<Response> removeParticipantFromContactList( int target) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/participants/remove-contact');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
        'me': participantID,
        'target':target
      }),
      );
    }



    
    Future<Response> scanQRID( String userID ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/participants/qr/scan');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
          'me': participantID,
          'userID':userID
        }),
      );
    }

    



      

    Future<Response> getEventProfileDATA( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage; 
      final url = Uri.parse('${_env.endpoint}/api/participants/me/participant/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }
 
    
    Future<Response> getParticipants({String? keywords}) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;
      String? token = await _storage.read(key: 'token');

      final uri = Uri.parse(
        '${_env.endpoint}/api/participants/list/$participantID',
      ).replace(
        queryParameters: {
          if (keywords != null && keywords.trim().isNotEmpty)
            'keywords': keywords.trim(),
        },
      );

      return get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang,
        },
      );
    }



    Future<Response> getEventProfiles( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;  
      final url = Uri.parse('${_env.endpoint}/api/events/profiles/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }

    
    Future<Response> getMyBadgeSetting( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   

      final url = Uri.parse('${_env.endpoint}/api/events/badge-setting/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }


        
    Future<Response> myContacts( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   

      final url = Uri.parse('${_env.endpoint}/api/participants/my-contacts');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }



    Future<Response> expositionScreen( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   

      final url = Uri.parse('${_env.endpoint}/api/events/exposition/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }


    Future<Response> fetchChats( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   

      final url = Uri.parse('${_env.endpoint}/api/messaging/chats/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }

    /************************************* NETWORKING EXPERIECNE********************************************** */


    Future<Response> networkingExperienceProfiles( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/profiling/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }


  
  Future<Response> getNetworkingExperienceAdvancedFilters(int profile) async {
    final lang = MyApp.currentLanguage;
    String? token = await _storage.read(key: 'token');
    String? participantID = await _storage.read(key: 'participantId');

    
    try {
      final uri = Uri.parse('${_env.endpoint}/api/networking/filters/$profile');

      final response = await get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Failed to load advanced filters: $e');
    }
  }


    

    Future<Response> networkingExperienceParticipants( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/participants/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }

    
    Future<Response> networkingExperienceMyRoles( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/my-profile-roles/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }


    Future<Response> networkingExperienceDates( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/dates/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }


    Future<Response> networkingTimeSlots( int target, int dateID ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/time-slots');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
          'me': participantID,
          'target':target,
          "dateID": dateID  
        }),
      );
    }




    Future<Response> networkingLocations( int target) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/locations/${participantID}/participant/${target}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }



    Future<Response> networkingSendInvitation( int target, int date, String time, int location ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/send-invitation');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
            "me": participantID, 
            "target": target, 
            "date": date, 
            "time": time, 
            "location" : location
              
        }),
      );
    }



    
    Future<Response> networkingReSendInvitation( int oldInvitationID, int date, String time, int location ) async {

      print(oldInvitationID);
      

      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/re-send-invitation');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
            "me": participantID, 
            "oldInvitationID": oldInvitationID, 
            "date": date, 
            "time": time, 
            "location" : location 
        }),
      );
    }


    
 


     Future<Response> myInvitations(  ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/my-invitations/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }

    Future<Response> updateInvitationStatus( int invitationID , int actionIndex, int? newdateID, String? newTime ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/update-invitation-status');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
          'participant': participantID,
          'id': invitationID,
          'action': actionIndex,
          'new_date_id': newdateID,
          'new_time': newTime
        }),
      );
    }



    Future<Response> fetchInvitationNativeDATA( int invitationID) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/invitation/data/${invitationID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }




    Future<Response> myPlanning(  ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/my-planning/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }
 
  

  
    

    Future<Response> sendBusinessCardRequest( int target ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/send-business-card-request');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
            "me": participantID, 
            "target": target
              
        }),
      );
    }


    Future<Response> myBusinessCardsInvitations(  ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/my-business-cards/${participantID}');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }



    Future<Response> handleBusinessCardRequest( int invitationID , int actionIndex) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/update-business-card-status');
      String? token = await _storage.read(key: 'token');
      
      return post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        },
        body: jsonEncode({
          'id': invitationID,
          'action': actionIndex
        }),
      );
    }


    Future<Response> myBusinessCardsContacts( ) async {
      String? participantID = await _storage.read(key: 'participantId');

      final lang = MyApp.currentLanguage;   
      
      final url = Uri.parse('${_env.endpoint}/api/networking/my-business-cards-contacts');
      String? token = await _storage.read(key: 'token');
      
      return get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang
        }
      );
    }

    

 
 
    


    /*********************************************************************************** */
  

    

    Future<Response> searchParticipants({
    String? fullName,
    String? profile,
    String? country,
    int page = 1,
    int limit = 10,
    Map<int, dynamic>? advancedFilters,
  }) async {

    String? participantID = await _storage.read(key: 'participantId'); 
    final lang = MyApp.currentLanguage;
    String? token = await _storage.read(key: 'token');

      
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (fullName != null && fullName.isNotEmpty) {
        queryParams['fullName'] = fullName;
      }

      if (profile != null && profile.isNotEmpty) {
        queryParams['profile'] = profile;
      }

      if (country != null && country.isNotEmpty) {
        queryParams['country'] = country;
      }

      // Add advanced filters
      if (advancedFilters != null && advancedFilters.isNotEmpty) {
        advancedFilters.forEach((fieldId, value) {
          if (value != null) {
            if (value is List) {
              queryParams['filter_$fieldId'] = jsonEncode(value);
            } else {
              queryParams['filter_$fieldId'] = value.toString();
            }
          }
        });
      }

      final uri = Uri.parse('${_env.endpoint}/api/participants/search/${participantID}')
          .replace(queryParameters: queryParams);

      final response = await get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Failed to search participants: $e');
    }
  }

  // Get advanced filters for a specific profile
  Future<Response> getAdvancedFilters(int profile) async {
    final lang = MyApp.currentLanguage;
    String? token = await _storage.read(key: 'token');
    String? participantID = await _storage.read(key: 'participantId');

    
    try {
      final uri = Uri.parse('${_env.endpoint}/api/events/filters/$profile');

      final response = await get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept-Language': lang,
        },
      );

      return response;
    } catch (e) {
      throw Exception('Failed to load advanced filters: $e');
    }
  }



  Future<Response> getCountriesList()  {
    final url = Uri.parse('${_env.endpoint}/api/events/countries'); 
    return get(
      url,
      headers: {
        'Content-Type': 'application/json',
      }, 
    );
    
  }







  


 
    
}

