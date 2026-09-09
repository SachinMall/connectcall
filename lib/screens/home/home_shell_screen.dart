import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/home_controller.dart';
import '../contacts/contacts_tab.dart';
import '../history/call_history_tab.dart';
import '../profile/profile_tab.dart';
import 'dashboard_tab.dart';

class HomeShellScreen extends GetView<HomeController> {
  const HomeShellScreen({super.key});

  static const _tabs = [
    DashboardTab(),
    ContactsTab(),
    CallHistoryTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.selectedTabIndex.value,
            children: _tabs,
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.selectedTabIndex.value,
            onTap: controller.changeTab,
            selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), activeIcon: Icon(Icons.people_rounded), label: 'Contacts'),
              BottomNavigationBarItem(icon: Icon(Icons.call_outlined), activeIcon: Icon(Icons.call_rounded), label: 'Calls'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
            ],
          )),
    );
  }
}
