import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ptit_dms_flutter/core/widgets/app_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: const AppHeader(title: 'Trang chủ'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/under-construction.svg',
                  key: const Key('home_under_construction_icon'),
                  width: 220,
                  fit: BoxFit.contain,
                  semanticsLabel: 'Đang phát triển',
                ),
                const SizedBox(height: 20),
                const Text(
                  'Đang phát triển',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF151A2D),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
