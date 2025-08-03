import 'package:flutter/material.dart';
import 'package:pdf_reader/features/application/presentation/views/widgets/system_wrapper_view.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../../../core/widgets/basics.dart'; // your simpleAppBar

class CurrentLevelView extends StatefulWidget {
  const CurrentLevelView({Key? key}) : super(key: key);

  @override
  State<CurrentLevelView> createState() => _CurrentLevelViewState();
}

class _CurrentLevelViewState extends State<CurrentLevelView> {
  // Example fake progress for demo
  final double currentProgress = 0.42; // 42%
  final String currentLevel = "A1";

  final List<LevelInfo> levels = [
    LevelInfo(
      level: "A1",
      description:
      "Beginner. Can understand and use familiar everyday expressions and very basic phrases.",
      time_to_complete: "60–100 hours",
    ),
    LevelInfo(
      level: "A2",
      description:
      "Elementary. Can communicate in simple and routine tasks requiring a simple and direct exchange of information.",
      time_to_complete: "180–200 hours (including A1)",
    ),
    LevelInfo(
      level: "B1",
      description:
      "Intermediate. Can deal with most situations likely to arise whilst travelling in an area where the language is spoken.",
      time_to_complete: "350–400 hours (including A1–A2)",
    ),
    LevelInfo(
      level: "B2",
      description:
      "Upper Intermediate. Can interact with a degree of fluency and spontaneity.",
      time_to_complete: "500–600 hours (including A1–B1)",
    ),
    LevelInfo(
      level: "C1",
      description:
      "Advanced. Can express ideas fluently and spontaneously without much obvious searching for expressions.",
      time_to_complete: "700–800 hours (including A1–B2)",
    ),
    LevelInfo(
      level: "C2",
      description:
      "Proficient. Can understand with ease virtually everything heard or read.",
      time_to_complete: "900–1200+ hours (including A1–C1)",
    ),
  ];


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SystemUiStyleWrapper(
        child:Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: simpleAppBar(context, text: "Italian Level"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Current Level",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Text("A1",style:theme.textTheme.titleMedium,),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SimpleAnimationProgressBar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          ratio: currentProgress,
                          direction: Axis.horizontal,
                          curve: Curves.fastLinearToSlowEaseIn,
                          duration: const Duration(seconds: 3),
                          borderRadius: BorderRadius.circular(10),
                          width: constraints.maxWidth, // Correct: Takes full width
                          height: 25, foregroundColor: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text("A2",style:theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 50),
              Text(
                "Your Italian Level Journey",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),

              ),
              const SizedBox(height: 20),
              // Timeline for Levels
              ...levels.asMap().entries.map((entry) {
                final idx = entry.key;
                final levelInfo = entry.value;
                return TimelineTile(
                  isFirst: idx == 0,
                  isLast: idx == levels.length - 1,
                  indicatorStyle: IndicatorStyle(
                    width: 30,
                    color: theme.colorScheme.primary,
                    padding: const EdgeInsets.all(6),
                    iconStyle: IconStyle(
                      iconData: Icons.school,
                      color: Colors.white,
                    ),
                  ),
                  beforeLineStyle: LineStyle(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    thickness: 4,
                  ),
                  afterLineStyle: LineStyle(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    thickness: 4,
                  ),
                  endChild: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                child: Card(
                    elevation: 0,
                    color: Theme.of(context).cardColor,
                    child:Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            levelInfo.level,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            levelInfo.description,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Time to complete",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),


                          Text(
                            levelInfo.time_to_complete,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ) ,
                  )) ,
                  alignment: TimelineAlign.start,
                  lineXY: 0.1,
                );
              }).toList(),

              const SizedBox(height: 40),
              Text(
                "About Official Italian Certification",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "The official Italian language certification exams (such as CELI, CILS, PLIDA) are internationally recognized and assess proficiency levels according to the Common European Framework of Reference for Languages (CEFR). "
                    "Our app helps you prepare for these levels with targeted lessons_overview, settings, and assessments.",
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ));
  }
}

class LevelInfo {
  final String level;
  final String description;
  final String time_to_complete;

  LevelInfo({
    required this.level,
    required this.description,
    required this.time_to_complete,
  });
}
