// lib/main.dart
// Full updated file with:
// - Subject names and assignment titles update immediately when language changes (no stale localized titles).
// - Calendar overflows fixed and performance improved (dynamic heights, cached month events, lighter cells).
// - Goals: top "+" removed, FAB remains; deleting & toggling goals updates dashboard immediately.
// - Announcements layout improved and mark-read updates dashboard quickly.
// - MaterialApp rebuild forced on locale change to apply new localized strings instantly.
//
// Make sure pubspec.yaml includes:
//   shared_preferences: ^2.0.0
//   flutter_localizations:
//
// Then: flutter pub get

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ------------------------------
// App-wide state (simple singleton with ValueNotifiers)
// ------------------------------
class AppState {
  AppState._();
  static final instance = AppState._();

  final ValueNotifier<int> unreadAnnouncements = ValueNotifier<int>(0);
  final ValueNotifier<int> goalsCount = ValueNotifier<int>(0);
  final ValueNotifier<int> assignmentsPending = ValueNotifier<int>(0);
  final ValueNotifier<int> reportsCount = ValueNotifier<int>(8);
}

// ------------------------------
// Localization
// ------------------------------
class L {
  static String locale = 'ru'; // default

  static final Map<String, Map<String, String>> _t = {
    'ru': {
      'app_title': 'Черно‑белое приложение',
      'login': 'Вход',
      'register': 'Регистрация',
      'email': 'Email',
      'password': 'Пароль',
      'confirm_password': 'Подтвердите пароль',
      'first_name': 'Имя',
      'last_name': 'Фамилия',
      'pin': 'PIN для восстановления (4 цифры)',
      'enter_email': 'Введите email',
      'enter_pin': 'Введите PIN (4 цифры)',
      'forgot_password': 'Забыл пароль',
      'reset_password': 'Сброс пароля',
      'submit': 'Отправить',
      'logout': 'Выйти',
      'home': 'Главная',
      'profile': 'Профиль',
      'dashboard': 'Дашборд',
      'users_cleared': 'Все пользователи удалены',
      'registered': 'Регистрация успешна',
      'user_exists': 'Пользователь уже существует',
      'invalid_credentials': 'Неверный email или пароль',
      'passwords_not_match': 'Пароли не совпадают',
      'fill_all': 'Заполните все поля',
      'choose_theme': 'Тема',
      'choose_language': 'Язык',
      'light': 'Белая',
      'dark': 'Чёрная',
      'change_language': 'Сменить язык',
      'reset_success': 'Пароль обновлён',
      'invalid_pin': 'Неверный PIN или email',
      'enter_new_password': 'Введите новый пароль',
      'confirm_new_password': 'Подтвердите новый пароль',
      'theme_updated': 'Тема изменена',
      'language_updated': 'Язык изменён',
      'assignments_title': 'Задания и сроки',
      'items_pending': 'ожидают',
      'assignments_count': 'Заданий',
      'mark_all_done': 'Отметить все выполненными',
      'calendar_title': 'Академический календарь 2025–2026',
      'today': 'Сегодня',
      'due_in_days': 'Срок через',
      'due_today': 'Срок сегодня',
      'overdue_by': 'Просрочено',
      'save_back': 'Сохранить и вернуться',
      'cancel': 'Отмена',
      'pending_label': 'Ожидает',
      'event_label': 'Событие',
      'announcements': 'Объявления',
      'my_goals': 'Мои цели',
      'no_announcements': 'Объявлений нет',
      'no_goals': 'Целей нет',
      'add_goal': 'Добавить цель',
      'edit_goal': 'Редактировать цель',
      'goal_title': 'Название цели',
      'goal_description': 'Описание (необязательно)',
      'mark_complete': 'Отметить выполненным',
      'delete': 'Удалить',
      'save': 'Сохранить',
      'progress_reports': 'Отчёты',
      'grades': 'Оценки',
      'days_late': 'Дни опоздания',
      'average_grade': 'Средняя оценка',
      'total_late': 'Всего опозданий',
      'select_subject': 'Выберите предмет',
      'reports_count': 'предметов',
      'timetable': 'Расписание',
      'monday': 'Пн',
      'tuesday': 'Вт',
      'wednesday': 'Ср',
      'thursday': 'Чт',
      'friday': 'Пт',
      'saturday': 'Сб',
      'monday_full': 'Понедельник',
      'tuesday_full': 'Вторник',
      'wednesday_full': 'Среда',
      'thursday_full': 'Четверг',
      'friday_full': 'Пятница',
      'saturday_full': 'Суббота',
      'room': 'Кабинет',
      'teacher': 'Преподаватель',
      'no_lessons': 'Нет занятий',
      'semester_fall': 'Осенний семестр',
      'semester_spring': 'Весенний семестр',
      'attendance': 'Посещаемость',
      'school_policies': 'Школьные правила и материалы',
      'attendance_rate': 'Процент посещаемости',
      'present': 'Присутствия',
      'absent': 'Отсутствия',
      'late': 'Опоздания',
      'dress_code': 'Форма одежды',
      'dress_code_desc': 'Учащиеся должны носить утверждённую школьную форму.',
      'mobile_devices': 'Использование телефонов',
      'mobile_desc': 'Телефоны разрешены только в перерывах и после уроков.',
      'classroom_conduct': 'Поведение в классе',
      'conduct_desc':
          'Уважайте учителей и одноклассников, следите за дисциплиной.',
      'homework_policy': 'Домашние задания',
      'homework_desc':
          'Выполняйте все домашние задания в срок. Несоблюдение может повлиять на оценки.',
      'safety_policy': 'Безопасность',
      'safety_desc':
          'Все учащиеся должны соблюдать правила безопасности и пожарной эвакуации.',
    },
    'en': {
      'app_title': 'Black & White App',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm password',
      'first_name': 'First name',
      'last_name': 'Last name',
      'pin': 'Recovery PIN (4 digits)',
      'enter_email': 'Enter email',
      'enter_pin': 'Enter PIN (4 digits)',
      'forgot_password': 'Forgot password',
      'reset_password': 'Reset password',
      'submit': 'Submit',
      'logout': 'Logout',
      'home': 'Home',
      'profile': 'Profile',
      'dashboard': 'Dashboard',
      'users_cleared': 'All users cleared',
      'registered': 'Registered successfully',
      'user_exists': 'User already exists',
      'invalid_credentials': 'Invalid email or password',
      'passwords_not_match': 'Passwords do not match',
      'fill_all': 'Fill all fields',
      'choose_theme': 'Theme',
      'choose_language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'change_language': 'Change language',
      'reset_success': 'Password updated',
      'invalid_pin': 'Invalid PIN or email',
      'enter_new_password': 'Enter new password',
      'confirm_new_password': 'Confirm new password',
      'theme_updated': 'Theme updated',
      'language_updated': 'Language updated',
      'assignments_title': 'Assignments and deadlines',
      'items_pending': 'items pending',
      'assignments_count': 'Assignments',
      'mark_all_done': 'Mark all done',
      'calendar_title': 'Academic calendar 2025–2026',
      'today': 'Today',
      'due_in_days': 'Due in',
      'due_today': 'Due today',
      'overdue_by': 'Overdue by',
      'save_back': 'Save & Back',
      'cancel': 'Cancel',
      'pending_label': 'Pending',
      'event_label': 'Event',
      'announcements': 'Announcements',
      'my_goals': 'My goals',
      'no_announcements': 'No announcements',
      'no_goals': 'No goals',
      'add_goal': 'Add goal',
      'edit_goal': 'Edit goal',
      'goal_title': 'Goal title',
      'goal_description': 'Description (optional)',
      'mark_complete': 'Mark complete',
      'delete': 'Delete',
      'save': 'Save',
      'progress_reports': 'Progress reports',
      'grades': 'Grades',
      'days_late': 'Days late',
      'average_grade': 'Average grade',
      'total_late': 'Total late days',
      'select_subject': 'Select subject',
      'reports_count': 'subjects',
      'timetable': 'Timetable',
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'monday_full': 'Monday',
      'tuesday_full': 'Tuesday',
      'wednesday_full': 'Wednesday',
      'thursday_full': 'Thursday',
      'friday_full': 'Friday',
      'saturday_full': 'Saturday',
      'room': 'Room',
      'teacher': 'Teacher',
      'no_lessons': 'No lessons',
      'semester_fall': 'Fall semester',
      'semester_spring': 'Spring semester',
      'attendance': 'Attendance',
      'school_policies': 'School policies and resources',
      'attendance_rate': 'Attendance rate',
      'present': 'Present',
      'absent': 'Absent',
      'late': 'Late',
      'dress_code': 'Dress Code',
      'dress_code_desc': 'Students must wear the approved school uniform.',
      'mobile_devices': 'Mobile Devices',
      'mobile_desc':
          'Mobile phones are allowed only during breaks and after lessons.',
      'classroom_conduct': 'Classroom Conduct',
      'conduct_desc': 'Respect teachers and classmates, maintain discipline.',
      'homework_policy': 'Homework Policy',
      'homework_desc':
          'Complete all homework on time. Non-compliance may affect grades.',
      'safety_policy': 'Safety',
      'safety_desc':
          'All students must follow safety and emergency evacuation procedures.',
    }
  };

  static String t(String key) {
    return _t[locale]?[key] ?? key;
  }
}

// localized month names helper
String localizedMonthName(int month) {
  if (L.locale == 'ru') {
    const rus = [
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек'
    ];
    return rus[month - 1];
  } else {
    const eng = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return eng[month - 1];
  }
}

