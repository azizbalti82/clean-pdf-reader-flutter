import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pdf_reader/features/application/presentation/views/widgets/more_bottom_sheet_view.dart';
import 'package:pdf_reader/main.dart';

import '../../../../core/provider/lists_provider.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/utils/assets_data.dart';
import '../../../../core/widgets/form.dart';
import '../../../pdf listing/presentation/views/home_view.dart';

class AppView extends StatefulWidget {
  const AppView({super.key, required this.currentIndex});
  final int currentIndex;
  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late int _currentIndex;
  late final List<Widget> _screens;
  bool isSearchEnabled = false;
  TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _screens = const [
      HomeView(type: "pdf listing"),
      HomeView(type: "recent"),
      HomeView(type: "bookmark"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    FullScreen.setFullScreen(false);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40),
        child: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          title: _getAppBar(_currentIndex),
          titleSpacing: 0,
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens.map((screen) {
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              child: RefreshIndicator(
                displacement: 5,
                backgroundColor: Theme.of(context).colorScheme.background,
                color: Theme.of(context).colorScheme.primary,
                elevation: 0,
                onRefresh: () async {
                  loadPDFs();
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      screen,
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: Container(
        height: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  context,
                  0,
                  assetsData.homeOutline,
                  assetsData.homeFilled,
                  24,
                ),
                _buildNavItem(
                  context,
                  1,
                  assetsData.recentOutline,
                  assetsData.recentFilled,
                  27,
                ),
                _buildNavItem(
                  context,
                  2,
                  assetsData.bookmarkOutline,
                  assetsData.bookmarkFilled,
                  24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String assetPath,
    String assetPathFilled,
    double size,
  ) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = index);
          //save last opened section
          SettingsService.saveLastSection(_currentIndex);
        },
        child: Container(
          width: 80,
          height: 50,
          color: Colors.transparent,
          child: Center(
            child: SvgPicture.asset(
              isSelected ? assetPathFilled : assetPath,
              width: size,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getAppBar(int currentIndex) {
    final PdfListsProvider pdfController = Get.put(PdfListsProvider());
    final List<String> titles = ["All files ", "Recent", "Bookmarks"];
    if (isSearchEnabled && _currentIndex == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              setState(() {
                isSearchEnabled = !isSearchEnabled;
                //clear input
                searchController.text = "";
                pdfController.filterHomePDF("");
              });
            },
            icon: SvgPicture.asset(
              assetsData.back,
              width: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          Expanded(
            child: customInput(
              Theme.of(context),
              searchController,
              _focusNode,
              "Search for pdf",
              "",
              context,
              onTextChanged: (text) {
                //filter list
                pdfController.filterHomePDF(text);
              },
            ),
          ),
          const SizedBox(width: 20),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                showCupertinoModalBottomSheet(
                  topRadius: Radius.circular(25),
                  context: context,
                  backgroundColor: Theme.of(context).canvasColor,
                  builder: (context) => MoreBottomSheetView(),
                );
              },
              icon: SvgPicture.asset(
                assetsData.menu,
                width: 26,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          const SizedBox(width: 15),
          Text(
            titles[currentIndex],
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
          ),
          const Spacer(),

          if (currentIndex == 0)
            IconButton(
              onPressed: () {
                setState(() {
                  isSearchEnabled = !isSearchEnabled;
                });
                //request keyboard
                Timer(Duration(milliseconds: 300), () {
                  if (mounted) {
                    _focusNode.requestFocus();
                  }
                });
              },
              icon: SvgPicture.asset(
                assetsData.search,
                width: 24,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
          const SizedBox(width: 14),
        ],
      );
    }
  }
}
