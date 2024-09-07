// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/post_provider.dart';
import 'providers/friend_request_provider.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/feed_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => FriendRequestProvider()),
      ],
      child: MaterialApp(
        title: 'Social Media App',
        theme: ThemeData(
          colorScheme: const ColorScheme(
            primary: Color(0xFFB8E986),
            secondary: Color(0xFFDA4167),
            surface: Color(0xFF2D1E2F),
            background: Color(0xFF2D1E2F),
            error: Colors.red,
            onPrimary: Colors.black,
            onSecondary: Colors.black,
            onSurface: Colors.white,
            onBackground: Colors.white,
            onError: Colors.white,
            brightness: Brightness.dark,
          ),
          textTheme: const TextTheme(
            headline1: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 24,
              color: Colors.white,
            ),
            headline2: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 22,
              color: Colors.white,
            ),
            bodyText1: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 16,
              color: Colors.white,
            ),
            bodyText2: TextStyle(
              fontFamily: 'PressStart2P',
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SignInScreen(),
          '/signin': (context) => const SignInScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/feed': (context) => const FeedScreen(),
        },
      ),
    );
  }
}