// ------------------------------
// Subject localization
// Store subjectKey in model and provide localized display functions
// ------------------------------
String localizedSubjectName(String subjectKey) {
  final ru = {
    'mathematics': 'Математика',
    'english': 'Английский',
    'science': 'Наука',
    'history': 'История',
    'art': 'ИЗО',
    'pe': 'Физра',
    'spanish': 'Испанский',
    'design': 'Дизайн',
  };
  final en = {
    'mathematics': 'Mathematics',
    'english': 'English',
    'science': 'Science',
    'history': 'History',
    'art': 'Art',
    'pe': 'PE',
    'spanish': 'Spanish',
    'design': 'Design',
  };
  // If subjectKey is already a localized name (persisted from older data),
  // map it back to a stable key. This handles cases where prefs stored
  // the localized subject string instead of the internal subject key.
  final Map<String, String> valueToKeyRu = {
    for (var e in ru.entries) e.value: e.key
  };
  final Map<String, String> valueToKeyEn = {
    for (var e in en.entries) e.value: e.key
  };

  String normalize(String s) {
    if (ru.containsKey(s)) return s; // already a key
    if (en.containsKey(s)) return s; // already a key
    if (valueToKeyRu.containsKey(s)) return valueToKeyRu[s]!;
    if (valueToKeyEn.containsKey(s)) return valueToKeyEn[s]!;
    return s;
  }

  final key = normalize(subjectKey);
  return L.locale == 'ru' ? (ru[key] ?? key) : (en[key] ?? key);
}

String localizedAssignmentLabel(int number) {
  return L.locale == 'ru' ? 'Задание $number' : 'Assignment $number';
}

// ------------------------------
// Models
// - Assignment now stores stable 'number' and 'subjectKey'.
// - displayTitle() returns localized subject + localized assignment label (computed at render time).
// ------------------------------
class UserModel {
  String email;
  String password;
  String firstName;
  String lastName;
  String pin;

  UserModel({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.pin,
  });

  Map<String, dynamic> toMap() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'pin': pin,
      };

  static UserModel fromMap(Map m) => UserModel(
        email: m['email'],
        password: m['password'],
        firstName: m['firstName'],
        lastName: m['lastName'],
        pin: m['pin'],
      );
}

class Assignment {
  final int id;
  String?
      title; // optional, kept for backward compatibility but not used for display
  final String subjectKey; // e.g. 'mathematics'
  final String dueIso; // yyyy-MM-dd
  bool done;
  final int number; // stable number to show (was i+1 when generated)

  Assignment({
    required this.id,
    this.title,
    required this.subjectKey,
    required this.dueIso,
    this.done = false,
    required this.number,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title ?? '',
        'subjectKey': subjectKey,
        'dueIso': dueIso,
        'done': done ? 1 : 0,
        'number': number,
      };

  static Assignment fromMap(Map<String, dynamic> m) {
    final sk = m.containsKey('subjectKey')
        ? m['subjectKey']
        : (m['subject'] ?? 'mathematics');
    final num = m.containsKey('number')
        ? (m['number'] is int ? m['number'] : int.parse(m['number'].toString()))
        : (m['id'] is int ? m['id'] : int.parse(m['id'].toString()));
    return Assignment(
      id: m['id'] is int ? m['id'] : int.parse(m['id'].toString()),
      title: (m['title'] as String).isEmpty ? null : m['title'],
      subjectKey: sk,
      dueIso: m['dueIso'],
      done: (m['done'] == 1 || m['done'] == true || m['done'] == '1'),
      number: num,
    );
  }

  DateTime get dueDate {
    try {
      final parts = dueIso.split('-');
      return DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (_) {
      return DateTime.now();
    }
  }

  String dueShortString() {
    final d = dueDate;
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
  }

  String dueHumanReadable() {
    final now = DateTime.now();
    final diff =
        dueDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    if (diff == 0) return L.t('due_today');
    if (diff > 0) return '${L.t('due_in_days')} $diff';
    return '${L.t('overdue_by')} ${-diff}';
  }

  // Compute localized display title at render time.
  String displayTitle() {
    return '${localizedSubjectName(subjectKey)} — ${localizedAssignmentLabel(number)}';
  }
}

class Announcement {
  final int id;
  String title;
  String body;
  final String dateIso; // yyyy-MM-dd
  bool read;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.dateIso,
    this.read = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'dateIso': dateIso,
        'read': read ? 1 : 0,
      };

  static Announcement fromMap(Map<String, dynamic> m) => Announcement(
        id: m['id'] is int ? m['id'] : int.parse(m['id'].toString()),
        title: m['title'],
        body: m['body'],
        dateIso: m['dateIso'],
        read: (m['read'] == 1 || m['read'] == true || m['read'] == '1'),
      );
}

class Goal {
  final int id;
  String title;
  String? description;
  bool done;
  String createdIso;

  Goal({
    required this.id,
    required this.title,
    this.description,
    this.done = false,
    required this.createdIso,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description ?? '',
        'done': done ? 1 : 0,
        'createdIso': createdIso,
      };

  static Goal fromMap(Map<String, dynamic> m) => Goal(
        id: m['id'] is int ? m['id'] : int.parse(m['id'].toString()),
        title: m['title'],
        description:
            (m['description'] as String).isEmpty ? null : m['description'],
        done: (m['done'] == 1 || m['done'] == true || m['done'] == '1'),
        createdIso: m['createdIso'] ?? DateTime.now().toIso8601String(),
      );
}

class CalendarEvent {
  final DateTime date;
  final String title;
  final String? note;
  CalendarEvent({required this.date, required this.title, this.note});
}

// ------------------------------
// Persistence keys & helpers
// ------------------------------
const String _kAssignmentsKey = 'assignments_list';
const String _kAnnouncementsKey = 'announcements_list';
const String _kGoalsKey = 'goals_list';

Future<List<Assignment>> loadAssignmentsFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kAssignmentsKey);
  if (raw == null) {
    final list = _generateInitialAssignments();
    await saveAssignmentsToPrefs(list);
    AppState.instance.assignmentsPending.value =
        list.where((a) => !a.done).length;
    return list;
  }
  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    final list = decoded
        .map((e) => Assignment.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    AppState.instance.assignmentsPending.value =
        list.where((a) => !a.done).length;
    return list;
  } catch (e) {
    final list = _generateInitialAssignments();
    await saveAssignmentsToPrefs(list);
    AppState.instance.assignmentsPending.value =
        list.where((a) => !a.done).length;
    return list;
  }
}

Future<void> saveAssignmentsToPrefs(List<Assignment> list) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(list.map((a) => a.toMap()).toList());
  await prefs.setString(_kAssignmentsKey, encoded);
  AppState.instance.assignmentsPending.value =
      list.where((a) => !a.done).length;
}

Future<void> updateAssignmentsLocalization() async {
  // If assignments store only number+subjectKey, no need to rewrite persistently.
  // But keep this fn for backward compatibility: if any title exists, regenerate title field.
  final assignments = await loadAssignmentsFromPrefs();
  bool changed = false;
  for (var a in assignments) {
    final newTitle =
        '${localizedSubjectName(a.subjectKey)} — ${localizedAssignmentLabel(a.number)}';
    if (a.title != newTitle) {
      a.title = newTitle;
      changed = true;
    }
  }
  if (changed) {
    await saveAssignmentsToPrefs(assignments);
  }
}

Future<List<Announcement>> loadAnnouncementsFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kAnnouncementsKey);
  if (raw == null) {
    final list = _generateInitialAnnouncements();
    await saveAnnouncementsToPrefs(list);
    AppState.instance.unreadAnnouncements.value =
        list.where((a) => !a.read).length;
    return list;
  }
  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    final list = decoded
        .map((e) => Announcement.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    AppState.instance.unreadAnnouncements.value =
        list.where((a) => !a.read).length;
    return list;
  } catch (e) {
    final list = _generateInitialAnnouncements();
    await saveAnnouncementsToPrefs(list);
    AppState.instance.unreadAnnouncements.value =
        list.where((a) => !a.read).length;
    return list;
  }
}

Future<void> saveAnnouncementsToPrefs(List<Announcement> list) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(list.map((a) => a.toMap()).toList());
  await prefs.setString(_kAnnouncementsKey, encoded);
  AppState.instance.unreadAnnouncements.value =
      list.where((a) => !a.read).length;
}

Future<void> updateAnnouncementsLocalization() async {
  final announcements = await loadAnnouncementsFromPrefs();
  if (announcements.length >= 2) {
    announcements[0].title =
        L.locale == 'ru' ? 'Школьный концерт' : 'School concert';
    announcements[0].body = L.locale == 'ru'
        ? 'Школьный концерт состоится в следующую пятницу в актовом зале. Начало в 18:00. Приглашаются все ученики и родители.'
        : 'The school concert will take place next Friday in the assembly hall at 18:00. All students and parents are invited.';
    announcements[1].title =
        L.locale == 'ru' ? 'Изменение расписания' : 'Timetable change';
    announcements[1].body = L.locale == 'ru'
        ? 'Обратите внимание: расписание для 10‑А класса изменено на следующую неделю. Проверьте раздел «Расписание» в приложении.'
        : 'Attention: the timetable for Grade 10A has changed for next week. Please check the Timetable section in the app.';
  }
  await saveAnnouncementsToPrefs(announcements);
}

