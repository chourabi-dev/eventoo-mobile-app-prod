import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/screens/calendar.dart/calendar.dart';
import 'package:mobile/screens/chat/chat_discussion_screen.dart';  
import 'package:mobile/screens/event_registration_flow/event_registration_flow.dart';
import 'package:mobile/screens/exposition/exposition_screen.dart';
import 'package:mobile/screens/my_contacts/my_contacts_screen.dart';
import 'package:mobile/screens/my_events/my_events.dart';
import 'package:mobile/screens/networking_experience/networking_experience_screen.dart'; 
import 'package:mobile/screens/participant/participant_screen.dart';
import 'package:mobile/screens/participants/participants_screen.dart';
import 'package:mobile/screens/profile/my_profile.dart';
import 'package:mobile/screens/profile_selection/profile_selection.dart';
import 'package:mobile/screens/reset_password/reset_password_screen.dart';
import 'package:mobile/screens/signup/signup_screen.dart';
import 'package:mobile/screens/updateProfile/update_profile.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/events/events_screen.dart';
import 'screens/signin/signin_screen.dart';
import 'screens/home/home_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
       GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignUpScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),


      
      GoRoute(
        path: '/events',
        name: 'events',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EventsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),



      GoRoute(
        path: '/events/:eventId/register',
        name: 'create-event',
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: EventRegistrationFlow(eventId: eventId), // pass the eventId here
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),




      GoRoute(
        path: '/events/:eventId/pick-profile',
        name: 'pick-profile',
        pageBuilder: (context, state) {
          final eventId = state.pathParameters['eventId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ParticipantTypeSelection(eventId: eventId), // pass the eventId here
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),

 


      GoRoute(
        path: '/profile',
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MyProfile(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),



      GoRoute(
        path: '/my-events',
        name: 'my-events',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MyEventsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),


      GoRoute(
        path: '/my-contacts',
        name: 'my-contacts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MyContactsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),


      GoRoute(
        path: '/exposition',
        name: 'exposition',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ExpositionsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),


      GoRoute(
        path: '/networking',
        name: 'networking',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NetworkingExperience(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),


      GoRoute(
        path: '/chats',
        name: 'chats',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DiscussionsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),



      



      
      GoRoute(
        path: '/event-calendar',
        name: 'event-calendar',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EventCalendarScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),


      


      GoRoute(
        path: '/update-profile',
        name: 'update-profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const UpdateProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),



      GoRoute(
        path: '/participants',
        name: 'participants-screen',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AllParticipantsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      ),







      
      GoRoute(
        path: '/signin',
        name: 'signin',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
        ),
      ),

      
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
        ),
      ),



    


      GoRoute(
        path: '/home',
        name: 'home',
        pageBuilder: (context, state) {
          final eventName = state.uri.queryParameters['event'] ?? 'Event';
          return CustomTransitionPage(
            key: state.pageKey,
            child: HomeScreen(eventName: eventName),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
    ],
  );
}