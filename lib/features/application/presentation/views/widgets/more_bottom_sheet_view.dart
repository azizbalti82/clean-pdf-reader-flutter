import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../../../core/provider/lists_provider.dart';
import '../../../../../core/provider/settings_provider.dart';
import '../../../../../core/services/settings_service.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/form.dart';
import '../../../../../main.dart';

class MoreBottomSheetView extends StatelessWidget {
  MoreBottomSheetView({super.key});

  final SettingsProvider settingsProvider = Get.put(SettingsProvider());
  final PdfListsProvider pdfController = Get.put(PdfListsProvider());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const SizedBox(height: 4),
          _buildHandle(colorScheme),
          _buildContactSection(context),
          SizedBox(height: 5,),
          _buildVersionText(context),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildHandle(ColorScheme colorScheme) => Container(
    width: 30,
    height: 5,
    decoration: BoxDecoration(
      color: colorScheme.primary.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  Widget _buildContactSection(BuildContext context) => _buildSection(
    context: context,
    title: "About App",
    icon: Icons.info,
    children: [
      Row(
        children: [
          Expanded(child:_buildWebsiteButton(),),
          const SizedBox(width: 10),
          Expanded(child: _buildGithubButton()),
        ],
      ),
      Row(
        children: [
          Expanded(child: _buildEmailButton()),
          const SizedBox(width: 10),
          Expanded(child:_buildRateButton(),),
        ],
      ),
      _buildPrivacyButton(),
    ],
  );

  Widget _buildEmailButton() => const CustomButtonOutline(
    text: 'Email',
    icon: "email",
    isLoading: false,
    onPressed: _launchEmail,
  );

  Widget _buildGithubButton() => const CustomButtonOutline(
    text: 'Github',
    icon: 'github',
    isLoading: false,
    onPressed: _launchGithub,
  );

  Widget _buildWebsiteButton() => const CustomButtonOutline(
    text: 'Developer',
    icon: 'public',
    isLoading: false,
    onPressed: _launchWebsite,
  );

  Widget _buildRateButton() => const CustomButtonOutline(
    text: "Rate us",
    icon: "stars",
    isLoading: false,
    onPressed: _launchRate,
  );

  Widget _buildPrivacyButton() => const CustomButtonOutline(
    text: "Privacy policy",
    icon: "privacy",
    isLoading: false,
    onPressed: _launchPrivacy,
  );

  Widget _buildVersionText(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      '${Constants.packageInfo?.version ?? ''}b${Constants.packageInfo?.buildNumber ?? ''}',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildSection(
      {
        required String title,
        required IconData icon,
        String? content,
        List<Widget>? children,
        bool isVertical = true,
        required BuildContext context
      })
  {
    final theme = Theme.of(context ?? Get.context!);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final items = [
      if (content != null)
        Text(
          content,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      if (children != null) ...children,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
              Spacer(),
              IconButton(onPressed: () => showCupertinoModalBottomSheet(
    topRadius: const Radius.circular(25),
    context: context,
    backgroundColor: Theme.of(context).canvasColor,
    builder: (context) => MoreBottomSettingsSheetView(),
    ),icon: SvgPicture.asset(
                "assets/icons/settings.svg",
                width: 25,
                color: colorScheme.onSurface, // textColor equivalent
              ),)
            ],
          ),
          const SizedBox(height: 10),
          isVertical
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: item,
            ))
                .toList(),
          )
              : Row(
            children: items
                .map((item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: item,
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // 🔹 Extracted static launch methods (so buttons can be const)
  static void _launchEmail() => EasyLauncher.url(
    url: 'mailto:baltcode.app@gmail.com?subject=${Uri.encodeComponent('App watchy contact')}',
  );

  static void _launchGithub() => EasyLauncher.url(url: "https://github.com/azizbalti82/modern-pdf-reader-for-android");

  static void _launchWebsite() =>
      EasyLauncher.url(url: "https://azizbalti.netlify.app");

  static void _launchRate() => EasyLauncher.url(
    url: "https://play.google.com/store/apps/details?id=com.baltcode.watchy",
  );

  static void _launchPrivacy() => EasyLauncher.url(
    url: "https://azizbalti.netlify.app/projects/privacy/mypdf",
  );
}

class MoreBottomSettingsSheetView extends StatelessWidget {
  MoreBottomSettingsSheetView({super.key});

  final SettingsProvider settingsProvider = Get.put(SettingsProvider());
  final PdfListsProvider pdfController = Get.put(PdfListsProvider());

  static const _sortOptions = [
    ('Name', 'name'),
    ('Date Added (new first)', 'date_new'),
    ('Date Added (old first)', 'date_old'),
  ];

  static const _gridOptions = [
    ('Grid view', true),
    ('List view', false),
  ];

  static const _columnOptions = [(2, '2 Columns'), (3, '3 Columns'), (4, '4 Columns')];

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const SizedBox(height: 4),
          _buildHandle(colorScheme),
          const SizedBox(height: 10),
          _buildSettingsSection(context),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildHandle(ColorScheme colorScheme) => Container(
    width: 30,
    height: 5,
    decoration: BoxDecoration(
      color: colorScheme.primary.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  Widget _buildSettingsSection(BuildContext context) => _buildSection(
    context,
    title: "Settings",
    icon: Icons.settings,
    children: [
      Wrap(
        spacing: 5,
        runSpacing: 5,
        children: [
          _buildSortButton(),
          _buildViewButton(),
          _buildColumnButton(),
          CustomButtonOutline(
            text: "Refresh",
            icon: "refresh",
            isLoading: false,
            isFullRow: false,
            onPressed: loadPDFs,
          ),
        ],
      ),
    ],
  );

  Widget _buildSortButton() => PullDownButton(
    itemBuilder: (_) => _sortOptions.map((option) => PullDownMenuItem(
      title: option.$1,
      onTap: () => _updateSort(option.$2),
    )).toList(),
    buttonBuilder: (_, showMenu) => CustomButtonOutline(
      text: _getSortName(settingsProvider.sortBy.value),
      icon: "sort",
      isFullRow: false,
      isLoading: false,
      onPressed: showMenu,
    ),
  );

  Widget _buildViewButton() => PullDownButton(
    itemBuilder: (_) => _gridOptions.map((option) => PullDownMenuItem(
      title: option.$1,
      onTap: () => _updateView(option.$2),
    )).toList(),
    buttonBuilder: (_, showMenu) => CustomButtonOutline(
      text: settingsProvider.isGrid.value ? 'Grid view' : "List view",
      icon: "grid",
      isLoading: false,
      isFullRow: false,
      onPressed: showMenu,
    ),
  );

  Widget _buildColumnButton() => PullDownButton(
    itemBuilder: (_) => _columnOptions.map((option) => PullDownMenuItem(
      title: option.$2,
      onTap: () => _updateColumns(option.$1),
    )).toList(),
    buttonBuilder: (_, showMenu) => CustomButtonOutline(
      text: '${settingsProvider.colCount.value} Columns',
      icon: "grid_count",
      isLoading: false,
      isFullRow: false,
      onPressed: showMenu,
    ),
  );

  Widget _buildSection(
      BuildContext? context, {
        required String title,
        required IconData icon,
        String? content,
        List<Widget>? children,
        bool isVertical = true,
      }) {
    final colorScheme = Theme.of(context ?? Get.context!).colorScheme;
    final textTheme = Theme.of(context ?? Get.context!).textTheme;

    final items = [
      if (content != null)
        Text(content, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
      if (children != null) ...children,
    ];

    return Card(
      color: colorScheme.surface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10,left: 10,right: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
            const SizedBox(height: 15),
            isVertical
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: item,
              )).toList(),
            )
                : Row(
              children: items.map((item) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: item,
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSort(String sortType) {
    SettingsService.saveSortType(sortType);
    settingsProvider.updateSortBy(sortType);
    pdfController.sort(sortType);
  }

  void _updateView(bool isGrid) {
    SettingsService.saveIsGrid(isGrid);
    settingsProvider.updateIsGrid(isGrid);
  }

  void _updateColumns(int count) {
    SettingsService.saveGridCount(count);
    settingsProvider.updateColCount(count);
  }

  String _getSortName(String value) => switch (value) {
    'name' => 'Name',
    'date_new' => 'Date Added (new first)',
    'date_old' => 'Date Added (old first)',
    _ => '',
  };
}