Future<List<Goal>> loadGoalsFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kGoalsKey);
  if (raw == null) {
    final list = <Goal>[];
    await saveGoalsToPrefs(list);
    AppState.instance.goalsCount.value = list.length;
    return list;
  }
  try {
    final decoded = jsonDecode(raw) as List<dynamic>;
    final list =
        decoded.map((e) => Goal.fromMap(Map<String, dynamic>.from(e))).toList();
    AppState.instance.goalsCount.value = list.length;
    return list;
  } catch (e) {
    final list = <Goal>[];
    await saveGoalsToPrefs(list);
    AppState.instance.goalsCount.value = list.length;
    return list;
  }
}

Future<void> saveGoalsToPrefs(List<Goal> list) async {
  final prefs = await SharedPreferences.getInstance();
  final encoded = jsonEncode(list.map((g) => g.toMap()).toList());
  await prefs.setString(_kGoalsKey, encoded);
  AppState.instance.goalsCount.value = list.length;
}

// ------------------------------
// Initial generators
// ------------------------------
List<Assignment> _generateInitialAssignments() {
  final subjectsKeys = [
    'mathematics',
    'english',
    'science',
    'history',
    'art',
    'pe',
    'spanish',
    'design'
  ];
  final start = DateTime(2025, 9, 1);
  final end = DateTime(2026, 6, 30);
  final totalDays = end.difference(start).inDays;
  List<Assignment> list = [];
  for (var i = 0; i < 50; i++) {
    final idx = i % subjectsKeys.length;
    final subjectKey = subjectsKeys[idx];
    final dayOffset = ((i * 11) % (totalDays > 0 ? totalDays : 1));
    final due = start.add(Duration(days: dayOffset));
    final dueIso =
        '${due.year.toString().padLeft(4, '0')}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}';
    final number = i + 1;
    final title =
        '${localizedSubjectName(subjectKey)} — ${localizedAssignmentLabel(number)}';
    list.add(Assignment(
        id: number,
        title: title,
        subjectKey: subjectKey,
        dueIso: dueIso,
        done: false,
        number: number));
  }
  return list;
}

List<Announcement> _generateInitialAnnouncements() {
  final now = DateTime.now();
  return [
    Announcement(
      id: 1,
      title: L.locale == 'ru' ? 'Школьный концерт' : 'School concert',
      body: L.locale == 'ru'
          ? 'Школьный концерт состоится в следующую пятницу в актовом зале. Начало в 18:00. Приглашаются все ученики и родители.'
          : 'The school concert will take place next Friday in the assembly hall at 18:00. All students and parents are invited.',
      dateIso:
          now.subtract(Duration(days: 5)).toIso8601String().split('T').first,
      read: false,
    ),
    Announcement(
      id: 2,
      title: L.locale == 'ru' ? 'Изменение расписания' : 'Timetable change',
      body: L.locale == 'ru'
          ? 'Обратите внимание: расписание для 10‑А класса изменено на следующую неделю. Проверьте раздел «Расписание» в приложении.'
          : 'Attention: the timetable for Grade 10A has changed for next week. Please check the Timetable section in the app.',
      dateIso:
          now.subtract(Duration(days: 2)).toIso8601String().split('T').first,
      read: false,
    ),
  ];
}

List<CalendarEvent> buildAcademicEvents() {
  List<CalendarEvent> events = [];

  void add(int y, int m, int d, String title, [String? note]) {
    events
        .add(CalendarEvent(date: DateTime(y, m, d), title: title, note: note));
  }

  add(2025, 9, 1, L.locale == 'ru' ? 'Начало учебного года' : 'Term starts',
      'First day of term');
  add(2025, 11, 4, L.locale == 'ru' ? 'Осенние каникулы' : 'Midterm break');
  add(2025, 11, 5, L.locale == 'ru' ? 'Осенние каникулы' : 'Midterm break');
  for (int d = 24; d <= 31; d++) {
    add(2025, 12, d, L.locale == 'ru' ? 'Зимние каникулы' : 'Winter break');
  }
  for (int d = 1; d <= 4; d++) {
    add(2026, 1, d, L.locale == 'ru' ? 'Зимние каникулы' : 'Winter break');
  }
  add(2026, 1, 20, 'Assessment period', 'Exams start');
  add(2026, 1, 27, 'Assessment period', 'Exams end');
  for (int d = 23; d <= 29; d++) {
    add(2026, 3, d, L.locale == 'ru' ? 'Весенние каникулы' : 'Spring break');
  }
  add(2026, 6, 20, 'Finals & Presentations');
  add(2026, 6, 30, L.locale == 'ru' ? 'Конец учебного года' : 'Term ends');
  add(2026, 2, 14, 'MYP Personal Project deadline', 'Submit report');
  add(2025, 12, 25, L.locale == 'ru' ? 'Рождество' : 'Christmas Day');
  add(2026, 1, 1, L.locale == 'ru' ? 'Новый год' : "New Year's Day");
  add(2026, 5, 1, L.locale == 'ru' ? 'Праздник труда' : 'Labor Day');

  return events;
}

// ------------------------------
// App entry
// ------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  L.locale = prefs.getString('locale') ?? 'ru';
  final savedThemeIsDark = prefs.getBool('isDark') ?? false;
  // Preload persisted lists to initialize AppState counts
  await loadAnnouncementsFromPrefs();
  await loadGoalsFromPrefs();
  await loadAssignmentsFromPrefs();
  runApp(MyApp(initialDark: savedThemeIsDark));
}

class MyApp extends StatefulWidget {
  final bool initialDark;
  const MyApp({super.key, required this.initialDark});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDark = false;
  Locale _locale = Locale(L.locale);

  @override
  void initState() {
    super.initState();
    isDark = widget.initialDark;
    _locale = Locale(L.locale);
  }

  void toggleTheme(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDark = dark);
    await prefs.setBool('isDark', dark);
  }

  Future<void> changeLanguage(String localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    // Update locale globally first
    L.locale = localeCode;
    await prefs.setString('locale', localeCode);
    // Update persisted localized texts where needed (backwards compatibility)
    await updateAnnouncementsLocalization();
    await updateAssignmentsLocalization();
    // Force full rebuild by changing state and providing a key to MaterialApp
    setState(() {
      _locale = Locale(localeCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData baseLight = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Colors.black,
      appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0),
      cardColor: Color(0xFFF7F7F7),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
            fontSize: 30, fontWeight: FontWeight.w800, color: Colors.black),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
      ),
    );

    final ThemeData baseDark = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.white,
      appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0),
      cardColor: Color(0xFF141414),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
            fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
      ),
    );

    final ThemeData theme = isDark ? baseDark : baseLight;

    return MaterialApp(
      locale: _locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ru'), Locale('en')],
      debugShowCheckedModeBanner: false,
      title: L.t('app_title'),
      theme: theme,
      home: AuthGate(
          onThemeChanged: toggleTheme,
          isDark: isDark,
          onLocaleChanged: changeLanguage),
    );
  }
}

class LoginForm extends StatefulWidget {
  final Map<String, UserModel> users;
  final void Function(String) onLogin;
  const LoginForm({super.key, required this.users, required this.onLogin});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  void _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(L.t('fill_all'))));
      return;
    }
    final u = widget.users[email];
    if (u != null && u.password == pass) {
      widget.onLogin(email);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(L.t('invalid_credentials'))));
    }
  }

  void _openReset() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(users: widget.users)));
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).primaryColor;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: L.t('email'))),
          const SizedBox(height: 12),
          TextField(
              controller: _passCtrl,
              decoration: InputDecoration(labelText: L.t('password')),
              obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: _login,
              child: SizedBox(
                  width: double.infinity,
                  child: Center(child: Text(L.t('login'))))),
          const SizedBox(height: 12),
          TextButton(
              onPressed: _openReset,
              child: Text(L.t('forgot_password'),
                  style: TextStyle(color: textColor))),
        ],
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  final Function(UserModel) onRegister;
  final Map<String, UserModel> users;
  const RegisterForm(
      {super.key, required this.onRegister, required this.users});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  void _register() {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final conf = _confirmCtrl.text;
    final first = _firstCtrl.text.trim();
    final last = _lastCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if ([email, pass, conf, first, last, pin].any((s) => s.isEmpty)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(L.t('fill_all'))));
      return;
    }
    if (pass != conf) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(L.t('passwords_not_match'))));
      return;
    }
    if (pin.length != 4 || int.tryParse(pin) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PIN должен состоять из 4 цифр')));
      return;
    }
    if (widget.users.containsKey(email)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(L.t('user_exists'))));
      return;
    }

    final user = UserModel(
        email: email,
        password: pass,
        firstName: first,
        lastName: last,
        pin: pin);
    widget.onRegister(user);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          TextField(
              controller: _firstCtrl,
              decoration: InputDecoration(labelText: L.t('first_name'))),
          const SizedBox(height: 12),
          TextField(
              controller: _lastCtrl,
              decoration: InputDecoration(labelText: L.t('last_name'))),
          const SizedBox(height: 12),
          TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: L.t('email'))),
          const SizedBox(height: 12),
          TextField(
              controller: _passCtrl,
              decoration: InputDecoration(labelText: L.t('password')),
              obscureText: true),
          const SizedBox(height: 12),
          TextField(
              controller: _confirmCtrl,
              decoration: InputDecoration(labelText: L.t('confirm_password')),
              obscureText: true),
          const SizedBox(height: 12),
          TextField(
              controller: _pinCtrl,
              decoration: InputDecoration(labelText: L.t('pin')),
              keyboardType: TextInputType.number),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: _register,
              child: SizedBox(
                  width: double.infinity,
                  child: Center(child: Text(L.t('register'))))),
        ],
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  final Map<String, UserModel> users;
  const ResetPasswordScreen({super.key, required this.users});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool step2 = false;

  void _verify() {
    final email = _emailCtrl.text.trim();
    final pin = _pinCtrl.text.trim();
    final u = widget.users[email];
    if (u != null && u.pin == pin) {
      setState(() {
        step2 = true;
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(L.t('invalid_pin'))));
    }
  }

  void _reset() async {
    final email = _emailCtrl.text.trim();
    final newPass = _newCtrl.text;
    final conf = _confirmCtrl.text;
    if (newPass.isEmpty || conf.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(L.t('fill_all'))));
      return;
    }
    if (newPass != conf) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(L.t('passwords_not_match'))));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('users_map');
    if (raw != null) {
      Map<String, dynamic> m = jsonDecode(raw);
      if (m.containsKey(email)) {
        m[email]['password'] = newPass;
        await prefs.setString('users_map', jsonEncode(m));
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(L.t('reset_success'))));
        Navigator.pop(context);
        return;
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(L.t('invalid_pin'))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L.t('reset_password')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: step2
            ? Column(
                children: [
                  TextField(
                      controller: _newCtrl,
                      decoration:
                          InputDecoration(labelText: L.t('enter_new_password')),
                      obscureText: true),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _confirmCtrl,
                      decoration: InputDecoration(
                          labelText: L.t('confirm_new_password')),
                      obscureText: true),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _reset, child: Text(L.t('submit'))),
                ],
              )
            : Column(
                children: [
                  TextField(
                      controller: _emailCtrl,
                      decoration:
                          InputDecoration(labelText: L.t('enter_email'))),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _pinCtrl,
                      decoration: InputDecoration(labelText: L.t('enter_pin')),
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _verify, child: Text(L.t('submit'))),
                ],
              ),
      ),
    );
  }
}

