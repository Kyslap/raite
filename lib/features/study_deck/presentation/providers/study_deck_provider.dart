import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raite/features/daily_goals/presentation/providers/daily_goals_provider.dart';
import '../../data/ocr_service.dart';
import '../../domain/study_models.dart';

class StudyDeckState {
  final List<FlashcardDeck> decks;
  final List<QuizDeck> quizzes;
  final List<OcrScanResult> recentScans;
  final bool isScanning;
  final String? scanError;

  const StudyDeckState({
    required this.decks,
    required this.quizzes,
    this.recentScans = const [],
    this.isScanning = false,
    this.scanError,
  });

  StudyDeckState copyWith({
    List<FlashcardDeck>? decks,
    List<QuizDeck>? quizzes,
    List<OcrScanResult>? recentScans,
    bool? isScanning,
    String? scanError,
  }) {
    return StudyDeckState(
      decks: decks ?? this.decks,
      quizzes: quizzes ?? this.quizzes,
      recentScans: recentScans ?? this.recentScans,
      isScanning: isScanning ?? this.isScanning,
      scanError: scanError ?? this.scanError,
    );
  }
}

final studyDeckProvider =
    NotifierProvider<StudyDeckNotifier, StudyDeckState>(StudyDeckNotifier.new);

class StudyDeckNotifier extends Notifier<StudyDeckState> {
  late final OcrService _ocrService;

  @override
  StudyDeckState build() {
    _ocrService = OcrService();
    return _initialState();
  }

