import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  static const green = Color(0xff347c5c);
  static const darkText = Color(0xff202620);
  static const mutedText = Color(0xff7d857f);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8faf7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(flex: 14, child: _buildHeader()),
            Expanded(flex: 77, child: _buildEmptyCollection()),
            Expanded(flex: 9, child: _buildBottomNavigation()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My collection',
                  style: GoogleFonts.plusJakartaSans(
                    color: darkText,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Your personal plant care space.',
                  style: TextStyle(color: mutedText, fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: const Icon(Icons.add, color: green, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCollection() {
    return Column(
      children: [
        const Spacer(flex: 2),
        _buildPlantIllustration(),
        const Spacer(flex: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38),
          child: Text(
            'Your collection is ready to\ngrow',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: darkText,
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 9),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 35),
          child: Text(
            'Save your first plant to track watering, build a\ncare rhythm, and keep every leaf thriving.',
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedText, fontSize: 16, height: 1.35),
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: 252,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.eco_outlined, size: 22),
            label: const Text(
              'Browse plant dictionary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: green,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const Spacer(flex: 3),
        const Text(
          'Tip: start with an easy-care plant',
          style: TextStyle(color: mutedText, fontSize: 12),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPlantIllustration() {
    return SvgPicture.asset(
      'assets/illustration/empty_collection_plant.svg',
      width: 180,
      height: 180,
      fit: BoxFit.contain,
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffeef1ee))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _NavigationItem(icon: Icons.explore_outlined)),
          Expanded(
            child: _NavigationItem(
              icon: Icons.local_florist_outlined,
              selected: true,
            ),
          ),
          Expanded(child: _NavigationItem(icon: Icons.person_outline)),
        ],
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({required this.icon, this.selected = false});

  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 28,
      color: selected ? CollectionPage.green : const Color(0xff758078),
    );
  }
}
