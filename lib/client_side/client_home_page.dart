import 'package:flutter/material.dart';
import 'client_profile_page.dart';
import 'client_request_edit.dart';
import 'client_requests_page.dart';
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
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientRequestsPage(user: currentUser),
          ),
        );
        // Reset selection back to home after returning
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 2: // Inbox
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inbox coming soon!'),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 1),
          ),
        );
        // Reset selection back to home
        setState(() {
          _selectedIndex = 0;
        });
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
        // Reset selection back to home
        setState(() {
          _selectedIndex = 0;
        });
        break;
    }
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 50,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksStep({
    required int number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[400]!, width: 2),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5F1),
        elevation: 0,
        title: Row(
          children: [
            const Text(
              'Fixit',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Text(
                'Resident',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
                (route) => false,
              );
            },
            child: const Text(
              'Log in',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero section
              const Text(
                'Get help from talented people\nin your area',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Report repair problems fast and track updates in one place.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.search, color: Colors.grey),
                    ),
                    const Expanded(
                      child: Text(
                        '',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientRequestEditPage(user: currentUser),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D7A5E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Create Request',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ClientRequestsPage(user: currentUser),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[400]!, width: 1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'My Requests',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Popular Services section
              const Text(
                'Popular Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              
              // Services grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  _buildServiceCard(
                    title: 'Carpenter',
                    subtitle: 'Doors • Cabinets • Furniture',
                    icon: Icons.carpenter,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientRequestEditPage(
                            serviceType: 'Carpentry',
                            user: currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildServiceCard(
                    title: 'Welding',
                    subtitle: 'Gate • Fence • Metal works',
                    icon: Icons.construction,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientRequestEditPage(
                            serviceType: 'Welding',
                            user: currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildServiceCard(
                    title: 'Plumber',
                    subtitle: 'Pipes • Faucet • Leaks',
                    icon: Icons.plumbing,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientRequestEditPage(
                            serviceType: 'Plumbing',
                            user: currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildServiceCard(
                    title: 'Electrician',
                    subtitle: 'Wiring • Switch • Outlet',
                    icon: Icons.electrical_services,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClientRequestEditPage(
                            serviceType: 'Electrical',
                            user: currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // How it works section
              const Text(
                'How it works',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildHowItWorksStep(
                number: 1,
                title: 'Describe your task',
                description: 'Add title, type, details, and photo.',
              ),
              const SizedBox(height: 16),
              
              _buildHowItWorksStep(
                number: 2,
                title: 'Choose a technician',
                description: 'Assigned (simulated) based on category.',
              ),
              const SizedBox(height: 16),
              
              _buildHowItWorksStep(
                number: 3,
                title: 'Schedule & Track',
                description: 'See status updates until done.',
              ),
              const SizedBox(height: 16),
              
              _buildHowItWorksStep(
                number: 4,
                title: 'Get it done',
                description: 'Repair completed, record saved.',
              ),
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D7A5E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF2D7A5E),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
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