  static StudyDeckState _initialState() {
    return StudyDeckState(
      decks: [
        FlashcardDeck(
          id: 'deck-math201',
          title: 'Calculus II: Integration Techniques',
          courseCode: 'MATH 201',
          description: 'Key formulas, u-substitution, integration by parts, and trigonometric identities.',
          colorValue: 0xFF375742,
          cards: [
            const Flashcard(
              id: 'c1',
              deckId: 'deck-math201',
              front: 'Integration by Parts Formula',
              back: '∫ u dv = u·v - ∫ v du\n\nTip: Use LIATE rule to choose u (Log, Inverse trig, Algebraic, Trig, Exponential).',
              topic: 'Calculus',
              masteryStatus: MasteryStatus.mastered,
            ),
            const Flashcard(
              id: 'c2',
              deckId: 'deck-math201',
              front: 'Derivative of ln(x)',
              back: 'd/dx [ln(x)] = 1/x\n\nFor composite functions: d/dx [ln(u)] = (1/u) · (du/dx)',
              topic: 'Calculus',
              masteryStatus: MasteryStatus.reviewing,
            ),
            const Flashcard(
              id: 'c3',
              deckId: 'deck-math201',
              front: 'Fundamental Theorem of Calculus (Part 1)',
              back: 'If f is continuous on [a, b], then:\nd/dx [ ∫[a to x] f(t) dt ] = f(x)',
              topic: 'Calculus',
              masteryStatus: MasteryStatus.learning,
            ),
            const Flashcard(
              id: 'c4',
              deckId: 'deck-math201',
              front: 'L\'Hôpital\'s Rule Condition',
              back: 'Can only be applied when direct substitution produces an indeterminate form: 0/0 or ±∞/±∞.\n\nTake derivative of numerator and denominator separately: lim f(x)/g(x) = lim f\'(x)/g\'(x).',
              topic: 'Calculus',
              masteryStatus: MasteryStatus.mastered,
            ),
            const Flashcard(
              id: 'c5',
              deckId: 'deck-math201',
              front: 'Integral of 1 / (1 + x²)',
              back: '∫ 1/(1 + x²) dx = arctan(x) + C',
              topic: 'Calculus',
              masteryStatus: MasteryStatus.learning,
            ),
          ],
        ),
        FlashcardDeck(
          id: 'deck-cs210',
          title: 'Data Structures & Algorithmic Complexity',
          courseCode: 'CS 210',
          description: 'Big-O bounds, trees, hashing, dynamic arrays, and graph traversals.',
          colorValue: 0xFF685D45,
          cards: [
            const Flashcard(
              id: 'c6',
              deckId: 'deck-cs210',
              front: 'Average vs Worst Case of QuickSort',
              back: 'Average: O(n log n)\nWorst Case: O(n²) when partition is maximally unbalanced (e.g. already sorted array with extreme pivot).',
              topic: 'Algorithms',
              masteryStatus: MasteryStatus.mastered,
            ),
            const Flashcard(
              id: 'c7',
              deckId: 'deck-cs210',
              front: 'Hash Table Collision Resolution: Open Addressing vs Chaining',
              back: 'Chaining: Each bucket holds a linked list/tree of colliding keys.\nOpen Addressing: Colliding keys probe other empty slots in the array (Linear, Quadratic, Double Hashing).',
              topic: 'Data Structures',
              masteryStatus: MasteryStatus.reviewing,
            ),
            const Flashcard(
              id: 'c8',
              deckId: 'deck-cs210',
              front: 'BFS vs DFS Traversal Queue vs Stack',
              back: 'BFS (Breadth-First Search) uses a FIFO Queue (finds shortest unweighted path).\nDFS (Depth-First Search) uses a LIFO Stack or recursion.',
              topic: 'Graphs',
              masteryStatus: MasteryStatus.mastered,
            ),
            const Flashcard(
              id: 'c9',
              deckId: 'deck-cs210',
              front: 'Height of a Balanced Binary Tree with n nodes',
              back: 'Height h = ⌊log₂ n⌋.\nSearch, insertion, and deletion all run in O(log n) time.',
              topic: 'Trees',
              masteryStatus: MasteryStatus.learning,
            ),
          ],
        ),
        FlashcardDeck(
          id: 'deck-phys102',
          title: 'Classical Mechanics & Thermodynamics',
          courseCode: 'PHYS 102',
          description: 'Newtonian motion, rotational dynamics, work-energy theorem, and gas laws.',
          colorValue: 0xFF2D5A27,
          cards: [
            const Flashcard(
              id: 'c10',
              deckId: 'deck-phys102',
              front: 'Work-Energy Theorem',
              back: 'W_net = ΔK = K_final - K_initial\n\nThe net work done on an object equals the change in its kinetic energy (1/2 m v²).',
              topic: 'Physics',
              masteryStatus: MasteryStatus.reviewing,
            ),
            const Flashcard(
              id: 'c11',
              deckId: 'deck-phys102',
              front: 'Conservation of Angular Momentum',
              back: 'L = I · ω (Moment of inertia × angular velocity).\nIf net external torque τ_ext = 0, total angular momentum is conserved (e.g., spinning figure skater pulling arms in).',
              topic: 'Rotational Motion',
              masteryStatus: MasteryStatus.learning,
            ),
            const Flashcard(
              id: 'c12',
              deckId: 'deck-phys102',
              front: 'Carnot Engine Efficiency Formula',
              back: 'η_max = 1 - (T_cold / T_hot)\n\nWhere temperatures must be measured in absolute Kelvin (K).',
              topic: 'Thermodynamics',
              masteryStatus: MasteryStatus.mastered,
            ),
          ],
        ),
      ],
      quizzes: [
        const QuizDeck(
          id: 'quiz-math201',
          title: 'Calculus II Mastery Challenge',
          courseCode: 'MATH 201',
          description: 'Test your understanding of derivatives, integration by parts, and series convergence.',
          bestScore: 80,
          totalQuestions: 4,
          questions: [
            QuizQuestion(
              id: 'q1',
              question: 'Which rule is recommended for selecting u in Integration by Parts (∫ u dv)?',
              options: ['LIATE', 'PEMDAS', 'FOIL', 'SOHCAHTOA'],
              correctIndex: 0,
              explanation: 'LIATE (Logarithmic, Inverse trig, Algebraic, Trigonometric, Exponential) provides the standard hierarchy for choosing u.',
              topic: 'Calculus',
            ),
            QuizQuestion(
              id: 'q2',
              question: 'What is the integral of sec²(x) dx?',
              options: ['tan(x) + C', 'sec(x)tan(x) + C', 'cos(x) + C', 'ln|sec(x)| + C'],
              correctIndex: 0,
              explanation: 'Since the derivative of tan(x) is sec²(x), the anti-derivative is tan(x) + C.',
              topic: 'Calculus',
            ),
            QuizQuestion(
              id: 'q3',
              question: 'What is lim (x→0) [sin(x) / x]?',
              options: ['1', '0', 'Undefined', 'Infinity'],
              correctIndex: 0,
              explanation: 'This fundamental trigonometric limit evaluates to 1, as verifiable via L\'Hôpital\'s Rule: cos(0)/1 = 1.',
              topic: 'Calculus',
            ),
            QuizQuestion(
              id: 'q4',
              question: 'If ∫[0 to 3] f(x) dx = 7, what is ∫[3 to 0] f(x) dx?',
              options: ['-7', '7', '0', '1/7'],
              correctIndex: 0,
              explanation: 'Reversing the limits of integration multiplies the integral by -1.',
              topic: 'Calculus',
            ),
          ],
        ),
        const QuizDeck(
          id: 'quiz-cs210',
          title: 'Data Structures & Big-O Quick Quiz',
          courseCode: 'CS 210',
          description: 'Assess algorithms, sorting bounds, and graph search paradigms.',
          bestScore: 100,
          totalQuestions: 4,
          questions: [
            QuizQuestion(
              id: 'q5',
              question: 'Which data structure gives optimal FIFO (First In First Out) behavior for BFS?',
              options: ['Queue', 'Stack', 'Priority Heap', 'B-Tree'],
              correctIndex: 0,
              explanation: 'A FIFO Queue ensures nodes are explored level by level in Breadth-First Search.',
              topic: 'Data Structures',
            ),
            QuizQuestion(
              id: 'q6',
              question: 'What is the expected average lookup time in a properly sized Hash Table?',
              options: ['O(1)', 'O(log n)', 'O(n)', 'O(n log n)'],
              correctIndex: 0,
              explanation: 'Hashing maps keys directly to bucket indices in constant amortized O(1) time.',
              topic: 'Data Structures',
            ),
            QuizQuestion(
              id: 'q7',
              question: 'What is the worst-case time complexity of QuickSort?',
              options: ['O(n²)', 'O(n log n)', 'O(n)', 'O(log n)'],
              correctIndex: 0,
              explanation: 'QuickSort degrades to O(n²) when the chosen pivot splits the list into 0 and n-1 elements at every step.',
              topic: 'Algorithms',
            ),
            QuizQuestion(
              id: 'q8',
              question: 'Which algorithmic paradigm does Dijkstra\'s Shortest Path algorithm use?',
              options: ['Greedy Algorithm', 'Divide and Conquer', 'Backtracking', 'Genetic Algorithm'],
              correctIndex: 0,
              explanation: 'Dijkstra greedily chooses the unvisited vertex with the minimum tentative distance at each step.',
              topic: 'Algorithms',
            ),
          ],
        ),
      ],
    );
  }

