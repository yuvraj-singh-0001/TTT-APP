import 'package:flutter/material.dart';

import '../widgets/app_header.dart';
import 'welcome_choice_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  void _showActionMessage(BuildContext context, String action) {
    if (action == 'Login') {
      Navigator.of(context).pushNamed('/login');
    } else if (action == 'Sign Up') {
      Navigator.of(context).pushNamed('/signup');
    } else {
      // Handle other cases
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(height: 68, title: 'The True Topper'),
      body: WelcomeChoicePage(
        onActionSelected: (action) => _showActionMessage(context, action),
        onLearnMore: () => Navigator.of(context).pushNamed('/about'),
      ),
    );
  }
}
