import 'package:flutter/material.dart';
import 'client_profile_page.dart';
import '../users_data/user_model.dart';
import '../sign_in_page.dart';
import '../users_data/users_database.dart';

class ClientHomePage extends StatefulWidget {
  final User user;
  
  const ClientHomePage({Key? key, required this.user}) : super(key: key);

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  int _selectedIndex = 0;
  late User currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    
    // Check if profile is incomplete and show popup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!currentUser.isProfileComplete) {
        _showCompleteProfileDialog();
      }
    });
  }

  void _refreshUser() {
    // Fetch updated user from database
    final updatedUser = UsersDatabase.getUserById(currentUser.id);
    if (updatedUser != null) {
      setState(() {
        currentUser = updatedUser;
      });
      
      // Check if profile is still incomplete and show popup again if needed
      if (!currentUser.isProfileComplete) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCompleteProfileDialog();
        });
      }
    }
  }

  void _showCompleteProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must complete profile
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
          title: const Text(
            'Complete Your Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'You need to complete your profile before using the app. Please fill in all your information.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                // Navigate to profile page and wait for result
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(user: currentUser),
                  ),
                );
                // Refresh user data after returning
                _refreshUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text('Complete Profile'),
            ),
          ],
        );
      },
    );
  }

  void _onNavItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        // Already on home, do nothing
        break;
      case 1: // Requests
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Requests coming soon!'),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 2: // Inbox
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inbox coming soon!'),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 1),
          ),
        );
        break;
      case 3: // Profile
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(user: currentUser),
          ),
        );
        // Refresh user data after returning from profile
        _refreshUser();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'FixIt - Client',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: Colors.black,
            height: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'CLIENT HOME PAGE',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}