// ------------------------------
// AuthGate
// ------------------------------
class LoginRegisterTabs extends StatelessWidget {
  final void Function(UserModel) onRegister;
  final void Function(String) onLogin;
  final Map<String, UserModel> users;

  const LoginRegisterTabs({
    super.key,
    required this.onRegister,
    required this.onLogin,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).primaryColor;
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(children: [
          TabBar(
            labelColor: textColor,
            unselectedLabelColor: textColor.withAlpha((0.6 * 255).round()),
            tabs: [Tab(text: L.t('login')), Tab(text: L.t('register'))],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(children: [
              LoginForm(users: users, onLogin: onLogin),
              RegisterForm(onRegister: onRegister, users: users),
            ]),
          ),
        ]),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  final void Function(bool) onThemeChanged;
  final bool isDark;
  final void Function(String) onLocaleChanged;
  const AuthGate(
      {super.key,
      required this.onThemeChanged,
      required this.isDark,
      required this.onLocaleChanged});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? currentEmail;
  Map<String, UserModel> users = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadLoggedIn();
  }

  Future<void> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('users_map');
    if (raw != null) {
      Map<String, dynamic> m = jsonDecode(raw);
      final map = <String, UserModel>{};
      m.forEach((k, v) {
        map[k] = UserModel.fromMap(v);
      });
      setState(() => users = map);
    }
  }

  Future<void> _saveUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final m = users.map((k, v) => MapEntry(k, v.toMap()));
    await prefs.setString('users_map', jsonEncode(m));
  }

  Future<void> _loadLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentEmail = prefs.getString('logged_in_email');
    });
  }

  Future<void> _setLoggedIn(String? email) async {
    final prefs = await SharedPreferences.getInstance();
    if (email == null) {
      await prefs.remove('logged_in_email');
    } else {
      await prefs.setString('logged_in_email', email);
    }
    setState(() {
      currentEmail = email;
    });
  }

  void onRegister(UserModel user) {
    users[user.email] = user;
    _saveUsers();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(L.t('registered'))));
  }

  void onLogin(String email) {
    _setLoggedIn(email);
  }

  void onLogout() {
    _setLoggedIn(null);
  }

  void onClearUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('users_map');
    await prefs.remove('logged_in_email');
    if (!mounted) return;
    setState(() {
      users.clear();
      currentEmail = null;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(L.t('users_cleared'))));
  }

  @override
  Widget build(BuildContext context) {
    if (currentEmail != null && users.containsKey(currentEmail)) {
      final user = users[currentEmail];
      if (user != null) {
        return MainAppScreen(
          user: user,
          onLogout: onLogout,
          isDark: widget.isDark,
          onThemeChanged: widget.onThemeChanged,
          onLocaleChanged: widget.onLocaleChanged,
        );
      }
    }
    return Scaffold(
      body: SafeArea(
        child: LoginRegisterTabs(
          onRegister: (u) {
            onRegister(u);
            onLogin(u.email);
          },
          onLogin: (email) => onLogin(email),
          users: users,
        ),
      ),
    );
  }
}

// ------------------------------
// MainAppScreen + Dashboard + other screens
// ------------------------------
class MainAppScreen extends StatefulWidget {
  final UserModel user;
  final VoidCallback onLogout;
  final bool isDark;
  final void Function(bool) onThemeChanged;
  final void Function(String) onLocaleChanged;

  const MainAppScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.isDark,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(),
      ProfileScreen(
        user: widget.user,
        onLogout: widget.onLogout,
        isDark: widget.isDark,
        onThemeChanged: widget.onThemeChanged,
        onLocaleChanged: widget.onLocaleChanged,
        currentLocale: L.locale,
      ),
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_rounded), label: ''),
            BottomNavigationBarItem(
              icon: const Icon(Icons.face_retouching_natural_rounded), label: ''),
        ],
      ),
    );
  }
}

// ------------------------------
// DashboardScreen listens to AppState to update counts quickly
// ------------------------------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _pending = 0;
  int _unreadAnnouncements = 0;
  int _goalsCount = 0;
  int _subjectsCount = 8;

  late final VoidCallback _reportsListener;
  late final VoidCallback _annListener;
  late final VoidCallback _goalsListener;
  late final VoidCallback _assignmentsListener;

  @override
  void initState() {
    super.initState();
    _pending = AppState.instance.assignmentsPending.value;
    _unreadAnnouncements = AppState.instance.unreadAnnouncements.value;
    _goalsCount = AppState.instance.goalsCount.value;
    _subjectsCount = AppState.instance.reportsCount.value;
    _reportsListener = () =>
        setState(() => _subjectsCount = AppState.instance.reportsCount.value);
    AppState.instance.reportsCount.addListener(_reportsListener);

    _annListener = () => setState(() =>
        _unreadAnnouncements = AppState.instance.unreadAnnouncements.value);
    _goalsListener =
        () => setState(() => _goalsCount = AppState.instance.goalsCount.value);
    _assignmentsListener = () =>
        setState(() => _pending = AppState.instance.assignmentsPending.value);

    AppState.instance.unreadAnnouncements.addListener(_annListener);
    AppState.instance.goalsCount.addListener(_goalsListener);
    AppState.instance.assignmentsPending.addListener(_assignmentsListener);
  }

  @override
  void dispose() {
    AppState.instance.unreadAnnouncements.removeListener(_annListener);
    AppState.instance.goalsCount.removeListener(_goalsListener);
    AppState.instance.assignmentsPending.removeListener(_assignmentsListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<_TileItem> items = [
      _TileItem(
          icon: Icons.edit,
          title: L.t('assignments_title'),
          subtitle: '$_pending ${L.t('items_pending')}'),
      _TileItem(
          icon: Icons.calendar_today,
          title: L.t('calendar_title'),
          subtitle:
              '${L.t('today')}: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}'),
      _TileItem(
          icon: Icons.announcement,
          title: L.t('announcements'),
          subtitle: '$_unreadAnnouncements'),
      _TileItem(
          icon: Icons.track_changes,
          title: L.t('my_goals'),
          subtitle: '$_goalsCount'),
      _TileItem(
          icon: Icons.bar_chart,
          title: L.t('progress_reports'),
          subtitle: '$_subjectsCount ${L.t('reports_count')}'),
      _TileItem(icon: Icons.schedule, title: L.t('timetable'), subtitle: ''),
      _TileItem(
          icon: Icons.event_available,
          title: L.t('attendance'),
          subtitle: '95%'),
      _TileItem(
          icon: Icons.library_books,
          title: L.t('school_policies'),
          subtitle: ''),
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MYP 2025-2026', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: Text(
                      '${L.t('today')}: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                      style: const TextStyle(fontWeight: FontWeight.w500))),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
              children: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final it = entry.value;
                return GestureDetector(
                  onTap: () async {
                    if (idx == 0) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AssignmentsScreen()));
                    } else if (idx == 1) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CalendarScreen()));
                    } else if (idx == 2) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AnnouncementsScreen()));
                    } else if (idx == 3) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GoalsScreen()));
                    } else if (idx == 4) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProgressReportsScreen()));
                    } else if (idx == 5) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TimetableScreen()));
                    } else if (idx == 6) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AttendanceScreen()));
                    } else if (idx == 7) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SchoolPoliciesScreen()));
                    }
                  },
                  child: _DashboardCard(item: it),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

