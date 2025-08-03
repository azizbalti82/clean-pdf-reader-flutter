import 'package:flutter/material.dart';

class BookmarksView extends StatefulWidget {
  @override
  State<BookmarksView> createState() => _State();
}

class _State extends State<BookmarksView> {
  @override
  void initState() {
    super.initState();
    //load the content of the lesson
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(child: Column(children: [])),
    );
  }
}
