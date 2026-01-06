import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/user_profile_model.dart';
import 'package:mobile/services/event_service.dart';
import 'package:mobile/widgets/participant_dynamic_secondary_form.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  UserProfile profile = UserProfile(
    photoUrl: 'https://i.pravatar.cc/300?img=33',
    fullName: 'John Anderson',
    email: 'john.anderson@example.com',
    profileLabel: 'Software Engineer',
    country: Country(id: 0, name: "...", icon: "icon"), 
    phone: "...",
    sex: 1,
    feilds: []

  );

  EventService _eventService = EventService();
  bool loading = true;

  File? _image;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initProfile();
  }



  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context);
    final ImagePicker picker = ImagePicker();

    // 1️⃣ Pick image
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return;

    
    if (picked != null) {


      setState(() {
        loading= true;
      });

      _image = File(picked.path);

      _eventService.updateEventProfilePhoto(_image!).then((res){
        setState(() {
          loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(l10n.profileInfoUpdated )),
        );
        
        
      });

      
    }
  }

  void _editProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(
        profile: profile,
        onSave: (data) {
          print("DATA:");
          print(data);

          setState(() {
            loading = true;
          });
          // SEND DATA VIA API
          _eventService.updateSecondaryInfo( data).then((res){
            dynamic body = jsonDecode(res.body);
            print(body);
            initProfile();
          });
           
          
        },
      ),
    );
  }


  void initProfile(){
      
      _eventService.getEventProfileDATA().then((res){

        dynamic data = jsonDecode(res.body);
  
        setState(() {
          loading = false;
          profile = UserProfile.fromJson(data['data']);
        });
      });
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);


    return Scaffold(
      
      body: 

        loading == true ?
          Center(
            child: CircularProgressIndicator(),
          )
        :
        
        SingleChildScrollView(
        child: 
        
        Column(
          children: [
            const SizedBox(height: 20),
            // Profile Photo
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6C63FF),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(profile.photoUrl),
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Primary Info
            Text(
              profile.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.profileLabel,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ), 
            
            InkWell(
  borderRadius: BorderRadius.circular(30),
  onTap: _editProfile,
  child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF2196F3),
          Color(0xFF21CBF3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: const Icon(
      Icons.edit,
      color: Colors.white,
      size: 22,
    ),
  ),
)
,
          const SizedBox(height: 30),


            // Primary Information Card
            _buildInfoCard(
              l10n.accountInformations ,
              [
                _buildInfoRow(Icons.email,  l10n.email, profile.email),
                _buildInfoRow(Icons.phone, l10n.phone, profile.phone),
                _buildInfoRow(Icons.person, l10n.profile, profile.profileLabel),
                _buildInfoRow(Icons.flag, l10n.country , profile.country.name),
                
                
              ],
              
            ),

            // Secondary Information Card
            _buildInfoCard(
              l10n.additonalDetails ,
               [
               ...profile.feilds.map(
                    (f) => _buildInfoRow(
                      Icons.list_outlined,
                      f.label,
                      f.value ??
                          (f.multipleValuesSelected != null
                              ? f.multipleValuesSelected!.join(', ')
                              : ''),
                    ),
                  )

               ]
            ),

            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class EditProfileSheet extends StatefulWidget {
  final UserProfile profile;
  final Function(dynamic) onSave;
  final dynamic tabSubmitFN;


  const EditProfileSheet({
    super.key,
    required this.profile,
    required this.onSave, this.tabSubmitFN,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late TextEditingController _nameController;  
  late TextEditingController _phoneController;  
  

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }



  

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    

    List<ParticipantField> _formFeilds =
    widget.profile.feilds.map((f) {
      return ParticipantField(
        id: f.id,
        label: f.label,
        type: f.type,
        value: f.value,
        feildValues: f.feildValues,
        multipleValuesSelected: f.multipleValuesSelected,
        showOnBadge: f.showOnBadge,
        showOnParticipantListPage: f.showOnParticipantListPage,
        showOnParticipantPage: f.showOnParticipantPage,
        showOnNetworkingApp: f.showOnNetworkingApp,
        showOnNetworkingExperienceFilters:  f.showOnNetworkingExperienceAppFilters,
      );
    }).toList();
 
    return Container(
     
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
           Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              l10n.editProfile,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: 
              ParticipantDynamicSecondaryForm(
                phone: widget.profile.phone,
                fullname: widget.profile.fullName,
                 fields: _formFeilds,
                 onSubmit:(payload){
                  
                  widget.onSave( payload );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text( l10n.profileInfoUpdated )),
                  );
                  

                  // SEND API TO SERVER

                  //
              })

              
              
              /*Column(
                children: [
                  _buildTextField(l10n.firstName , _nameController, Icons.person),
                  const SizedBox(height: 16),

                  _buildTextField(l10n.phone , _phoneController, Icons.phone),
                   
                   
                 
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.profile.fullName = _nameController.text;   
                        widget.profile.phone = _phoneController.text;  
                        widget.onSave(widget.profile);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(content: Text( l10n.profileInfoUpdated )),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:  Text(
                        l10n.submit,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),*/
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
        ),
      ),
    );
  }
}
