import 'package:casino/Auth/login.dart';
import 'package:flutter/material.dart';
import 'Home/basescreen.dart';
import 'services/app_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Casino Club',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF10131A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6966F6),
          secondary: Color(0xFF6966F6),
          surface: Color(0xFF171B25),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF171B25),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const SessionGate(),
    );
  }
}

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  late final Future<AppUser?> _sessionUser;

  @override
  void initState() {
    super.initState();
    _sessionUser = _getSessionUser();
  }

  Future<AppUser?> _getSessionUser() async {
    final username = await AppStorage.getSession();
    if (username == null) return null;
    final accounts = await AppStorage.getAccounts();
    for (final account in accounts) {
      if (account.username.toLowerCase() == username.toLowerCase()) {
        return account;
      }
    }
    await AppStorage.clearSession();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppUser?>(
      future: _sessionUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        return user == null ? const LoginScreen() : BaseScreen(user: user);
      },
    );
  }
}
