import 'package:flutter/material.dart';

class ResponsiveBreakpoints {
  static const double phoneMaxWidth = 600.0;
  static const double mobileMaxWidth = 600.0;
  static const double tabletMaxWidth = 1024.0;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget desktop;
  final Widget? tablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
    this.tablet,
  });

  static bool isPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.phoneMaxWidth;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobileMaxWidth;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= ResponsiveBreakpoints.mobileMaxWidth &&
        width < ResponsiveBreakpoints.tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tabletMaxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.tabletMaxWidth) {
          return desktop;
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.mobileMaxWidth) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}

