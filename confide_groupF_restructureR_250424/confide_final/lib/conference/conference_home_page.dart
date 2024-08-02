import 'package:confide/api/apis.dart';
import 'package:confide/auth/login_screen.dart';
import 'package:confide/conference/hist_meet_screen.dart';
import 'package:confide/conference/meet_screen.dart';
import 'package:confide/widgets/custom_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ConferenceHomePage extends StatefulWidget {
  const ConferenceHomePage({super.key});

  @override
  State<ConferenceHomePage> createState() => _ConferenceHomePageState();
}

class _ConferenceHomePageState extends State<ConferenceHomePage> {
  int _page = 0;
  static final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();
  onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  List<Widget> pages = [
    MeetingScreen(),
    const HistoryMeetingScreen(),
    const Text('Contacts'),
    CustomButton(
      text: 'Logout',
      onPressed: () async {
        await APIs.updateActiveStatus(false);

        try {
          await APIs.auth.signOut();
          await GoogleSignIn().signOut();

          APIs.auth = FirebaseAuth.instance;

          _navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } catch (e) {
          // Handle sign out errors
          print('Error signing out: $e');
        }
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe2e7ef),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Conference',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white, // Set text color to black
          ),
        ),
        backgroundColor: const Color(0xff0c2c63),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xff0c2c63),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: onPageChanged,
        type: BottomNavigationBarType.shifting,
        unselectedFontSize: 14,
        currentIndex: _page,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.comment,
            ),
            label: 'Comment',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.lock_clock,
            ),
            label: 'Meetting',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_2_outlined,
            ),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
