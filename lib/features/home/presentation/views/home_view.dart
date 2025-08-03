import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../../../core/services/storage_service.dart';
import '../../../../core/widgets/basics.dart';
import '../../../../main.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _State();
}

class _State extends State<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double last = 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: booksGridView(
        pdfFiles,
        onTap: (item) {
        },
      ),
    );
  }
}
