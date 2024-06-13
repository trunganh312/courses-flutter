import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_providers.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:provider/provider.dart';

class ReponsiveLayout extends StatefulWidget {
  const ReponsiveLayout(
      {super.key, required this.mobileLayout, required this.webLayout});

  final Widget webLayout;
  final Widget mobileLayout;

  @override
  State<ReponsiveLayout> createState() => _ReponsiveLayoutState();
}

class _ReponsiveLayoutState extends State<ReponsiveLayout> {
  void _loadUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.getUser();
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > webScreenSize) {
          return widget.webLayout;
        }
        return widget.mobileLayout;
      },
    );
  }
}
