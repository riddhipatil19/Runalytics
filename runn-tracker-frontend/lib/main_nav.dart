import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:runn_track/pages/home.dart';
import 'package:runn_track/pages/profile.dart';
import 'package:runn_track/pages/run_tracker.dart';
import 'package:runn_track/provider/run_provider.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [Home(), RunTracker(), Profile()];

  void _onItemTapped(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  bool get _shouldHideBottomNav => _selectedIndex == 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _screens,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: _selectedIndex == 1 &&
                (Provider.of<RunTrackerProvider>(context).isTracking)
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
      ),
      bottomNavigationBar: _shouldHideBottomNav
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.blue,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.directions_run),
                  label: 'Run Track',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}
