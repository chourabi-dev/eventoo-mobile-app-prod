// ============================================================================
// MEETING INVITATION DIALOG
// ============================================================================
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/api_networking_date.dart';
import 'package:mobile/models/participant_model.dart';
import 'package:mobile/services/event_service.dart';

class MeetingInvitationDialog extends StatefulWidget {
  final Participant participant;
  const MeetingInvitationDialog({super.key, required this.participant});

  @override
  State<MeetingInvitationDialog> createState() =>
      _MeetingInvitationDialogState();
}

class _MeetingInvitationDialogState extends State<MeetingInvitationDialog> {
  ApiDate? _selectedDate;
  ApiLocation? _selectedLocation;
  String? _selectedTime;


  bool loadingDates = true;
  bool loadingTimeSlots = false;
  bool loadingLocations = true;
  
  

  /// 🔁 Normally fetched from API
   List<ApiDate> availableDates = [];

   List<ApiLocation> locations = [];

   List<ApiTime> timeSlots =  [];

   EventService eventService = EventService();


   @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDates();
    fetchLoacations();
  }

  void fetchDates() {
    eventService.networkingExperienceDates().then((res) {
      final body = jsonDecode(res.body);

      final List<ApiDate> tmp = (body['dates'] as List)
          .map((e) => ApiDate.fromJson(e))
          .toList();

      setState(() {
        loadingDates = false;
        availableDates = tmp;
      });
    });
  }


  void fetchTimeSlots(){  
    setState(() {
      loadingTimeSlots = true;
      timeSlots = [];
      _selectedTime = null;
    });

    eventService.networkingTimeSlots(widget.participant.id, int.parse(_selectedDate!.id) ).then((res){
      dynamic body = jsonDecode(res.body);

      if( body['success'] == true ){

        final List<String> tmp = (body['slots'] as List)
          .map((e) => e.toString())
          .toList();

          List<ApiTime> slots = [];

          for (var i = 0; i < tmp.length; i++) {

            slots.add(ApiTime(id: tmp[i], time: tmp[i]));
          }

          setState(() {
            timeSlots = slots;
            loadingTimeSlots = false;
          }); 
      } 
      
    }).catchError((err){
      setState(() { 
        loadingTimeSlots = false;
      });
 
    });

  }

  void fetchLoacations(){
    eventService.networkingLocations(widget.participant.id).then((res){
      dynamic body = jsonDecode(res.body);
 

       if( body['success'] == true ){
        final List<ApiLocation> tmp = (body['locations'] as List)
          .map((e) => ApiLocation.fromJson(e))
          .toList();


          setState(() {
            locations = tmp;
            loadingLocations = false;
          });

       }

    });
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    


    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
                Text( 
                l10n.scheduleMeeting,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              /// 📅 Date Dropdown
              Text( l10n.dateLabel ),
              const SizedBox(height: 8),

              loadingDates== true?
              Container( 
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Center(child: CircularProgressIndicator(),)
              )
              :
              ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 250), // adjust as needed
              child: DropdownButtonFormField<ApiDate>(
                isExpanded: true, // important!
                value: _selectedDate,
                items: availableDates.map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(
                      d.date,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ).toList(),
                onChanged: (value){
                  setState(() => _selectedDate = value);

                  // fetch time slots if value is not null

                  if( value != null ){
                    // call time slots fetch
                    fetchTimeSlots();
                    
                  }
                },
                decoration: _inputDecoration(Icons.calendar_today),
              ),
            ),



              const SizedBox(height: 20),

              /// ⏰ Time badges
              Text( l10n.timeLabel ),
              const SizedBox(height: 8),

              loadingTimeSlots == true ?

              Container( 
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Center(child: CircularProgressIndicator(),)
              )
              :

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: timeSlots.map((time) {
                  final bool selected = _selectedTime == time.time;
                  return ChoiceChip(
                    label: Text(time.time),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedTime = time.time);
                    },
                    selectedColor: const Color(0xFF6C63FF),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              /// 📍 Location Dropdown
              Text( l10n.locationLabel ),
              const SizedBox(height: 8),

              loadingLocations == true ?
              Container( 
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: Center(child: CircularProgressIndicator(),)
              )
              :
              DropdownButtonFormField<ApiLocation>(
                value: _selectedLocation,
                items: locations
                    .map(
                      (l) => DropdownMenuItem(
                        value: l,
                        child: Text(l.location),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedLocation = value),
                decoration: _inputDecoration(Icons.location_on),
              ),

              const SizedBox(height: 30),

              /// 🔘 Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.close, style: TextStyle(fontSize: 12), ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text( l10n.sendLabel, style: TextStyle(fontSize: 12), ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: CircularProgressIndicator(),
    ),
  );
}


void showSuccessDialog(BuildContext context, String message) {
   final l10n = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child:  Text(l10n.close),
        ),
      ],
    ),
  );
}

void showErrorDialog(BuildContext context, String message) {
  final l10n = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (_) => AlertDialog( 
      content:  Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info, color: Colors.amber, size: 64),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text( l10n.close ),
        ),
      ],
    ),
  );
}





  void _submit() {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }else{ 


      showLoadingDialog(context);

      eventService.networkingSendInvitation(widget.participant.id, int.parse(_selectedDate!.id) ,  _selectedTime!, int.parse(_selectedLocation!.id)  ).then((res){
        dynamic body = jsonDecode(res.body);
        print(body);
        
        if( body['success'] == true ){
           Navigator.pop(context);
           
           showSuccessDialog(
            context,
            body['message'] ?? 'Invitation sent successfully',
          );
          

        }else{
          Navigator.pop(context);
          showErrorDialog(
            context,
            body['message'] ?? 'Network error. Please try again.',
          );
           

        }

      }).catchError((err){
        
         Navigator.pop(context);

         showErrorDialog(
            context,
             'Network error. Please try again.',
          );

      });
 
    }

   
  }


  InputDecoration _inputDecoration(IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
