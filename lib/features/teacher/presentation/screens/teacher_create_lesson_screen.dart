import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/widgets/retro_button.dart';
import '../../../../core/theme/widgets/retro_text_field.dart';
import '../../domain/lesson_model.dart';
import '../providers/teacher_lesson_provider.dart';

class TeacherCreateLessonScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLessonPublished;

  const TeacherCreateLessonScreen({super.key, this.onLessonPublished});

  @override
  ConsumerState<TeacherCreateLessonScreen> createState() =>
      _TeacherCreateLessonScreenState();
}

class _TeacherCreateLessonScreenState
    extends ConsumerState<TeacherCreateLessonScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _aiPromptController = TextEditingController();
  final _objectiveController = TextEditingController();

  String _selectedClassId = 'class-1';
  String _selectedDuration = '45 mins';
  bool _isGeneratingAI = false;

  final List<LessonAttachment> _attachments = [];

  final List<String> _objectives = [
    'Define the fundamental core principles',
    'Examine real-world engineering case studies',
  ];

  final List<String> _quizQuestions = [
    'Explain the primary distinction between supervised and unsupervised paradigms.',
  ];

  final List<String> _durationOptions = [
    '30 mins',
    '45 mins',
    '60 mins',
    '90 mins',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _aiPromptController.dispose();
    _objectiveController.dispose();
    super.dispose();
  }

  void _generateWithAI() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a lesson topic for AI generation')),
      );
      return;
    }

    setState(() => _isGeneratingAI = true);

    // Simulate high-impact AI Lesson Generation for hackathon
    await Future.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    setState(() {
      _isGeneratingAI = false;
      _titleController.text = prompt;
      _contentController.text =
          '## 1. Executive Summary\n'
          'In this session, we investigate the underlying mechanics of $prompt. '
          'Students will learn theoretical foundations, mathematical formulations, '
          'and practical applications in modern industry.\n\n'
          '## 2. Core Concepts & Architecture\n'
          '• Foundational premise and operational boundaries\n'
          '• Systematic step-by-step pipeline analysis\n'
          '• Performance optimization trade-offs and error mitigation\n\n'
          '## 3. Practical Exercise\n'
          'Follow the guided walkthrough to verify empirical outcomes against baseline models.';

      _objectives.clear();
      _objectives.addAll([
        'Master the theoretical foundations of $prompt',
        'Analyze latency vs accuracy trade-offs in deployment',
        'Design a prototype test harness demonstrating core axioms',
      ]);

      _quizQuestions.clear();
      _quizQuestions.addAll([
        'What is the principal operational bottleneck in $prompt?',
        'How would you diagnose convergence failure in this scenario?',
      ]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✨ AI generated lesson outline, objectives, and quiz!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _addObjective() {
    final text = _objectiveController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _objectives.add(text);
        _objectiveController.clear();
      });
    }
  }

  Future<void> _pickLearningMaterials() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'ppt', 'pptx', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
      );

      if (files.isNotEmpty) {
        setState(() {
          for (final file in files) {
            final ext = (file.extension ?? '').toLowerCase();
            _attachments.add(
              LessonAttachment(
                id: 'att-${DateTime.now().millisecondsSinceEpoch}-${file.name}',
                name: file.name,
                fileType: ext.isNotEmpty ? ext : 'file',
                sizeBytes: file.lengthSync() ?? 0,
                path: file.path,
              ),
            );
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📎 Attached ${files.length} learning material${files.length > 1 ? "s" : ""}!'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _addSampleMaterial(String type) {
    final titleStem = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim().replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_')
        : 'Lecture';

    setState(() {
      if (type == 'ppt') {
        _attachments.add(
          LessonAttachment(
            id: 'att-${DateTime.now().millisecondsSinceEpoch}-ppt',
            name: '${titleStem}_Slides_Deck.pptx',
            fileType: 'pptx',
            sizeBytes: 4620000,
          ),
        );
      } else if (type == 'pdf') {
        _attachments.add(
          LessonAttachment(
            id: 'att-${DateTime.now().millisecondsSinceEpoch}-pdf',
            name: '${titleStem}_Reading_Material.pdf',
            fileType: 'pdf',
            sizeBytes: 1850000,
          ),
        );
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📎 Attached sample ${type.toUpperCase()} presentation!'),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAddLinkDialog() {
    final linkNameController = TextEditingController();
    final linkUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Slides / Web Resource Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: linkNameController,
              decoration: const InputDecoration(
                labelText: 'Material Title (e.g. Slides Deck URL)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: linkUrlController,
              decoration: const InputDecoration(
                labelText: 'URL (Google Slides, Drive, etc.)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = linkNameController.text.trim();
              final url = linkUrlController.text.trim();
              if (name.isNotEmpty && url.isNotEmpty) {
                setState(() {
                  _attachments.add(
                    LessonAttachment(
                      id: 'att-${DateTime.now().millisecondsSinceEpoch}-link',
                      name: name,
                      fileType: 'link',
                      sizeBytes: 0,
                      url: url,
                    ),
                  );
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Attach Link'),
          ),
        ],
      ),
    );
  }

  void _publishLesson() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a lesson title and content')),
      );
      return;
    }

    final classes = ref.read(teacherClassesProvider);
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a class from the Classes tab first')),
      );
      return;
    }

    final targetClass = classes.firstWhere(
      (c) => c.id == _selectedClassId,
      orElse: () => classes.first,
    );

    ref.read(teacherLessonsProvider.notifier).addLesson(
          classId: targetClass.id,
          className: targetClass.title,
          title: title,
          content: content,
          estimatedMinutes: _selectedDuration,
          objectives: List.from(_objectives),
          quizQuestions: List.from(_quizQuestions),
          attachments: List.from(_attachments),
        );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 10),
            Text('Lesson Published!'),
          ],
        ),
        content: Text(
          'Your lesson "$title" has been successfully posted to ${targetClass.title}${_attachments.isNotEmpty ? " with ${_attachments.length} attached learning material(s)" : ""}. '
          'Enrolled students will now see it on their Class dashboard and can consult Nova AI for questions.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (widget.onLessonPublished != null) {
                widget.onLessonPublished!();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Back to Dashboard'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final classes = ref.watch(teacherClassesProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Create & Post Lesson',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target Class Selection
            Text(
              'SELECT TARGET CLASS',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            if (classes.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: colorScheme.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No classes created yet. Please create a class first from the "Classes" tab.',
                        style: TextStyle(fontSize: 12, color: colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: classes.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cls = classes[index];
                    final isSelected = cls.id == _selectedClassId || (_selectedClassId.isEmpty && index == 0);

                    return ChoiceChip(
                      label: Text(cls.title),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedClassId = cls.id);
                      },
                      selectedColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),

            // AI Co-pilot Assist Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI Lesson Generator',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter a topic and let AI draft the lesson outline, learning goals, and quiz questions in seconds.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _aiPromptController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Attention Mechanism & Transformers',
                            hintStyle: TextStyle(
                              color: colorScheme.outline,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _isGeneratingAI ? null : _generateWithAI,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isGeneratingAI
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.bolt, size: 18),
                                  SizedBox(width: 4),
                                  Text(
                                    'Generate',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Lesson Details Form
            RetroTextField(
              label: 'LESSON TITLE',
              hint: 'e.g. Introduction to Quantum Computing',
              controller: _titleController,
              prefixIcon: Icons.title,
            ),
            const SizedBox(height: 16),

            // Duration selector
            Text(
              'ESTIMATED DURATION',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: _durationOptions.map((dur) {
                final isSelected = dur == _selectedDuration;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(dur),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedDuration = dur);
                    },
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Lesson Content Body
            Text(
              'LESSON CONTENT & NOTES',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Enter comprehensive lecture notes, formulas, and resources...',
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Learning Materials Uploader (PowerPoint, PDF, Slides, Documents)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.attachment_rounded, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'LEARNING MATERIALS & SLIDES',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _attachments.isEmpty
                              ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                              : colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_attachments.length} Attached',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _attachments.isEmpty
                                ? colorScheme.outline
                                : colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your PowerPoint lecture presentations (.ppt, .pptx), PDF study notes, or document resources for enrolled students.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Upload Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickLearningMaterials,
                          icon: const Icon(Icons.upload_file_rounded, size: 18),
                          label: const Text(
                            'Upload PPT / PDF',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _showAddLinkDialog,
                        icon: const Icon(Icons.link_rounded, size: 16),
                        label: const Text('Add Link', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Quick Demo Helpers Row (for easily testing without device files)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Quick demo add:',
                        style: TextStyle(fontSize: 11, color: colorScheme.outline),
                      ),
                      ActionChip(
                        avatar: Icon(Icons.slideshow_rounded, size: 14, color: Colors.orange.shade800),
                        label: const Text('+ PPT Slides', style: TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () => _addSampleMaterial('ppt'),
                      ),
                      ActionChip(
                        avatar: Icon(Icons.picture_as_pdf_rounded, size: 14, color: Colors.red.shade800),
                        label: const Text('+ PDF Handout', style: TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        onPressed: () => _addSampleMaterial('pdf'),
                      ),
                    ],
                  ),

                  // Render Selected Attachments List
                  if (_attachments.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _attachments.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final att = _attachments[index];
                        final isPdf = att.fileType.toLowerCase().contains('pdf');
                        final isPpt = att.fileType.toLowerCase().contains('ppt');
                        final isLink = att.fileType.toLowerCase() == 'link';

                        final iconData = isPpt
                            ? Icons.slideshow_rounded
                            : isPdf
                                ? Icons.picture_as_pdf_rounded
                                : isLink
                                    ? Icons.language_rounded
                                    : Icons.description_rounded;

                        final badgeColor = isPpt
                            ? Colors.orange.shade800
                            : isPdf
                                ? Colors.red.shade800
                                : isLink
                                    ? Colors.blue.shade800
                                    : colorScheme.primary;

                        final typeLabel = isPpt
                            ? 'POWERPOINT'
                            : isPdf
                                ? 'PDF DOCUMENT'
                                : isLink
                                    ? 'WEB RESOURCE'
                                    : 'DOCUMENT';

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: badgeColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(iconData, color: badgeColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      att.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          typeLabel,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: badgeColor,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                        if (att.formattedSize.isNotEmpty) ...[
                                          Text(
                                            ' • ${att.formattedSize}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: colorScheme.outline,
                                            ),
                                          ),
                                        ],
                                        if (att.url != null) ...[
                                          Text(
                                            ' • Link attached',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: colorScheme.outline,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                color: colorScheme.error,
                                tooltip: 'Remove Material',
                                onPressed: () {
                                  setState(() {
                                    _attachments.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Learning Objectives
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LEARNING OBJECTIVES',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  '${_objectives.length} Added',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _objectives.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _objectives[index],
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        color: colorScheme.outline,
                        onPressed: () {
                          setState(() => _objectives.removeAt(index));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _objectiveController,
                    decoration: InputDecoration(
                      hintText: 'Add an objective...',
                      hintStyle: TextStyle(color: colorScheme.outline, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addObjective,
                  icon: const Icon(Icons.add_circle),
                  color: colorScheme.primary,
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Publish Button
            RetroButton(
              text: 'Publish Lesson to Class',
              onPressed: _publishLesson,
              icon: Icons.send_rounded,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
