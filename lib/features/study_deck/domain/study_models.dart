enum MasteryStatus {
  learning,
  reviewing,
  mastered,
}

class Flashcard {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final String topic;
  final MasteryStatus masteryStatus;

  const Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.topic,
    this.masteryStatus = MasteryStatus.learning,
  });

  Flashcard copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    String? topic,
    MasteryStatus? masteryStatus,
  }) {
    return Flashcard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      topic: topic ?? this.topic,
      masteryStatus: masteryStatus ?? this.masteryStatus,
    );
  }
}

class FlashcardDeck {
  final String id;
  final String title;
  final String courseCode;
  final String description;
  final List<Flashcard> cards;
  final int colorValue;

  const FlashcardDeck({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.description,
    required this.cards,
    this.colorValue = 0xFF375742,
  });

  int get masteredCount =>
      cards.where((c) => c.masteryStatus == MasteryStatus.mastered).length;

  double get masteryProgress =>
      cards.isEmpty ? 0.0 : masteredCount / cards.length;

  FlashcardDeck copyWith({
    String? id,
    String? title,
    String? courseCode,
    String? description,
    List<Flashcard>? cards,
    int? colorValue,
  }) {
    return FlashcardDeck(
      id: id ?? this.id,
      title: title ?? this.title,
      courseCode: courseCode ?? this.courseCode,
      description: description ?? this.description,
      cards: cards ?? this.cards,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String topic;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.topic,
  });
}

class QuizDeck {
  final String id;
  final String title;
  final String courseCode;
  final String description;
  final List<QuizQuestion> questions;
  final int? bestScore;
  final int? totalQuestions;
  final DateTime? lastAttempted;

  const QuizDeck({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.description,
    required this.questions,
    this.bestScore,
    this.totalQuestions,
    this.lastAttempted,
  });

  QuizDeck copyWith({
    String? id,
    String? title,
    String? courseCode,
    String? description,
    List<QuizQuestion>? questions,
    int? bestScore,
    int? totalQuestions,
    DateTime? lastAttempted,
  }) {
    return QuizDeck(
      id: id ?? this.id,
      title: title ?? this.title,
      courseCode: courseCode ?? this.courseCode,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      bestScore: bestScore ?? this.bestScore,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lastAttempted: lastAttempted ?? this.lastAttempted,
    );
  }
}

class OcrScanResult {
  final String extractedText;
  final String summary;
  final List<String> keyConcepts;
  final List<Flashcard> generatedCards;
  final List<QuizQuestion> generatedQuiz;
  final String? imagePath;
  final String? fileName;

  const OcrScanResult({
    required this.extractedText,
    required this.summary,
    required this.keyConcepts,
    required this.generatedCards,
    required this.generatedQuiz,
    this.imagePath,
    this.fileName,
  });
}