// ------------------------------
// AssignmentsScreen (renders displayTitle())
// ------------------------------
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  List<Assignment> _assignments = [];
  bool _loading = true;
  String _currentLocale = L.locale;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentLocale != L.locale) {
      _currentLocale = L.locale;
      _load();
    }
  }

  Future<void> _load() async {
    final list = await loadAssignmentsFromPrefs();
    if (mounted) {
      setState(() {
        _assignments = list;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    await saveAssignmentsToPrefs(_assignments);
  }

  Future<void> _toggleDone(int idx, bool? value) async {
    setState(() => _assignments[idx].done = value ?? false);
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = _assignments.map((a) => a.subjectKey).toSet().toList()
      ..sort();
    return Scaffold(
      appBar: AppBar(
        title: Text(L.t('assignments_title')),
        actions: [
          IconButton(
            tooltip: L.t('mark_all_done'),
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              // Capture messenger + navigator before awaiting to avoid using
              // the BuildContext across async gaps.
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              setState(() {
                for (var a in _assignments) {
                  a.done = true;
                }
              });
              await _save();
              if (!mounted) return;
              messenger
                  .showSnackBar(SnackBar(content: Text(L.t('mark_all_done'))));
              navigator.pop(true);
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Column(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${L.t('assignments_count')}: ${_assignments.length}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                          '${_assignments.where((a) => !a.done).length} ${L.t('items_pending')}',
                          style: TextStyle(color: theme.primaryColor)),
                    ]),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: subjects.map((subjectKey) {
                      final items = _assignments
                          .where((a) => a.subjectKey == subjectKey)
                          .toList();
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          key: ValueKey('subject_${subjectKey}_${L.locale}'),
                          children: [
                            const SizedBox(height: 8),
                            Text(localizedSubjectName(subjectKey),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 8),
                            ...items.map((a) {
                              final idx =
                                  _assignments.indexWhere((x) => x.id == a.id);
                              return Card(
                                color: theme.cardColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: Checkbox(
                                      value: a.done,
                                      onChanged: (v) => _toggleDone(idx, v)),
                                  title: Text(a.displayTitle(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                      '${a.dueShortString()} • ${a.dueHumanReadable()}'),
                                  trailing: a.done
                                      ? const Icon(Icons.check_circle,
                                          color: Colors.green)
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                              color: theme.primaryColor
                                                  .withAlpha(
                                                      (0.08 * 255).round()),
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Text(L.t('pending_label'),
                                              style: TextStyle(
                                                  color: theme.primaryColor,
                                                  fontSize: 12)),
                                        ),
                                  onTap: () => _toggleDone(idx, !a.done),
                                ),
                              );
                            }),
                          ]);
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Capture navigator before awaiting to avoid using BuildContext after await
                        final navigator = Navigator.of(context);
                        await _save();
                        if (!mounted) return;
                        navigator.pop(true);
                      },
                      child: Text(L.t('save_back')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(L.t('cancel')),
                  ),
                ])
              ]),
            ),
    );
  }
}

