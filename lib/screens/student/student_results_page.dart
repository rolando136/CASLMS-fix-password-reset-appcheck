import 'package:flutter/material.dart';

import 'activities_scores_page.dart';
import 'posted_grades_page.dart';
import 'progress_page.dart';

class StudentResultsScreen extends StatelessWidget {
  const StudentResultsScreen({super.key, required this.selection});
  final ValueNotifier<int> selection;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: selection,
    builder: (context, selected, _) => Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < 3; index++)
                ChoiceChip(
                  label: Text(
                    const [
                      'Progress',
                      'Activity scores',
                      'Official grades',
                    ][index],
                  ),
                  selected: selected == index,
                  onSelected: (_) => selection.value = index,
                ),
            ],
          ),
        ),
        Expanded(
          child: switch (selected) {
            1 => const ActivitiesScoresScreen(),
            2 => const PostedGradesScreen(),
            _ => const ProgressScreen(),
          },
        ),
      ],
    ),
  );
}
