import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../../../core/provider/lists_provider.dart';
import '../../../../../core/provider/settings_provider.dart';
import '../../../../../core/services/settings_service.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/form.dart';

class MoreBottomSheetView extends StatelessWidget {
  MoreBottomSheetView({super.key});
  SettingsProvider settingsProvider= Get.put(SettingsProvider());
  PDFController pdfController = Get.put(PDFController());



  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          // settings
          _buildSection(
            context,
            title: "Settings",
            icon: Icons.settings,
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: [
                    PullDownButton(
                      itemBuilder: (context) => [
                        PullDownMenuItem(
                          title: 'Name',
                          onTap: () {
                            SettingsService.saveSortType("name");
                            settingsProvider.updateSortBy("name");
                            pdfController.sort("name");
                          },
                        ),
                        PullDownMenuItem(
                          title: 'Date Added (new first)',
                          onTap: () {
                            SettingsService.saveSortType("date_new");
                            settingsProvider.updateSortBy("date_new");
                            pdfController.sort("date_new");

                          },
                        ),
                        PullDownMenuItem(
                          title: 'Date Added (old first)',
                          onTap: () {
                            SettingsService.saveSortType("date_old");
                            settingsProvider.updateSortBy("date_old");
                            pdfController.sort("date_old");

                          },
                        ),
                      ],
                      buttonBuilder: (context, showMenu) => CustomButtonOutline(
                        text: 'Sort By',
                        icon: "sort",
                        isFullRow: false,
                        isLoading: false,
                        onPressed: showMenu,
                      ),
                    ),
                    PullDownButton(
                      itemBuilder: (context) => [
                        PullDownMenuItem(
                          title: 'Grid view',
                          onTap: () {
                            SettingsService.saveIsGrid(true);
                            settingsProvider.updateIsGrid(true);
                          },
                        ),
                        PullDownMenuItem(
                          title: 'List view',
                          onTap: () {
                            SettingsService.saveIsGrid(false);
                            settingsProvider.updateIsGrid(false);
                          },
                        ),
                      ],
                      buttonBuilder: (context, showMenu) => CustomButtonOutline(
                        text: 'Grid view',
                        icon: "grid",
                        isLoading: false,
                        isFullRow: false,
                        onPressed: showMenu,
                      ),
                    ),
                    PullDownButton(
                      itemBuilder: (context) => [
                        PullDownMenuItem(
                          title: '2 Columns',
                          onTap: () {
                            SettingsService.saveGridCount(2);
                            settingsProvider.updateColCount(2);
                          },
                        ),
                        PullDownMenuItem(
                          title: '3 Columns',
                          onTap: () {
                            SettingsService.saveGridCount(3);
                            settingsProvider.updateColCount(3);
                          },
                        ),
                        PullDownMenuItem(
                          title: '4 Columns',
                          onTap: () {
                            SettingsService.saveGridCount(4);
                            settingsProvider.updateColCount(4);
                          },
                        ),
                      ],
                      buttonBuilder: (context, showMenu) => CustomButtonOutline(
                        text: 'Column count',
                        icon: "grid_count",
                        isLoading: false,
                        isFullRow: false,
                        onPressed: showMenu,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Contact Section
          _buildSection(
            context,
            title: "Contact Us",
            icon: Icons.email,
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomButtonOutline(
                      text: 'Email',
                      icon: "email",
                      isLoading: false,
                      onPressed: () async {
                        String email = 'baltcode.app@gmail.com';
                        String subject = 'App watchy contact';
                        String body = '';

                        String mailtoUrl =
                            'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';

                        await EasyLauncher.url(url: mailtoUrl);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButtonOutline(
                      text: 'Github',
                      icon: 'github',
                      isLoading: false,
                      onPressed: () async {
                        await EasyLauncher.url(url: "");
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CustomButtonOutline(
                  text: 'Developer Website',
                  icon: 'public',
                  isLoading: false,
                  onPressed: () async {
                    await EasyLauncher.url(
                      url: "https://azizbalti.netlify.app",
                    );
                  },
                ),
              ),
            ],
          ),

          // About Section
          _buildSection(
            context,
            title: "About",
            icon: Icons.info,
            children: aboutButtons(context),
            isVertical: !isLandscape,
          ),
          const SizedBox(height: 10),
          Text(
            '${Constants.packageInfo?.version ?? ''}b${Constants.packageInfo?.buildNumber ?? ''}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Image.asset(
            "assets/logo/logo.png",
            width: 70,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? content,
    List<Widget>? children,
    bool isVertical = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final items = <Widget>[
      if (content != null) ...[
        Text(
          content,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
      if (children != null) ...children,
    ];

    return Card(
      color: colorScheme.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.onSurface, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            isVertical
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: item,
                          ),
                        )
                        .toList(),
                  )
                : Row(
                    children: items
                        .map(
                          (item) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: item,
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  List<Widget> aboutButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      CustomButtonOutline(
        text: "Rate us",
        isLoading: false,
        onPressed: () async {
          await EasyLauncher.url(
            url:
                "https://play.google.com/store/apps/details?id=com.baltcode.watchy",
          );
        },
      ),
      CustomButtonOutline(
        text: "Privacy policy",
        isLoading: false,
        onPressed: () async {
          await EasyLauncher.url(
            url:
                "https://azizbalti.netlify.app/projects/lingua/it/privacy.html",
          );
        },
      ),
    ];
  }
}