// ------------------------------
// AnnouncementsScreen (fixed layout + updates AppState immediately)
// ------------------------------
class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});
  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Announcement> _announcements = [];
  bool _loading = true;
  String _currentLocale = L.locale;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentLocale != L.locale) {
      _currentLocale = L.locale;
      _load();
    }
  }

  Future<void> _load() async {
    final list = await loadAnnouncementsFromPrefs();
    if (mounted) {
      setState(() {
        _announcements = list;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    await saveAnnouncementsToPrefs(_announcements);
  }

  void _markRead(int idx) async {
    if (!_announcements[idx].read) {
      setState(() {
        _announcements[idx].read = true;
      });
      await _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(L.t('announcements'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
              ? Center(child: Text(L.t('no_announcements')))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.separated(
                    itemCount: _announcements.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final a = _announcements[index];
                      return Card(
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.primaryColor
                                    .withAlpha((0.12 * 255).round()),
                                child: Icon(Icons.announcement,
                                    color: theme.primaryColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    const SizedBox(height: 6),
                                    Text(
                                      a.body,
                                      style: TextStyle(
                                          color: theme
                                              .textTheme.bodyMedium?.color),
                                      softWrap: true,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(a.dateIso,
                                            style: TextStyle(
                                                color: theme.primaryColor
                                                    .withAlpha(
                                                        (0.6 * 255).round()),
                                                fontSize: 12)),
                                        if (!a.read)
                                          TextButton(
                                            onPressed: () {
                                              _markRead(index);
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              minimumSize: const Size(0, 32),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(L.t('mark_complete'),
                                                style: TextStyle(
                                                    color: theme.primaryColor,
                                                    fontSize: 12)),
                                          )
                                        else
                                          const Icon(Icons.done,
                                              color: Colors.green, size: 18),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ------------------------------
// GoalsScreen (removed top plus, kept FAB; updates AppState quickly)
// ------------------------------
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Goal> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await loadGoalsFromPrefs();
    if (mounted) {
      setState(() {
        _goals = list;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    await saveGoalsToPrefs(_goals);
  }

  Future<void> _addOrEditGoal({Goal? existing}) async {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final isEditing = existing != null;
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? L.t('edit_goal') : L.t('add_goal')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: titleCtrl,
                decoration: InputDecoration(labelText: L.t('goal_title'))),
            const SizedBox(height: 8),
            TextField(
                controller: descCtrl,
                decoration:
                    InputDecoration(labelText: L.t('goal_description'))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(L.t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isEmpty) return;
              if (isEditing) {
                existing.title = titleCtrl.text.trim();
                existing.description = descCtrl.text.trim();
              } else {
                final newGoal = Goal(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                  done: false,
                  createdIso: DateTime.now().toIso8601String(),
                );
                _goals.insert(0, newGoal);
              }
              final navigator = Navigator.of(ctx);
              await _save();
              navigator.pop(true);
            },
            child: Text(L.t('save')),
          ),
        ],
      ),
    );
    if (res == true) setState(() {});
  }

  void _toggleDone(int idx) async {
    setState(() {
      _goals[idx].done = !_goals[idx].done;
    });
    await _save();
  }

  void _deleteGoal(int idx) async {
    setState(() {
      _goals.removeAt(idx);
    });
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(L.t('my_goals')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _goals.isEmpty
              ? Center(child: Text(L.t('no_goals')))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final g = _goals[index];
                      return Dismissible(
                        key: ValueKey(g.id),
                        background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white)),
                        secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white)),
                        onDismissed: (_) => _deleteGoal(index),
                        child: Card(
                          color: theme.cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: Checkbox(
                                value: g.done,
                                onChanged: (_) => _toggleDone(index)),
                            title: Text(g.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    decoration: g.done
                                        ? TextDecoration.lineThrough
                                        : null)),
                            subtitle: g.description != null
                                ? Text(g.description!)
                                : null,
                            trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _addOrEditGoal(existing: g)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditGoal(),
        tooltip: L.t('add_goal'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ------------------------------
// AttendanceScreen
// ------------------------------
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(L.t('attendance'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(L.t('attendance_rate'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 12),
                    Text('95%',
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 48,
                            color: theme.primaryColor)),
                    const SizedBox(height: 8),
                    Text('191 ${L.t('present')} out of 200 days',
                        style: TextStyle(
                            color: theme.primaryColor
                                .withAlpha((0.6 * 255).round()))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(L.t('semester_fall'),
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(L.t('present'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text('92',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green)),
                        ]),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(L.t('absent'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text('5',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.red)),
                        ]),
                    const SizedBox(height: 8),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(L.t('late'),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          Text('3',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.orange)),
                        ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------
// SchoolPoliciesScreen
// ------------------------------
class SchoolPoliciesScreen extends StatelessWidget {
  const SchoolPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final policies = [
      {
        'title': L.t('dress_code'),
        'desc': L.t('dress_code_desc'),
      },
      {
        'title': L.t('mobile_devices'),
        'desc': L.t('mobile_desc'),
      },
      {
        'title': L.t('classroom_conduct'),
        'desc': L.t('conduct_desc'),
      },
      {
        'title': L.t('homework_policy'),
        'desc': L.t('homework_desc'),
      },
      {
        'title': L.t('safety_policy'),
        'desc': L.t('safety_desc'),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(L.t('school_policies'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemCount: policies.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final p = policies[index];
            return Card(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['title'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p['desc'] as String,
                      style: TextStyle(
                        color:
                            theme.primaryColor.withAlpha((0.7 * 255).round()),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ------------------------------
// CalendarScreen improvements:
// - Cache per-month event lists
// - Compute dynamic grid height based on weeks
// - Use LayoutBuilder to adapt to available height and avoid overflow
// - Use lighter cell widgets and minimal padding to reduce layout cost
// ------------------------------
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final List<DateTime> months = List.generate(10, (i) => DateTime(2025, 9 + i));
  late final List<CalendarEvent> events;
  int page = 0;
  late final PageController _pageController;
  final Map<int, List<CalendarEvent>> _eventsByMonth = {};

  @override
  void initState() {
    super.initState();
    events = buildAcademicEvents();
    _groupEventsByMonth();
    final now = DateTime.now();
    final idx =
        months.indexWhere((m) => m.year == now.year && m.month == now.month);
    page = idx == -1 ? 0 : idx;
    _pageController = PageController(initialPage: page);
  }

  void _groupEventsByMonth() {
    _eventsByMonth.clear();
    for (var e in events) {
      final key = e.date.year * 100 + e.date.month;
      _eventsByMonth.putIfAbsent(key, () => []).add(e);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool hasEventOn(DateTime day) {
    final key = day.year * 100 + day.month;
    final list = _eventsByMonth[key];
    if (list == null) return false;
    return list.any((ev) => isSameDate(ev.date, day));
  }

  List<CalendarEvent> eventsOn(DateTime day) {
    final key = day.year * 100 + day.month;
    final list = _eventsByMonth[key];
    if (list == null) return [];
    return list.where((ev) => isSameDate(ev.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(L.t('calendar_title'))),
      body: LayoutBuilder(builder: (context, constraints) {
        // Compute a pageView height that can fit the largest month (by weeks)
        const double cellHeight = 48.0;
        const double titleArea = 56.0;
        const double weekdayHeader = 28.0 + 6.0;
        const double extraPadding = 24.0; // container paddings
        final maxAllowed = constraints.maxHeight * 0.6;

        double maxRequired = 220.0; // minimum
        for (var m in months) {
          final first = DateTime(m.year, m.month, 1);
          final weekdayOffset = (first.weekday % 7);
          final daysInMonth = DateTime(m.year, m.month + 1, 0).day;
          final weeks = ((weekdayOffset + daysInMonth) / 7.0).ceil();
          final double idealGrid = weeks * cellHeight;
          final req = titleArea + weekdayHeader + idealGrid + extraPadding;
          if (req > maxRequired) maxRequired = req;
        }
        // Round to whole pixels to avoid fractional overflows
        final pageViewHeight = min(maxAllowed, maxRequired).floorToDouble();
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: pageViewHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: months.length,
                    onPageChanged: (p) => setState(() => page = p),
                    itemBuilder: (c, idx) {
                      final month = months[idx];
                      return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: _buildMonth(month, theme));
                    },
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${localizedMonthName(months[page].month)} ${months[page].year}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                          '${L.t('today')}: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                          style: TextStyle(color: theme.primaryColor)),
                    ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Builder(builder: (ctx) {
                  final key = months[page].year * 100 + months[page].month;
                  final list = _eventsByMonth[key] ?? [];
                  if (list.isEmpty) {
                    return Center(
                        child: Text(L.t('no_announcements'))); // reuse string
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final e = list[i];
                      return Card(
                        color: theme.cardColor,
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: theme.primaryColor
                                  .withAlpha((0.12 * 255).round()),
                              child:
                                  Icon(Icons.event, color: theme.primaryColor)),
                          title: Text(e.title),
                          subtitle: e.note != null
                              ? Text(e.note!)
                              : Text(_formatLongDate(e.date)),
                        ),
                      );
                    },
                  );
                }),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMonth(DateTime month, ThemeData theme) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxHeight = constraints.maxHeight;
      final first = DateTime(month.year, month.month, 1);
      final weekdayOffset = (first.weekday % 7);
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

      final weekDays = L.locale == 'ru'
          ? ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб']
          : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

      final cells = <int?>[];
      for (int i = 0; i < weekdayOffset; i++) {
        cells.add(null);
      }
      for (int d = 1; d <= daysInMonth; d++) {
        cells.add(d);
      }
      while (cells.length % 7 != 0) {
        cells.add(null);
      }

      final weeks = (cells.length / 7).ceil();

      const double titleArea = 56.0;
      const double weekdayHeader = 28.0;
      const double gaps = 18.0;

      final double availableForGrid =
          maxHeight - titleArea - weekdayHeader - gaps;
      final double idealCell = 40.0;
      final double cellHeight = max(
          24.0,
          min(idealCell,
              (availableForGrid > 0 ? (availableForGrid / weeks) : idealCell)));

      final rows =
          List.generate(weeks, (r) => cells.skip(r * 7).take(7).toList());

      Widget buildCell(int? val) {
        if (val == null) return const SizedBox.shrink();
        final day = DateTime(month.year, month.month, val);
        final isToday = isSameDate(day, DateTime.now());
        final hasEvent = hasEventOn(day);
        return SizedBox(
          height: cellHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$val',
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (hasEvent)
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  '${localizedMonthName(month.month)} ${month.year}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _pageControllerPrevious(),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _pageControllerNext(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: weekdayHeader,
            child: Row(
              children: weekDays
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Table(
              defaultColumnWidth: const FlexColumnWidth(),
              children: rows.map((weekRow) {
                return TableRow(
                  children: weekRow.map((cellVal) {
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: buildCell(cellVal),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  // A simpler month renderer that accepts a fixed maxHeight. This avoids
  // nested LayoutBuilder and ensures deterministic heights to prevent
  // fractional overflows.
  Widget _buildMonthFixed(DateTime month, ThemeData theme, double maxHeight) {
    final first = DateTime(month.year, month.month, 1);
    final weekdayOffset = (first.weekday % 7); // Sunday=0
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final weekDays = L.locale == 'ru'
        ? ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб']
        : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    final cells = <int?>[]; // null = empty
    for (int i = 0; i < weekdayOffset; i++) {
      cells.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(d);
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final weeks = (cells.length / 7).ceil();

    // reserved heights
    const double titleArea = 56.0;
    const double weekdayHeader = 28.0;
    const double gaps = 18.0;

    final double availableForGrid =
        max(24.0, maxHeight - titleArea - weekdayHeader - gaps);
    final double cellHeight = max(24.0, availableForGrid / weeks);
    final double gridHeight = cellHeight * weeks + weekdayHeader + 6.0;

    final rows =
        List.generate(weeks, (r) => cells.skip(r * 7).take(7).toList());

    Widget buildCell(int? val) {
      if (val == null) return const SizedBox.shrink();
      final day = DateTime(month.year, month.month, val);
      final isToday = isSameDate(day, DateTime.now());
      final hasEvent = hasEventOn(day);
      return Container(
        height: cellHeight,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$val',
              style: TextStyle(
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13),
              textAlign: TextAlign.left),
          const Spacer(),
          if (hasEvent)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(L.t('event_label'),
                  style: TextStyle(fontSize: 10, color: theme.primaryColor),
                  textAlign: TextAlign.center),
            )
          else
            const SizedBox(height: 8),
        ]),
      );
    }

    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Text('${localizedMonthName(month.month)} ${month.year}',
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const Spacer(),
          IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final idx = months.indexWhere(
                    (m) => m.year == month.year && m.month == month.month);
                if (idx > 0) _pageControllerPrevious();
              }),
          IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final idx = months.indexWhere(
                    (m) => m.year == month.year && m.month == month.month);
                if (idx < months.length - 1) _pageControllerNext();
              }),
        ]),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: gridHeight,
        child: Column(children: [
          SizedBox(
            height: weekdayHeader,
            child: Row(
              children: weekDays
                  .map((d) => Expanded(
                      child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12)))))
                  .toList(),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: cellHeight * weeks,
            child: Table(
              defaultColumnWidth: FlexColumnWidth(),
              children: rows.map((weekRow) {
                return TableRow(
                  children: weekRow.map((cellVal) {
                    return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: buildCell(cellVal));
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ]),
      ),
    ]);
  }

  void _pageControllerPrevious() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _pageControllerNext() {
    _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }
}

// ------------------------------
// Utilities & UI helpers
// ------------------------------
bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
String _formatLongDate(DateTime d) =>
    '${d.day} ${localizedMonthName(d.month)} ${d.year}';

class _TileItem {
  final IconData icon;
  final String title;
  final String subtitle;
  _TileItem({required this.icon, required this.title, required this.subtitle});
}

class _DashboardCard extends StatelessWidget {
  final _TileItem item;
  const _DashboardCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final bg = theme.cardColor;
    final primary = theme.primaryColor;
    final textPrimary = theme.textTheme.bodyMedium?.color ??
        (dark ? Colors.white : Colors.black87);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!dark)
            const BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
              color: dark ? Colors.white12 : Colors.black12,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(item.icon, color: primary, size: 26),
        ),
        const SizedBox(height: 12),
        Expanded(
            child: Text(item.title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textPrimary))),
        if (item.subtitle.isNotEmpty)
          Text(item.subtitle,
              style: TextStyle(
                  fontSize: 13,
                  color: textPrimary.withAlpha((0.7 * 255).round()))),
      ]),
    );
  }
}

// ------------------------------
// Profile, ThemeSwitcher, LanguageSelector
// ------------------------------
class ProfileScreen extends StatelessWidget {
  final UserModel user;
  final VoidCallback onLogout;
  final bool isDark;
  final void Function(bool) onThemeChanged;
  final void Function(String) onLocaleChanged;
  final String currentLocale;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
    required this.isDark,
    required this.onThemeChanged,
    required this.onLocaleChanged,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          CircleAvatar(
              radius: 44,
              backgroundColor: Colors.grey.withAlpha((0.12 * 255).round()),
              child: Icon(Icons.person, size: 48, color: primary)),
          const SizedBox(height: 16),
          Text('${user.firstName} ${user.lastName}',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: primary)),
          const SizedBox(height: 6),
          Text(user.email,
              style: TextStyle(color: primary.withAlpha((0.8 * 255).round()))),
          const SizedBox(height: 24),
          ListTile(
            leading: Icon(Icons.color_lens, color: primary),
            title: Text(L.t('choose_theme')),
            trailing: ThemeSwitcher(
                isDark: isDark,
                onChanged: (val) {
                  onThemeChanged(val);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(L.t('theme_updated'))));
                }),
          ),
          ListTile(
            leading: Icon(Icons.language, color: primary),
            title: Text(L.t('choose_language')),
            trailing: LanguageSelector(
                current: currentLocale,
                onLocaleChanged: (code) {
                  onLocaleChanged(code);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(L.t('language_updated'))));
                }),
          ),
          const SizedBox(height: 12),
          Text('MYP 2025-2026',
              style: TextStyle(color: primary.withAlpha((0.6 * 255).round()))),
          const Spacer(),
          ElevatedButton(
              onPressed: onLogout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: SizedBox(
                  width: double.infinity,
                  child: Center(child: Text(L.t('logout'))))),
        ]),
      ),
    );
  }
}

class ThemeSwitcher extends StatefulWidget {
  final bool isDark;
  final void Function(bool) onChanged;
  const ThemeSwitcher(
      {super.key, required this.isDark, required this.onChanged});
  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  late bool _isDark;
  @override
  void initState() {
    super.initState();
    _isDark = widget.isDark;
  }

  Future<void> _toggle(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', val);
    setState(() => _isDark = val);
    widget.onChanged(val);
  }

  @override
  Widget build(BuildContext context) =>
      Switch(value: _isDark, onChanged: (v) => _toggle(v));
}

class LanguageSelector extends StatefulWidget {
  final String current;
  final void Function(String) onLocaleChanged;
  const LanguageSelector(
      {super.key, required this.current, required this.onLocaleChanged});
  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late String _lang;
  @override
  void initState() {
    super.initState();
    _lang = widget.current;
  }

  Future<void> _setLang(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
    setState(() => _lang = code);
    L.locale = code;
    widget.onLocaleChanged(code);
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _lang,
      underline: const SizedBox(),
      items: const [
        DropdownMenuItem(value: 'ru', child: Text('Русский')),
        DropdownMenuItem(value: 'en', child: Text('English')),
      ],
      onChanged: (v) {
        if (v != null) _setLang(v);
      },
    );
  }
}

class ProgressReportsScreen extends StatefulWidget {
  const ProgressReportsScreen({super.key});
  @override
  State<ProgressReportsScreen> createState() => _ProgressReportsScreenState();
}

class _ProgressReportsScreenState extends State<ProgressReportsScreen> {
  int _tabIndex = 0;
  String _selectedSubject = 'mathematics';

  final Map<String, Map<String, List<Map<String, dynamic>>>> _subjectData = {
    'mathematics': {
      'grades': [
        {'month': 'Sep', 'value': 5.5},
        {'month': 'Oct', 'value': 6.0},
        {'month': 'Nov', 'value': 6.8},
        {'month': 'Dec', 'value': 8.5},
        {'month': 'Jan', 'value': 8.0},
        {'month': 'Feb', 'value': 8.0},
      ],
      'late': [
        {'month': 'Sep', 'value': 3.0},
        {'month': 'Oct', 'value': 2.0},
        {'month': 'Nov', 'value': 3.5},
        {'month': 'Dec', 'value': 7.0},
        {'month': 'Jan', 'value': 5.0},
        {'month': 'Feb', 'value': 5.0},
      ],
    },
    'english': {
      'grades': [
        {'month': 'Sep', 'value': 7.0},
        {'month': 'Oct', 'value': 7.5},
        {'month': 'Nov', 'value': 8.0},
        {'month': 'Dec', 'value': 8.2},
        {'month': 'Jan', 'value': 8.5},
        {'month': 'Feb', 'value': 9.0},
      ],
      'late': [
        {'month': 'Sep', 'value': 1.0},
        {'month': 'Oct', 'value': 0.0},
        {'month': 'Nov', 'value': 1.0},
        {'month': 'Dec', 'value': 2.0},
        {'month': 'Jan', 'value': 1.0},
        {'month': 'Feb', 'value': 0.0},
      ],
    },
    'science': {
      'grades': [
        {'month': 'Sep', 'value': 6.0},
        {'month': 'Oct', 'value': 6.5},
        {'month': 'Nov', 'value': 7.0},
        {'month': 'Dec', 'value': 7.5},
        {'month': 'Jan', 'value': 7.0},
        {'month': 'Feb', 'value': 7.5},
      ],
      'late': [
        {'month': 'Sep', 'value': 2.0},
        {'month': 'Oct', 'value': 3.0},
        {'month': 'Nov', 'value': 2.0},
        {'month': 'Dec', 'value': 4.0},
        {'month': 'Jan', 'value': 3.0},
        {'month': 'Feb', 'value': 2.0},
      ],
    },
    'history': {
      'grades': [
        {'month': 'Sep', 'value': 8.0},
        {'month': 'Oct', 'value': 8.5},
        {'month': 'Nov', 'value': 8.0},
        {'month': 'Dec', 'value': 9.0},
        {'month': 'Jan', 'value': 8.5},
        {'month': 'Feb', 'value': 9.0},
      ],
      'late': [
        {'month': 'Sep', 'value': 0.0},
        {'month': 'Oct', 'value': 1.0},
        {'month': 'Nov', 'value': 0.0},
        {'month': 'Dec', 'value': 1.0},
        {'month': 'Jan', 'value': 0.0},
        {'month': 'Feb', 'value': 1.0},
      ],
    },
    'art': {
      'grades': [
        {'month': 'Sep', 'value': 9.0},
        {'month': 'Oct', 'value': 9.5},
        {'month': 'Nov', 'value': 9.0},
        {'month': 'Dec', 'value': 10.0},
        {'month': 'Jan', 'value': 9.5},
        {'month': 'Feb', 'value': 9.5},
      ],
      'late': [
        {'month': 'Sep', 'value': 0.0},
        {'month': 'Oct', 'value': 0.0},
        {'month': 'Nov', 'value': 1.0},
        {'month': 'Dec', 'value': 0.0},
        {'month': 'Jan', 'value': 0.0},
        {'month': 'Feb', 'value': 0.0},
      ],
    },
    'pe': {
      'grades': [
        {'month': 'Sep', 'value': 8.5},
        {'month': 'Oct', 'value': 8.0},
        {'month': 'Nov', 'value': 8.5},
        {'month': 'Dec', 'value': 9.0},
        {'month': 'Jan', 'value': 8.5},
        {'month': 'Feb', 'value': 9.0},
      ],
      'late': [
        {'month': 'Sep', 'value': 1.0},
        {'month': 'Oct', 'value': 2.0},
        {'month': 'Nov', 'value': 1.0},
        {'month': 'Dec', 'value': 0.0},
        {'month': 'Jan', 'value': 1.0},
        {'month': 'Feb', 'value': 0.0},
      ],
    },
    'spanish': {
      'grades': [
        {'month': 'Sep', 'value': 6.5},
        {'month': 'Oct', 'value': 7.0},
        {'month': 'Nov', 'value': 7.5},
        {'month': 'Dec', 'value': 7.0},
        {'month': 'Jan', 'value': 7.5},
        {'month': 'Feb', 'value': 8.0},
      ],
      'late': [
        {'month': 'Sep', 'value': 2.0},
        {'month': 'Oct', 'value': 1.0},
        {'month': 'Nov', 'value': 2.0},
        {'month': 'Dec', 'value': 3.0},
        {'month': 'Jan', 'value': 2.0},
        {'month': 'Feb', 'value': 1.0},
      ],
    },
    'design': {
      'grades': [
        {'month': 'Sep', 'value': 7.5},
        {'month': 'Oct', 'value': 8.0},
        {'month': 'Nov', 'value': 8.5},
        {'month': 'Dec', 'value': 8.0},
        {'month': 'Jan', 'value': 8.5},
        {'month': 'Feb', 'value': 9.0},
      ],
      'late': [
        {'month': 'Sep', 'value': 1.0},
        {'month': 'Oct', 'value': 1.0},
        {'month': 'Nov', 'value': 0.0},
        {'month': 'Dec', 'value': 2.0},
        {'month': 'Jan', 'value': 1.0},
        {'month': 'Feb', 'value': 0.0},
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subjectInfo = _subjectData[_selectedSubject]!;
    final data = _tabIndex == 0 ? subjectInfo['grades']! : subjectInfo['late']!;
    final maxValue = _tabIndex == 0 ? 10.0 : 8.0;
    final avgGrade = subjectInfo['grades']!
            .map((e) => e['value'] as double)
            .reduce((a, b) => a + b) /
        subjectInfo['grades']!.length;
    final totalLate = subjectInfo['late']!
        .map((e) => e['value'] as double)
        .reduce((a, b) => a + b);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                L.t('progress_reports'),
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              // Subject selector
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedSubject,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: theme.primaryColor),
                  items: _subjectData.keys.map((key) {
                    return DropdownMenuItem(
                      value: key,
                      child: Text(
                        localizedSubjectName(key),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSubject = val);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Tab switcher
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 0
                                ? (isDark ? Colors.grey[800] : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: _tabIndex == 0
                                ? [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4)
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              L.t('grades'),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _tabIndex == 0
                                      ? theme.primaryColor
                                      : Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 1
                                ? (isDark ? Colors.grey[800] : Colors.white)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: _tabIndex == 1
                                ? [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4)
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              L.t('days_late'),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _tabIndex == 1
                                      ? theme.primaryColor
                                      : Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Chart
              Expanded(
                child: _buildChart(data, maxValue, theme),
              ),
              const SizedBox(height: 16),
              // Stats card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(L.t('average_grade'),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(avgGrade.toStringAsFixed(1),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    Column(
                      children: [
                        Text(L.t('total_late'),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(totalLate.toInt().toString(),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(
      List<Map<String, dynamic>> data, double maxValue, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartHeight = constraints.maxHeight - 30;
        return Column(
          children: [
            SizedBox(
              height: chartHeight,
              child: Stack(
                children: [
                  ...List.generate(5, (i) {
                    final y = chartHeight - (chartHeight / 4 * i);
                    return Positioned(
                      top: y,
                      left: 0,
                      right: 0,
                      child: Container(
                          height: 1, color: Colors.grey.withOpacity(0.2)),
                    );
                  }),
                  ...List.generate(5, (i) {
                    final y = chartHeight - (chartHeight / 4 * i) - 8;
                    final value = (maxValue / 4 * i).toInt();
                    return Positioned(
                      top: y,
                      left: 0,
                      child: Text('$value',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                    );
                  }),
                  Positioned(
                    left: 30,
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: CustomPaint(
                      painter: _LineChartPainter(
                          data: data,
                          maxValue: maxValue,
                          lineColor: const Color(0xFFFF9500)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: data
                    .map((d) => Text(d['month'],
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)))
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;
  final Color lineColor;

  _LineChartPainter(
      {required this.data, required this.maxValue, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y = size.height - (data[i]['value'] / maxValue * size.height);
      points.add(Offset(x, y));
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    for (final point in points) {
      canvas.drawCircle(point, 6, dotBorderPaint);
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _selectedDay = DateTime.now().weekday - 1;
  final PageController _pageController = PageController();

  final List<String> _dayKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday'
  ];

  final Map<String, List<Map<String, String>>> _schedule = {
    'monday': [
      {
        'time': '08:00 - 08:45',
        'subject': 'mathematics',
        'room': '301',
        'teacher': 'Васильева М.Г.',
        'type': 'lecture'
      },
      {
        'time': '08:55 - 09:40',
        'subject': 'mathematics',
        'room': '301',
        'teacher': 'Васильева М.Г.',
        'type': 'practice'
      },
      {
        'time': '10:00 - 10:45',
        'subject': 'english',
        'room': '205',
        'teacher': 'Смирнова Е.А.',
        'type': 'lecture'
      },
      {
        'time': '10:55 - 11:40',
        'subject': 'english',
        'room': '205',
        'teacher': 'Смирнова Е.А.',
        'type': 'practice'
      },
      {
        'time': '12:00 - 12:45',
        'subject': 'science',
        'room': '412',
        'teacher': 'Петров И.В.',
        'type': 'lab'
      },
      {
        'time': '12:55 - 13:40',
        'subject': 'science',
        'room': '412',
        'teacher': 'Петров И.В.',
        'type': 'lab'
      },
    ],
    'tuesday': [
      {
        'time': '08:00 - 08:45',
        'subject': 'history',
        'room': '118',
        'teacher': 'Козлов А.П.',
        'type': 'lecture'
      },
      {
        'time': '08:55 - 09:40',
        'subject': 'history',
        'room': '118',
        'teacher': 'Козлов А.П.',
        'type': 'lecture'
      },
      {
        'time': '10:00 - 10:45',
        'subject': 'spanish',
        'room': '207',
        'teacher': 'Родригес М.К.',
        'type': 'practice'
      },
      {
        'time': '10:55 - 11:40',
        'subject': 'spanish',
        'room': '207',
        'teacher': 'Родригес М.К.',
        'type': 'practice'
      },
      {
        'time': '12:00 - 12:45',
        'subject': 'pe',
        'room': 'Gym',
        'teacher': 'Иванов С.Д.',
        'type': 'practice'
      },
      {
        'time': '12:55 - 13:40',
        'subject': 'pe',
        'room': 'Gym',
        'teacher': 'Иванов С.Д.',
        'type': 'practice'
      },
    ],
    'wednesday': [
      {
        'time': '08:00 - 08:45',
        'subject': 'design',
        'room': '315',
        'teacher': 'Новикова О.Л.',
        'type': 'lecture'
      },
      {
        'time': '08:55 - 09:40',
        'subject': 'design',
        'room': '315',
        'teacher': 'Новикова О.Л.',
        'type': 'practice'
      },
      {
        'time': '10:00 - 10:45',
        'subject': 'mathematics',
        'room': '301',
        'teacher': 'Васильева М.Г.',
        'type': 'lecture'
      },
      {
        'time': '10:55 - 11:40',
        'subject': 'mathematics',
        'room': '301',
        'teacher': 'Васильева М.Г.',
        'type': 'practice'
      },
      {
        'time': '12:00 - 12:45',
        'subject': 'art',
        'room': '420',
        'teacher': 'Белова Н.С.',
        'type': 'practice'
      },
      {
        'time': '12:55 - 13:40',
        'subject': 'art',
        'room': '420',
        'teacher': 'Белова Н.С.',
        'type': 'practice'
      },
    ],
    'thursday': [
      {
        'time': '08:00 - 08:45',
        'subject': 'english',
        'room': '205',
        'teacher': 'Смирнова Е.А.',
        'type': 'lecture'
      },
      {
        'time': '08:55 - 09:40',
        'subject': 'english',
        'room': '205',
        'teacher': 'Смирнова Е.А.',
        'type': 'practice'
      },
      {
        'time': '10:00 - 10:45',
        'subject': 'science',
        'room': '412',
        'teacher': 'Петров И.В.',
        'type': 'lecture'
      },
      {
        'time': '10:55 - 11:40',
        'subject': 'science',
        'room': '412',
        'teacher': 'Петров И.В.',
        'type': 'lecture'
      },
      {
        'time': '12:00 - 12:45',
        'subject': 'history',
        'room': '118',
        'teacher': 'Козлов А.П.',
        'type': 'practice'
      },
      {
        'time': '12:55 - 13:40',
        'subject': 'history',
        'room': '118',
        'teacher': 'Козлов А.П.',
        'type': 'practice'
      },
    ],
    'friday': [
      {
        'time': '08:00 - 08:45',
        'subject': 'spanish',
        'room': '207',
        'teacher': 'Родригес М.К.',
        'type': 'lecture'
      },
      {
        'time': '08:55 - 09:40',
        'subject': 'spanish',
        'room': '207',
        'teacher': 'Родригес М.К.',
        'type': 'practice'
      },
      {
        'time': '10:00 - 10:45',
        'subject': 'design',
        'room': '315',
        'teacher': 'Новикова О.Л.',
        'type': 'practice'
      },
      {
        'time': '10:55 - 11:40',
        'subject': 'design',
        'room': '315',
        'teacher': 'Новикова О.Л.',
        'type': 'practice'
      },
      {
        'time': '12:00 - 12:45',
        'subject': 'mathematics',
        'room': '301',
        'teacher': 'Васильева М.Г.',
        'type': 'lecture'
      },
    ],
    'saturday': [
      {
        'time': '09:00 - 09:45',
        'subject': 'art',
        'room': '420',
        'teacher': 'Белова Н.С.',
        'type': 'practice'
      },
      {
        'time': '09:55 - 10:40',
        'subject': 'art',
        'room': '420',
        'teacher': 'Белова Н.С.',
        'type': 'practice'
      },
      {
        'time': '10:50 - 11:35',
        'subject': 'pe',
        'room': 'Gym',
        'teacher': 'Иванов С.Д.',
        'type': 'practice'
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    if (_selectedDay > 5) _selectedDay = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_selectedDay);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getTypeLabel(String type) {
    if (L.locale == 'ru') {
      switch (type) {
        case 'lecture':
          return 'Лекция';
        case 'practice':
          return 'Практика';
        case 'lab':
          return 'Лаб. работа';
        default:
          return type;
      }
    } else {
      switch (type) {
        case 'lecture':
          return 'Lecture';
        case 'practice':
          return 'Practice';
        case 'lab':
          return 'Lab';
        default:
          return type;
      }
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'lecture':
        return const Color(0xFF4CAF50);
      case 'practice':
        return const Color(0xFFFF9800);
      case 'lab':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(L.t('timetable')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Day selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                final isSelected = _selectedDay == index;
                final isToday = DateTime.now().weekday - 1 == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDay = index);
                    _pageController.animateToPage(index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  child: Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor
                          : (isToday
                              ? theme.primaryColor.withOpacity(0.1)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          L.t(_dayKeys[index]),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : theme.primaryColor,
                          ),
                        ),
                        if (isToday && !isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1),
          // Schedule content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _selectedDay = index),
              itemCount: 6,
              itemBuilder: (context, index) {
                final dayKey = _dayKeys[index];
                final lessons = _schedule[dayKey] ?? [];

                if (lessons.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.weekend, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(L.t('no_lessons'),
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lessons.length,
                  itemBuilder: (context, lessonIndex) {
                    final lesson = lessons[lessonIndex];
                    final typeColor = _getTypeColor(lesson['type']!);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color:
                                isDark ? Colors.grey[800]! : Colors.grey[200]!),
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            // Color indicator
                            Container(
                              width: 4,
                              decoration: BoxDecoration(
                                color: typeColor,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                            ),
                            // Content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          lesson['time']!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: typeColor.withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _getTypeLabel(lesson['type']!),
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: typeColor,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      localizedSubjectName(lesson['subject']!),
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.room_outlined,
                                            size: 16, color: Colors.grey[500]),
                                        const SizedBox(width: 4),
                                        Text(
                                          lesson['room']!,
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600]),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.person_outline,
                                            size: 16, color: Colors.grey[500]),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            lesson['teacher']!,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600]),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