  void updateMastery(String deckId, String cardId, MasteryStatus newStatus) {
    final updatedDecks = state.decks.map((deck) {
      if (deck.id == deckId) {
        final updatedCards = deck.cards.map((c) {
          if (c.id == cardId) {
            return c.copyWith(masteryStatus: newStatus);
          }
          return c;
        }).toList();
        return deck.copyWith(cards: updatedCards);
      }
      return deck;
    }).toList();

    state = state.copyWith(decks: updatedDecks);
  }

  void submitQuizResult(String quizId, int score, int total) {
    final updatedQuizzes = state.quizzes.map((quiz) {
      if (quiz.id == quizId) {
        final currentBest = quiz.bestScore ?? 0;
        final newBest = score > currentBest ? score : currentBest;
        return quiz.copyWith(
          bestScore: newBest,
          totalQuestions: total,
          lastAttempted: DateTime.now(),
        );
      }
      return quiz;
    }).toList();

    state = state.copyWith(quizzes: updatedQuizzes);

    // Credit study minutes to daily goals!
    ref.read(dailyGoalsProvider.notifier).addMinutes(15, reason: 'Completed Quiz ($score/$total)');
  }

  Future<OcrScanResult> scanDocument(File file) async {
    state = state.copyWith(isScanning: true, scanError: null);
    try {
      final result = await _ocrService.scanAndGenerateStudyMaterial(file);
      final newScans = [result, ...state.recentScans];
      state = state.copyWith(
        recentScans: newScans,
        isScanning: false,
      );

      // Auto-add new deck and quiz to library
      saveOcrResultToDecks(result);

      // Credit study minutes for studying uploaded material
      ref.read(dailyGoalsProvider.notifier).addMinutes(10, reason: 'Scanned Notes via OCR');

      return result;
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        scanError: 'Failed to process document: $e',
      );
      rethrow;
    }
  }

  void saveOcrResultToDecks(OcrScanResult result) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final deckTitle = result.fileName != null
        ? 'Notes: ${result.fileName}'
        : 'Scanned Material Deck';

    if (result.generatedCards.isNotEmpty) {
      final newDeck = FlashcardDeck(
        id: 'deck-ocr-$now',
        title: deckTitle,
        courseCode: 'SCAN',
        description: result.summary,
        colorValue: 0xFF2D5A27,
        cards: result.generatedCards,
      );
      state = state.copyWith(decks: [newDeck, ...state.decks]);
    }

    if (result.generatedQuiz.isNotEmpty) {
      final newQuiz = QuizDeck(
        id: 'quiz-ocr-$now',
        title: '$deckTitle Quiz',
        courseCode: 'SCAN',
        description: 'Auto-generated quiz from scanned material notes.',
        questions: result.generatedQuiz,
      );
      state = state.copyWith(quizzes: [newQuiz, ...state.quizzes]);
    }
  }
}
