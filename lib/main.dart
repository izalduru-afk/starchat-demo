import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'screens/auth_screens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(const StarChatApp());
}

class StarChatApp extends StatelessWidget {
  const StarChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE4E1EC), width: 1.5),
    );

    return MaterialApp(
      title: 'StarChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimary,
          primary: kPrimary,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: kText,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          titleTextStyle: TextStyle(color: kText, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: fieldBorder,
          enabledBorder: fieldBorder,
          focusedBorder: fieldBorder.copyWith(
            borderSide: const BorderSide(color: kPrimary, width: 1.8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: const TextStyle(color: kMuted),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size(64, 52),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kPrimary,
            minimumSize: const Size(64, 48),
            shape: const StadiumBorder(),
            side: const BorderSide(color: kPrimary, width: 1.5),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          indicatorColor: kPrimaryLight,
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? kPrimary : kMuted,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(color: selected ? kPrimary : kMuted);
          }),
        ),
        dividerTheme: const DividerThemeData(color: kBorder, thickness: 1, space: 1),
      ),
      home: const SignInScreen(),
    );
  }
}
