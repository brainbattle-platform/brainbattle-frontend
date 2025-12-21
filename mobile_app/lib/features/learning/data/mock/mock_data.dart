import 'package:flutter/material.dart';
import '../../domain/domain_model.dart';
import '../../domain/exercise_model.dart';
import '../unit_model.dart';
import '../lesson_model.dart';
import '../../widgets/skill_planet.dart';

/// Mock data for learning module
class MockLearningData {
  static Domain englishDomain() {
    return Domain(
      id: 'english',
      name: 'English',
      description: 'Learn English from basics to advanced',
      color: const Color(0xFF00C2FF),
      units: [
        unit1(),
        unit2(),
      ],
    );
  }

  static Domain programmingDomain() {
    return Domain(
      id: 'programming',
      name: 'Programming',
      description: 'Learn programming concepts',
      color: const Color(0xFF7C4DFF),
      units: [
        unit1(), // Reuse for now
      ],
    );
  }

  static Unit unit1() {
    return Unit(
      id: 'U1',
      title: 'Unit 1 • Basics',
      color: const Color(0xFFFFD166),
      lessons: [
        lesson1(),
        lesson2(),
      ],
    );
  }

  static Unit unit2() {
    return Unit(
      id: 'U2',
      title: 'Unit 2 • Daily Life',
      color: const Color(0xFF00C2FF),
      lessons: [
        lesson3(),
        lesson4(),
      ],
    );
  }

  static Lesson lesson1() {
    return Lesson(
      id: 'L1',
      title: 'Greetings',
      description: 'Learn basic greetings and introductions',
      level: 'A1',
      progress: 0.0,
      status: LessonStatus.unlocked,
    );
  }

  static Lesson lesson2() {
    return Lesson(
      id: 'L2',
      title: 'Numbers & Colors',
      description: 'Master numbers and color vocabulary',
      level: 'A1',
      progress: 0.0,
      status: LessonStatus.unlocked,
    );
  }

  static Lesson lesson3() {
    return Lesson(
      id: 'L3',
      title: 'Food & Drinks',
      description: 'Order food and drinks in English',
      level: 'A1',
      progress: 0.0,
      status: LessonStatus.locked,
    );
  }

  static Lesson lesson4() {
    return Lesson(
      id: 'L4',
      title: 'At School',
      description: 'Classroom phrases and vocabulary',
      level: 'A1',
      progress: 0.0,
      status: LessonStatus.locked,
    );
  }

  /// Get exercises for a lesson (5 items with all 4 template types)
  static List<ExerciseItem> exercisesForLesson(String lessonId) {
    switch (lessonId) {
      case 'L1':
        return [
          // MCQ
          ExerciseItem(
            id: 'E1',
            type: ExerciseType.mcq,
            skill: Skill.listening,
            question: 'What does "Hello" mean?',
            options: ['Xin chào', 'Tạm biệt', 'Cảm ơn', 'Xin lỗi'],
            correctAnswer: 'Xin chào',
            explanation: '"Hello" is a greeting used when meeting someone.',
            hint: 'Think about how you greet someone in Vietnamese.',
            timeLimit: 30,
          ),
          // Fill
          ExerciseItem(
            id: 'E2',
            type: ExerciseType.fill,
            skill: Skill.reading,
            question: 'Complete: "Good ___" (morning/afternoon/evening)',
            options: ['morning', 'afternoon', 'evening', 'night'],
            correctAnswer: 'morning',
            explanation: 'We say "Good morning" in the morning.',
            hint: 'What time of day is it?',
            timeLimit: 30,
          ),
          // Match
          ExerciseItem(
            id: 'E3',
            type: ExerciseType.match,
            skill: Skill.reading,
            question: 'Match the words',
            options: ['Hello', 'Goodbye', 'Thank you', 'Sorry', 'Xin chào', 'Tạm biệt', 'Cảm ơn', 'Xin lỗi'],
            correctAnswer: 'Hello-Xin chào,Goodbye-Tạm biệt,Thank you-Cảm ơn,Sorry-Xin lỗi',
            explanation: 'Match English words with their Vietnamese meanings.',
            hint: 'Think about common greetings.',
            timeLimit: 45,
          ),
          // Listen (stub)
          ExerciseItem(
            id: 'E4',
            type: ExerciseType.listen,
            skill: Skill.listening,
            question: 'Listen and choose the correct answer',
            questionAudio: null, // Stub
            options: ['Hello', 'Hi', 'Hey', 'Good morning'],
            correctAnswer: 'Hello',
            explanation: 'The audio said "Hello".',
            hint: 'Listen carefully to the pronunciation.',
            timeLimit: 20,
          ),
          // MCQ again
          ExerciseItem(
            id: 'E5',
            type: ExerciseType.mcq,
            skill: Skill.speaking,
            question: 'How do you respond to "How are you?"',
            options: ['I\'m fine, thanks', 'Goodbye', 'Hello', 'Thank you'],
            correctAnswer: 'I\'m fine, thanks',
            explanation: 'A common response to "How are you?" is "I\'m fine, thanks".',
            hint: 'Think about polite responses.',
            timeLimit: 30,
          ),
        ];
      case 'L2':
        return [
          ExerciseItem(
            id: 'E6',
            type: ExerciseType.mcq,
            skill: Skill.reading,
            question: 'What number comes after 5?',
            options: ['4', '6', '7', '8'],
            correctAnswer: '6',
            explanation: 'The number after 5 is 6.',
            timeLimit: 20,
          ),
          ExerciseItem(
            id: 'E7',
            type: ExerciseType.fill,
            skill: Skill.writing,
            question: 'The color of the sky is ___',
            options: ['red', 'blue', 'green', 'yellow'],
            correctAnswer: 'blue',
            explanation: 'The sky is typically blue.',
            timeLimit: 30,
          ),
          ExerciseItem(
            id: 'E8',
            type: ExerciseType.match,
            skill: Skill.reading,
            question: 'Match numbers with words',
            options: ['1', '2', '3', '4', 'One', 'Two', 'Three', 'Four'],
            correctAnswer: '1-One,2-Two,3-Three,4-Four',
            explanation: 'Match numerals with their word forms.',
            timeLimit: 40,
          ),
          ExerciseItem(
            id: 'E9',
            type: ExerciseType.listen,
            skill: Skill.listening,
            question: 'Listen: What color is mentioned?',
            questionAudio: null,
            options: ['Red', 'Blue', 'Green', 'Yellow'],
            correctAnswer: 'Red',
            explanation: 'The audio mentioned "red".',
            timeLimit: 20,
          ),
          ExerciseItem(
            id: 'E10',
            type: ExerciseType.mcq,
            skill: Skill.reading,
            question: 'How do you say "màu đỏ" in English?',
            options: ['Red', 'Blue', 'Green', 'Yellow'],
            correctAnswer: 'Red',
            explanation: '"Màu đỏ" means "red" in English.',
            timeLimit: 25,
          ),
        ];
      default:
        return exercisesForLesson('L1'); // Fallback
    }
  }
}

