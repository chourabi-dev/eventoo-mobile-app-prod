import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'welcome': 'Welcome',
      'home_screen_subtitle': "Event management platform",
      'discover_events': 'Discover amazing events',
      'pick_event': 'Pick an Event',
      'sign_in': 'Sign In',
      'sign_up': 'Sign Up',
      'sign_up_label':"Sign Up",
      'sign_in_continue': 'Sign in to continue',
      'sign_up_continue': 'Sign up to continue',
      'email': 'Email',
      'enter_email': 'Enter your email',
      'enter_valid_email': "Please enter a valid email",
      'password': 'Password',
      'enter_your_password': 'Enter your password',
      'password_error': 'Password must be at least 6 characters',
      'forget_password': 'Forget password?',
      'dont_have_account': "Don't have an account?",
      'first_name': 'First Name',
      'enter_first_name': 'Enter your first name',
      'last_name': 'Last Name',
      'enter_last_name': 'Enter your last name',
      'phone': 'Phone',
      'enter_your_phone': 'Enter your phone number',
      'country': 'Country',
      'select_country': 'Select your country',
      'bad_cridentials': "Wrong email or password.",
      'server_error': "Une erreur s'est produite, veuillez réessayer plus tard.",
      'email_already_in_use':"Email already in use",
      'recommanded_for_you':'Recommended for you',
      'update_my_profile':'Update my profile',
      'profile_data_updated':"Your information are successfully updated",
      'joined_events':"Joined events",
      'quick_actions':"Quick Actions",
      'edit_profile':"Edit Profile",
      'settings_label':"Settings",
      'see_all':'See All',
      "hybrid_label": "Hybrid",
      "physical_label": "Physical",
      "virtual_label": "Virtual",
      "unknown_label": "Unknown",
      "select_profile_label": "Please select a profile",
      "choose_profile_label": "Choose Your Profile",
      "pick_profile_description": "Select the participant type that best describes you. Each type has different registration requirements and benefits.",
      "continue_label":"Continue",
      "event_registration":"Event Registration",
      "submit_label":"Submit",
      "next_label" :"Next",
      "previous_label" :"Previous",
      "submiting_label": "Creating account...",
      "registration_success_label": "Registration Successful!",
      "registration_success_message":'Your event account has been created successfully. You can now access all event features.',
      "view_event_details":"View event details",
      "back_to_events":"Back to events",
      "logout_label":"Logout",
      "sex": "Civility",
      "male": "Sir",
      "female": "Madam",
      "selectSex": "Please select your sex",
      "more_events":"More events",
      "calendar_label":"Calendar",
      "live_label":"LIVE",
      "programs_label":"Program(s)",
      "description_label":"Description", 
      "sponsors_label":"Sponsors",
      "participants_label":"Participants",
      "moderators_label":"Moderators",
      "exhibitors_label":"Exhibitors",
      "live_chat_label":'Live Chat',
      "join_the_conversation":"Join the conversation",
      "no_messages_yet": "No messages yet",
      "watch_live":"Watch live",
      "new_label":"new",
      "no_notifications_label":  'No notifications yet',
      "account_informations_label": "Account informations",
      "profile_label": "Profile",
      "search_participants_label":"Search Participants",
      "search_participants_placeholder_label":"Search by name...",
      "no_participant_found_label": "No participants found",
      "profile_updated_successfully": "Profile updated successfully",
      "add_to_favoutes":"Save",
      "added_to_favoutes":"Participant added to your favourites",
      "explore_more_events": "Explore More Events",

      "forgot_password_label":"Forgot password?",
      "forgot_password_description":"Enter you email address and we'll send you a varification code",
      "send_validation_code":"Send code",
      "back_to_login":"Back to login",

      "verify_code_label":"Verify Code",
      "verify_code_description":"Enter the 6-digit code sent to",
      "verify_code_btn":"Verify Code",
      
      "reset_password":"Reset Password",
      "reset_password_description":"Create a new password for your account",
      "new_password":"New password",
      "confirm_new_password":"Confirm password",
      "reset_password_btn":"Reset Password",

      "reset_success_label":"Success!",
      "reset_success_description":"our password has been reset successfully.",
      "reset_success_back_to_login":"Back To Login",
      "searchParticipant_label":"Search participants...",
      "clear_label":"clear",
      "loading_participants_label":'Loading participants...',
      "advanced_filters_label": "Advanced Filters",
      "select_option_label":"Select an option",
      "apply_filters":"Apply Filters",
      "additonal_details":"Additonal details",
      "badge_options":"Badge Options",
      "show_badge":"Show Badge",
      "scan_qr_badge":"Scan Participant badge", 
      


      "loading_participant_label":"Loading participant data ...", 
      "connect_label":"Connect", 
      "close_label":"Close", 
      "error_loading_participant_label":"Error loading participant", 
      "participant_not_found_label":"Error loading participant", 
      "scan_badge_label":"Scan Badge", 
      "scan_instructions_label":"Align QR code within the frame", 
      "sign_in_with_google":"Sign in with Google",
      "sign_up_with_google":"Sign up with Google",

      "my_contacts_label":"My contacts", 
      "remarque_label":"Notice",

      "add_to_fav_label":"Add to favorites",
      "add_to_fav_descritpion":"Do you want to add this participant to your contacts?",
      "notice_label":"Notice(optionnal)",
      "notice_description":"Add a personal note",
      "cancel_label":"Cancel",
      "confirm_label":"Confirl", 
      "retry_label":"retry",
      "results_label":"result(s)",
      
      "event_label":"Event",
      "date_label":"Date", 
      "no_stand_available":"No stands available",
      "networking_label":"Networking",
      "type_a_message":"Type a message...",
      "chats_label":"Chats",
      "all_label":"All",
      "recommendations_label":"Recommendations",
      "my_meetings_label":"My meetings",
      "my_invitations_label":"My invitations",
      "send_invitation_label":"Send Meeting invitation",
      "request_business_card_label":"Request Business Card", 
      "schedule_meeting_label":"Schedule Meeting",
      "time_label": "Time",
      "location_label":"Location",
      "send_label":"Send",
      "home_label":"Home",
      "noIncomingInvitations_label": "No incoming invitations",
      "noOutgoingInvitations_label": "No outgoing invitations",
      "reject_label": "Reject",
      "reschedule_label": "Reschedule",
      "accept_label": "Accept",
      "accepted_label": "Accepted",
      "rejected_label": "Rejected",
      "pending_label": "Pending",
      "incoming_label": "Incoming",
      "outgoing_label": "Outgoing",
      "processing_label": "Processing",
      
      "invitation_accepted_label": "Invitation accepted",
      "invitation_rejected_label": "Invitation rejected",
      "invitation_escheduled_label": "Invitation rescheduled", 
      "replanification_label": "Rescheduling", 
      "today_label":"Today",
      "tomorrow_label":"Tomorrow",
      "exposers_label":"Exhibitors",
      "business_card_exchange":"Business cards",
      "no_incoming_business_cards":"No incoming business cards requests",
      "no_utgoing_business_cards":"no outgoing business cards",
      "call_label":"Call",

      "email_equired_validation_title":"Email verification required",
      "email_equired_validation_content":"You must verify your email address before you can start using the app.\n Please check your inbox and confirm your email.",
      "email_equired_validation_button":"Resend verification email",  
      "refresh_label":"Refresh",

      "finish_signup":"Finish",

      "finish_signup_text":"Finish sign up by filling the missing informations",
      "all_rooms_label":"All Rooms",
      "google_sign_in_faild_no_account":"This email is not registred in our system. try creating account first.",
      "google_sign_in_faild":"Something went wrong trying to sign in using googlge services. please try again.",

      "or_text_separator":"OR",
      "my_events_label":"My events",

      "no_events_content":"You haven't registered for any events yet.",
      "no_events_label":"No events yet",
      "delete_my_account":"Delete my account",
      "delete_account_warning":"This action is permanent. Deleting your account will remove all your data and cannot be undone.",
      "company_label": "Company",
      "function_label": "Occupation",
      "my_events_subtitle":"In which I am registered",
      "more_events_subtitle":"Which I am not yet \nregistered for",
      
      
   

 

    },
    'fr': {
      'welcome': 'Bienvenue',
      'home_screen_subtitle': "Plateforme de gestion d'événements",
      'discover_events': 'Découvrez des événements incroyables',
      'pick_event': 'Choisir un Événement',
      'sign_in': 'Se Connecter',
      'sign_up': "S’inscrire avec e-mail",
      'sign_up_label': "S’inscrire",
      'sign_in_continue': 'Connectez-vous pour continuer',
      'sign_up_continue': "Inscrivez-vous pour continuer",
      'email': 'Email',
      'enter_email': 'Saisissez votre adresse e-mail',
      'enter_valid_email': "Veuillez saisir une adresse e-mail valide",
      'password': 'Mot de passe',
      'enter_your_password': 'Saisissez votre mot de passe',
      'password_error': 'Le mot de passe doit comporter au moins 6 caractères.',
      'forget_password': 'Mot de passe oublié ?',
      'dont_have_account': "Vous n'avez pas de compte ?",
      'first_name': 'Prénom',
      'enter_first_name': 'Saisissez votre prénom',
      'last_name': 'Nom',
      'enter_last_name': 'Saisissez votre nom',
      'phone': 'Téléphone',
      'enter_your_phone': 'Saisissez votre numéro de téléphone',
      'country': 'Pays',
      'select_country': 'Sélectionnez votre pays',
      'bad_cridentials': "Adresse e-mail ou mot de passe incorrect.",
      'server_error':"Something went wrong, please try again later.", 
      'email_already_in_use':"Adresse e-mail déjà utilisée",
      'recommanded_for_you':'Recommandé pour vous',
      'update_my_profile':'Mettre à jour mon profil',
      'profile_data_updated':"Vos informations ont été mises à jour avec succès.",
      'quick_actions':'Actions Rapides',
      'joined_events':"Mes événements",
      'edit_profile':"Modifier le profil",
      'settings_label':"Paramètres",
      'see_all':'Voir tout',
      "hybrid_label": "Hybride",
      "physical_label": "Physique",
      "virtual_label": "Virtuel",
      "unknown_label": "Inconnu",
      "select_profile_label": "Veuillez sélectionner un profil",
      "choose_profile_label": "Choisissez votre profil",
      "pick_profile_description": "Sélectionnez le type de participant qui vous décrit le mieux. Chaque type a des exigences d'inscription et des avantages différents.",
      "continue_label":"Continuer",
      "event_registration":"Inscription à l'événement",
      "submit_label":"Valider",
      "next_label" :"Suivant",
      "previous_label" :"Précédent",
      "submiting_label": "Création d'un compte...",
      "registration_success_label": "Inscription réussie !",
      "registration_success_message":"Votre compte événementiel a été créé avec succès. Vous pouvez désormais accéder à toutes les fonctionnalités de l'événement.",
      "view_event_details":"Voir les détails de l'événement",
      "back_to_events":"Retour aux événements",
      "logout_label":"Déconnexion",
      "sex": "Civilité",
      "male": "Monsieur",
      "female": "Madame",
      "selectSex": "Veuillez choisir votre sexe",
      "more_events":"Plus d'événement",
      "calendar_label":"Agenda",
      "live_label":"En direct",
      "programs_label":"Programme(s)",
      "description_label":"Description",
      "sponsors_label":"Sponsors",
      "participants_label":"Participants",
      "moderators_label":"Modérateurs",
      "exposers_label":"Exposants",
      "live_chat_label":'Chat en direct',
      "join_the_conversation":"Rejoignez la conversation",
      "no_messages_yet": "Aucun message pour l'instant",
      "watch_live":"Regardez le direct",
      "new_label":"nouvelles notifications",
      "no_notifications_label":  'Aucune notification pour le moment',
      "account_informations_label": "Informations sur le compte",
      "profile_label": "Profil",
      "search_participants_label":"Recherche de participants",
      "search_participants_placeholder_label":"Recherche par nom...",
      "no_participant_found_label": "Aucun participant trouvé",
      "profile_updated_successfully": "Profil mis à jour avec succès",
      "add_to_favoutes":"Favoris",
      "added_to_favoutes": "Participant ajouté à vos favoris",
      "explore_more_events": "Découvrez plus d'événements",
      
      "forgot_password_label":"Mot de passe oublié ?",
      "forgot_password_description":"Saisissez votre adresse e-mail et nous vous enverrons un code de vérification",
      "send_validation_code":"Envoyer le code",
      "back_to_login":"Retour à la connexion",

      "verify_code_label":"Vérifier le code",
      "verify_code_description":"Saisissez le code à 6 chiffres envoyé à",
      "verify_code_btn":"Vérifier le code",

      "reset_password":"Réinitialiser le mot de passe",
      "reset_password_description":"Créer un nouveau mot de passe pour votre compte",
      "new_password":"Nouveau mot de passe",
      "confirm_new_password":"Confirmer le mot de passe",
      "reset_password_btn":"Réinitialiser le mot de passe",
      "reset_success_label":"Succès !",
      "reset_success_description":"Votre mot de passe a été réinitialisé avec succès.",
      "reset_success_back_to_login":"Retour à la page de connexion",
      "searchParticipant_label":"Recherche par nom...",
      "clear_label":"effacer",
      "loading_participants_label":'Chargement des participants...',
      "advanced_filters_label": "Filtres avancés",
      "select_option_label":"Sélectionnez une option",
      "apply_filters":"Appliquer les filtres",
      "additonal_details":"Plus d'informations",
      "badge_options":"Options de badge",
      "show_badge":"Afficher mon badge",
      "scan_qr_badge":"Scanner badge",
      
      "loading_participant_label":"Chargement des données du participant...",
      "connect_label":"Connexion",
      "close_label":"Fermer",
      "error_loading_participant_label":"Erreur lors du chargement du participant",
      "participant_not_found_label":"Erreur lors du chargement du participant",
      "scan_badge_label":"Scanner le badge",
      "scan_instructions_label":"Aligner le code QR dans le cadre",
      "sign_in_with_google":"Se connecter avec Google",
      "sign_up_with_google":"Inscrivez-vous avec Google",
      
      "my_contacts_label":"Mes contacts",
      "remarque_label":"Remarque",
       
       "add_to_fav_label":"Ajouter aux favoris",
       "add_to_fav_descritpion":"Voulez-vous ajouter ce participant à vos contacts ?",
       "notice_label":"Notification (facultatif)",
       "notice_description":"Ajouter une note personnelle",
       "cancel_label":"Annuler",
       "confirm_label":"Confirmer",
       "retry_label":"réessayer", 
       "results_label":"résultats", 
      "event_label":"Événement",
      "date_label":"Date",  
      "no_stand_available":"Aucun stand disponible",
      "networking_label":"Networking",
      "type_a_message":"Saisissez un message...",
      "chats_label":"Discussions",
      "all_label":"Tout",
      "recommendations_label":"Recommandations",
      "my_meetings_label":"Mes rendez-vous",
      "my_invitations_label":"Mes invitations",
      "send_invitation_label":"Demande rendez vous",
      "request_business_card_label":"Demande carte de visite",
      "schedule_meeting_label":"Planifier une réunion",
      "time_label": "Temps",
      "location_label":"Emplacement",
      "send_label":"Envoyer",
      "home_label":"Accueil",
      "noIncomingInvitations_label": "Aucune invitation reçue",
      "noOutgoingInvitations_label": "Aucune invitation envoyée",
      "reject_label": "Refuser",
      "reschedule_label": "Reprogrammer",
      "accept_label": "Accepter",
      "accepted_label": "Acceptée",
      "rejected_label": "Refusée",
      "pending_label": "En attente", 
      "incoming_label": "Reçues",
      "outgoing_label": "Envoyées",
      "processing_label": "En cours", 
      "invitation_accepted_label": "Invitation acceptée",
      "invitation_rejected_label": "Invitation refusée",
      "invitation_escheduled_label": "Invitation replanifiée",
      "replanification_label": "Replanification",  
      "today_label":"Aujourd’hui",
      "tomorrow_label":"Demain",
      "business_card_exchange":"Cartes de visite",
      "no_incoming_business_cards":"Aucune demande de cartes de visite entrantes",
      "no_utgoing_business_cards":"Aucune carte de visite sortante",
      "call_label":"Appelez", 
      "email_equired_validation_title":"Vérification de l'adresse e-mail requise",
      "email_equired_validation_content":"Vous devez vérifier votre adresse e-mail avant de pouvoir utiliser l'application.\nVeuillez consulter votre boîte de réception et confirmer votre adresse e-mail.",
      "email_equired_validation_button":"Renvoyer l'e-mail de vérification",
      "refresh_label":"Actualiser", 
      "finish_signup":"Terminer l'inscription", 
      "finish_signup_text":"Finalisez votre inscription en complétant les informations manquantes.",
      "all_rooms_label":"Toutes les salles",

      "google_sign_in_faild_no_account": "Cette adresse e-mail n’est pas enregistrée dans notre système. Veuillez d’abord créer un compte.",
      "google_sign_in_faild": "Une erreur est survenue lors de la tentative de connexion avec les services Google. Veuillez réessayer.",
      
      "or_text_separator":"OU",
      "my_events_label":"Mes événements",

      "no_events_content":"Vous n'êtes inscrit à aucun événement pour le moment.",
      "no_events_label":"Aucun événement pour le moment",
      "delete_my_account":"Supprimer mon compte",
      "delete_account_warning":"Cette action est définitive. La suppression de votre compte entraînera la perte de toutes vos données et ne pourra pas être annulée.",
      
      
      "company_label": "Entreprise",
      "function_label": "Fonction",
      "my_events_subtitle":"Dans lesquels je suis inscrit",
      "more_events_subtitle":"Dans lesquels je ne \nsuis pas encore inscrit",


 
      

  


          
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Existing getters
  String get welcome => translate('welcome');
  String get discoverEvents => translate('discover_events');
  String get pickEvent => translate('pick_event');
  String get signIn => translate('sign_in');
  
  String get companyLabel => translate('company_label');
  String get functionLabel => translate('function_label');
  

  
  String get signUp => translate('sign_up');
  String get signUpLabel => translate('sign_up_label');
  String get signInContinue => translate('sign_in_continue');
  String get signUpContinue => translate('sign_up_continue');
  String get email => translate('email');
  String get password => translate('password');
  String get enterYourEmail => translate('enter_email');
  String get enterYourPassword => translate('enter_your_password');
  String get enterValidEmail => translate('enter_valid_email');
  String get passwordError => translate('password_error');
  String get forgetPassword => translate('forget_password');
  String get dontHaveAccount => translate('dont_have_account');

  // New getters for signup fields
  String get firstName => translate('first_name');
  String get enterFirstName => translate('enter_first_name');
  String get lastName => translate('last_name');
  String get enterLastName => translate('enter_last_name');
  String get phone => translate('phone');
  String get enterYourPhone => translate('enter_your_phone');
  String get country => translate('country');
  String get selectCountry => translate('select_country');
  String get badCridential => translate('bad_cridentials');
  String get serverError => translate('server_error');
  String get enterAlreadyInUse => translate('email_already_in_use');
  String get recommandedForYou => translate('recommanded_for_you');
  String get updateMyProfile => translate('update_my_profile');
  String get profileDataUpdated => translate('profile_data_updated');
  String get joinedEvents => translate('joined_events');
  String get quickActions => translate('quick_actions');
  String get editProfile => translate('edit_profile');
  String get settings => translate('settings_label');
  String get seeAll => translate('see_all');
  
  String get hybrid => translate('hybrid_label');
  String get physical => translate('physical_label');
  String get virtual => translate('virtual_label');
  String get unknown => translate('unknown_label');
  String get selectProfile => translate('select_profile_label');
  String get chooseProfile => translate('choose_profile_label');
  String get pickProfileDescription => translate('pick_profile_description');
  String get continueLabel => translate('continue_label'); 
  String get eventRegistration => translate('event_registration'); 
  String get submit => translate('submit_label');
  String get next => translate('next_label');
  String get previous => translate('previous_label');
  
  String get submiting => translate('submiting_label');
  String get registrationSuccessLabel => translate('registration_success_label');
  String get registrationSuccessMessage => translate('registration_success_message');
   
  String get viewEventDeatils => translate('view_event_details');
  String get backToEvents => translate('back_to_events');
  String get logout => translate('logout_label');
  
  String get sex => translate('sex');
  String get male => translate('male');
  String get female => translate('female');
  String get selectSex => translate('selectSex');
  String get moreEvents => translate('more_events');
  String get calendar => translate('calendar_label');
  String get liveLabel => translate('live_label');
  String get programs => translate('programs_label');
  String get description => translate('description_label');
  
  String get sponsors => translate('sponsors_label');
  String get participants => translate('participants_label');
  String get moderators => translate('moderators_label');
  String get exposers => translate('exposers_label');
  String get liveChat => translate('live_chat_label');
  String get joinTheConversation => translate('join_the_conversation');
  String get noMessagesyet => translate('no_messages_yet');
  String get watchLive => translate('watch_live');
  String get newLabel => translate('new_label');
  String get noNotificationsYet => translate('no_notifications_label');
  String get accountInformations => translate('account_informations_label');
  String get profile => translate('profile_label');
  String get searchParticipantsLabel => translate('search_participants_label');
  String get searchParticipantsPlaceholder => translate('search_participants_placeholder_label');
  String get noParticipantFound => translate('no_participant_found_label');
  String get profileInfoUpdated => translate('profile_updated_successfully');
  String get addToFavourites => translate('add_to_favoutes');
  String get addedToFavourites => translate('added_to_favoutes');
  String get exploreMoreEvents => translate('explore_more_events');
  
  String get forgotPasswordLabel => translate('forgot_password_label');
  String get forgotPasswordDescription => translate('forgot_password_description');
  String get sendValidationCode => translate('send_validation_code');
  String get backTologin => translate('back_to_login');
  
  String get verifyCode => translate('verify_code_label');
  String get verifyCodeDescription => translate('verify_code_description');
  String get verifyCodebtn => translate('verify_code_btn');
  

  String get resetPassword => translate('reset_password');
  String get resetPasswordDescription => translate('reset_password_description');
  String get newPassword => translate('new_password');
  String get confirmNewPassword => translate('confirm_new_password');
  String get resetPasswordBtn => translate('reset_password_btn');
  
 
  String get resetSuccessLabel => translate('reset_success_label');
  String get resetSuccessDescription => translate('reset_success_description');
  String get resetSuccessBackToLogin => translate('reset_success_back_to_login');



  String get participantsLabel => translate('participants_label');
  String get searchParticipantslabel => translate('searchParticipant_label');

  String get clearLabel => translate('clear_label');
  String get loadingParticipants => translate('loading_participants_label');
  
  String get advancedFilters => translate('advanced_filters_label');
  String get selectOptionLabel => translate('select_option_label');
  String get applyFilters => translate('apply_filters');
  String get additonalDetails => translate('additonal_details');
  

  String get badgeOptions => translate('badge_options');
  String get showBadge => translate('show_badge');
  String get scanQRBadge => translate('scan_qr_badge');
    




  String get loadingParticipant => translate('loading_participant_label');
  String get connect => translate('connect_label');
  String get close => translate('close_label');
  String get errorLoadingParticipant => translate('error_loading_participant_label');
  String get participantNotFound => translate('participant_not_found_label'); 
  String get scanBadge => translate('scan_badge_label');
  String get scanInstructions => translate('scan_instructions_label');
  


  String get signInWihGoogle => translate('sign_in_with_google');
  String get signUpWihGoogle => translate('sign_up_with_google');
  

  
  String get myContacts => translate('my_contacts_label');
  String get remarqueLabel => translate('remarque_label');



  String get addToFavLabel => translate('add_to_fav_label');
  String get addToFavDescription => translate('add_to_fav_descritpion');
  String get noticeLabel => translate('notice_label');
  String get noticeDescription => translate('notice_description');
  String get cancelLabel => translate('cancel_label');
  String get confirmLabel => translate('confirm_label');
  

  String get retry => translate('retry_label');
  String get resultsLabel => translate('results_label');


  String get eventLabel => translate('event_label');
  String get dateLabel => translate('date_label');
  
  String get noStandAvailable => translate('no_stand_available');
  String get networking => translate('networking_label');
  String get typeAMessage => translate('type_a_message');
  String get chatsLabel => translate('chats_label');
  String get allLabel => translate('all_label');
  String get recommendationsLabel => translate('recommendations_label');
  String get myMeetings => translate('my_meetings_label');
  String get myInvitations => translate('my_invitations_label');
  String get sendInvitation => translate('send_invitation_label');
  String get requestBusinesCard => translate('request_business_card_label'); 
  String get scheduleMeeting => translate('schedule_meeting_label'); 
  String get timeLabel => translate('time_label'); 
  String get locationLabel => translate('location_label'); 
  String get sendLabel => translate('send_label'); 
  String get homeLabel => translate('home_label'); 



  String get incoming => translate('incoming_label');
  String get outgoing => translate('outgoing_label');
  String get processing => translate('processing_label');
  
  String get noIncomingInvitations => translate('noIncomingInvitations_label');
  String get noOutgoingInvitations => translate('noOutgoingInvitations_label');
  String get reject => translate('reject_label');
  String get reschedule => translate('reschedule_label');
  String get accept => translate('accept_label');
  String get accepted => translate('accepted_label');
  String get rejected => translate('rejected_label');
  String get pending => translate('pending_label');
  
  String get invitationAccepted => translate('invitation_accepted_label');
  String get invitationRejected => translate('invitation_rejected_label');
  String get invitationRescheduled => translate('invitation_escheduled_label');

  String get replanification => translate('replanification_label');
  
  String get todayLabel => translate('today_label');
  String get tomorrowLabel => translate('tomorrow_label');



  String get businessCardExchange => translate('business_card_exchange');
  String get noIncomingBusinessCards => translate('no_incoming_business_cards');
  String get noOutgoingBusinessCards => translate('no_utgoing_business_cards');
  String get callLabel => translate('call_label');


  String get emailRequiredValidationTitle => translate('email_equired_validation_title');
  String get emailRequiredValidationContent => translate('email_equired_validation_content');
  String get emailRequiredValidationButton => translate('email_equired_validation_button');


  String get refreshLabel => translate('refresh_label');
  String get finishSignup => translate('finish_signup');


  String get finishSignUpText => translate('finish_signup_text');
  String get allRoomsLabel => translate('all_rooms_label');
  
  String get googleSignInFaildNoAccount => translate('google_sign_in_faild_no_account');
  String get googleSignInFaild => translate('google_sign_in_faild'); 
  String get orTextSeparator => translate('or_text_separator'); 
  String get myEventsLabel => translate('my_events_label'); 
  String get noEventsLabel => translate('no_events_label');
  String get noEventsContent => translate('no_events_content'); 
  String get deleteMyAccount => translate('delete_my_account');
  String get deleteAccountWarning => translate('delete_account_warning');
  

  String get myEventsSubTitleDans => translate('my_events_subtitle');
  String get moreEventsSubtitle => translate('more_events_subtitle');
  

  
    




 
  
  
  

  
  


  
  
  
  
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
