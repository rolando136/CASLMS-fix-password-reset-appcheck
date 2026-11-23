import '../../core/app_colors.dart';

import 'package:flutter/material.dart';

class CaslmsGuide {
  const CaslmsGuide(
    this.title,
    this.steps, {
    this.planned = false,
    this.imageAsset, // NEW: Added optional image asset path
  });

  final String title;
  final List<String> steps;
  final bool planned;
  final String? imageAsset; // NEW: Stores the path for the step's screenshot
}

class CaslmsGuides {
  static List<CaslmsGuide> forRole(String role) {
    if (role == 'instructor') {
      return const [
        CaslmsGuide('Create a course', [
          'Open My Courses from the instructor dashboard.',
          'Select Create Course.',
          'Enter the course code, title, description, and academic details.',
          'Save the course, then open its details.',
        ], imageAsset: 'assets/images/instructor_create_course.png'),
        CaslmsGuide('Add a section', [
          'Open My Courses and choose a course.',
          'Select Add Section.',
          'Enter a section name and identifier, such as BSIT 1A.',
          'Save the section, then invite students using their Campus IDs.',
          'Add as many sections as needed; there is no fixed limit.',
        ], imageAsset: 'assets/images/instructor_add_section.png'),
        CaslmsGuide('Enroll students', [
          'Open the course and identify the correct section.',
          'Open the section and select Invite student.',
          'Students accept the invitation from Course invitations on their dashboard.',
          'For original classes, use the instructor invitation workflow.',
          'Check the student roster before assigning activities.',
        ], imageAsset: 'assets/images/instructor_enroll_students.png'),
        CaslmsGuide('Upload learning materials', [
          'Open the course and select Course Tools & Materials.',
          'Open or create the appropriate module.',
          'Choose the option for adding learning materials.',
          'Select a supported file or link, then save.',
          'Verify that students can access the published material.',
        ], imageAsset: 'assets/images/instructor_upload_materials.png'),
        CaslmsGuide('Create assessments', [
          'Open the relevant course and module.',
          'Choose Create Assessment.',
          'Select the assessment type and enter instructions.',
          'Set points, submission details, and the due date.',
          'Review the assessment before publishing.',
          'Section-specific assessment controls are being integrated.',
        ], imageAsset: 'assets/images/instructor_create_assessment.png'),
        CaslmsGuide('Use the AI assistant', [
          'Open the AI Assistant tab in the instructor area.',
          'Choose a course context if the teaching assistant is available.',
          'Ask for lesson plans, quizzes, assignments, or learning activities.',
          'Review the result before copying it into your materials.',
          'AI requires a working Firebase AI service and available quota.',
        ], imageAsset: 'assets/images/instructor_ai_assistant.png'),
        CaslmsGuide(
          'Create grading rubrics',
          [
            'Choose the essay assessment you want to grade.',
            'Define criteria such as content, organization, and grammar.',
            'Assign maximum points or weights to each criterion.',
            'Review the rubric before it is used for grading.',
            'The rubric editor is part of the ongoing essay-grading feature.',
          ],
          planned: true,
          imageAsset: 'assets/images/instructor_grading_rubrics.png',
        ),
        CaslmsGuide('Check student submissions', [
          'Open the instructor Grading area.',
          'Select the course and assessment.',
          'Review each available student submission.',
          'Check the response, attachments, and submission status.',
          'Section-specific submission separation is being integrated.',
        ], imageAsset: 'assets/images/instructor_check_submissions.png'),
        CaslmsGuide(
          'Review and publish grades',
          [
            'Open an assessment submission in Grading.',
            'Review the score and instructor feedback.',
            'For AI-assisted essays, treat any AI score as a suggestion.',
            'Correct the score and feedback before approving.',
            'The full AI rubric approval workflow is still being developed.',
          ],
          planned: true,
          // Assuming you will add this image later, using the root assets/images path
          imageAsset: 'assets/images/instructor_publish_grades.png',
        ),
      ];
    }

    if (role == 'student') {
      return const [
        CaslmsGuide('Join a section', [
          'Open the Student Dashboard.',
          'Open Course invitations on your dashboard.',
          'Review the course and section, then accept your instructor’s invitation.',
          'The class appears in My Classes automatically.',
        ], imageAsset: 'assets/images/student_join_section.png'),
        CaslmsGuide('Find learning materials', [
          'Open your enrolled classes.',
          'Choose the course and look for its modules.',
          'Open a module to view available learning materials.',
        ], imageAsset: 'assets/images/student_find_materials.png'),
        CaslmsGuide('Complete assessments', [
          'Open Assignments or the assessment inside a course.',
          'Read the instructions and due date.',
          'Complete the activity and verify successful submission.',
        ], imageAsset: 'assets/images/student_complete_assessments.png'),
        CaslmsGuide('View grades and feedback', [
          'Open your Progress or assessment results area.',
          'Review published results and instructor feedback.',
          'Contact your instructor about missing or incorrect results.',
        ], imageAsset: 'assets/images/student_view_grades.png'),
      ];
    }

    return const [
      CaslmsGuide('Get started', [
        'Review the main dashboard.',
        'Use the navigation menu to open your assigned features.',
        'Check notifications for new actions or updates.',
      ], imageAsset: 'assets/images/general_get_started.png'),
      CaslmsGuide('Use the system safely', [
        'Only access records you are authorized to view.',
        'Review information before saving important changes.',
        'Sign out after using a shared computer.',
      ], imageAsset: 'assets/images/general_use_safely.png'),
      CaslmsGuide('Find help', [
        'Open Help & User Guide.',
        'Choose a topic that matches your task.',
        'Replay the guided tour whenever you need a refresher.',
      ], imageAsset: 'assets/images/general_find_help.png'),
    ];
  }
}

class CaslmsHelpPage extends StatefulWidget {
  const CaslmsHelpPage({super.key, required this.role});

  final String role;

  @override
  State<CaslmsHelpPage> createState() => _CaslmsHelpPageState();
}

class _CaslmsHelpPageState extends State<CaslmsHelpPage> {
  final search = TextEditingController();
  String filter = '';

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = CaslmsGuides.forRole(widget.role)
        .where(
          (entry) =>
              entry.title.toLowerCase().contains(filter) ||
              entry.steps.any((step) => step.toLowerCase().contains(filter)),
        )
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.darkText,
        title: const Text(
          'Help & User Guide',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Replay the beginner guided tour',
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.replay_rounded),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.inputBorder),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'CASLMS Beginner Guide',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose a task to see simple step-by-step instructions. '
                'Topics marked "In development" describe planned workflows.',
                style: TextStyle(color: AppColors.secondaryText, height: 1.5),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: search,
                onChanged: (value) =>
                    setState(() => filter = value.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search help topics...',
                  hintStyle: const TextStyle(color: Color(0xFFA0A8B7)),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (entries.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.inputBorder),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 48,
                        color: AppColors.primaryBlue,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No matching guide topics.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ...entries.map(
                (entry) => Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.inputBorder),
                  ),
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      entry.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                    subtitle: entry.planned
                        ? const Text(
                            'In development',
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: [
                            for (var i = 0; i < entry.steps.length; i++)
                              ListTile(
                                leading: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.primaryBlue
                                      .withValues(alpha: 0.1),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  entry.steps[i],
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.darkText,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.resolve(context, AppColors.link),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text(
                    'Replay Guided Tour',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
