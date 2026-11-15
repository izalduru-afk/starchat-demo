import 'dart:async';

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Colors
// ---------------------------------------------------------------------------
const kPrimary = Color(0xFF6D28D9);
const kPrimaryDark = Color(0xFF3B0F7A);
const kPrimaryLight = Color(0xFFEDE9FE);
const kText = Color(0xFF1F1A2E);
const kMuted = Color(0xFF6B6880);
const kBorder = Color(0xFFECEAF2);
const kSurface = Color(0xFFF4F2F8);
const kChatBg = Color(0xFFF7F6FB);
const kGreen = Color(0xFF15803D);
const kRed = Color(0xFFB91C1C);

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------
class Person {
  Person({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.bg,
    required this.fg,
    required this.followers,
    required this.followingCount,
  });

  final String id;
  final String name;
  final String username;
  final String bio;
  final Color bg;
  final Color fg;
  int followers;
  final int followingCount;

  String get initials => initialsOf(name);
}

class Message {
  Message(this.text, this.senderId, this.time);

  final String text;

  /// null means the message was sent by the current user.
  final String? senderId;
  final DateTime time;

  bool get mine => senderId == null;
}

class Group {
  Group({
    required this.id,
    required this.name,
    required this.username,
    required this.description,
    required this.members,
    required this.joined,
    required this.bg,
    required this.fg,
    required this.announcement,
    required this.messages,
    this.unread = 0,
  });

  final String id;
  String name;
  String username;
  String description;
  int members;
  bool joined;
  final Color bg;
  final Color fg;
  String announcement;
  final List<Message> messages;
  int unread;

  String get link => 'starchat.app/$username';
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

String two(int n) => n.toString().padLeft(2, '0');

String fmtClock(DateTime t) => '${two(t.hour)}:${two(t.minute)}';

String fmtTime(DateTime t) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;
  if (diff <= 0) return fmtClock(t);
  if (diff == 1) return 'Yesterday';
  if (diff < 7) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[t.weekday - 1];
  }
  return '${t.day}/${t.month}';
}

String fmtDate(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

String fmtCount(int n) {
  return n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}

final RegExp kUsernamePattern = RegExp(r'^[a-z0-9_]{3,30}$');

String slugify(String s) {
  return s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

// ---------------------------------------------------------------------------
// App state (demo data, kept in memory only)
// ---------------------------------------------------------------------------
class AppState extends ChangeNotifier {
  AppState() {
    _seed();
  }

  // Current user
  String myName = 'Alex Carter';
  String myUsername = 'alexcarter';
  String myBio = 'Passionate about technology and building communities.';
  DateTime? myDob = DateTime(1990, 5, 15);

  final List<Person> people = [
    Person(id: 'emma', name: 'Emma Wilson', username: 'emmawilson', bio: 'Sharing about design, productivity, and creative communities. Join us: starchat.app/designcommunity', bg: const Color(0xFFFCE7F3), fg: const Color(0xFF9D174D), followers: 3800, followingCount: 342),
    Person(id: 'daniel', name: 'Daniel Martin', username: 'danielmartin', bio: 'Product designer. Coffee first, then pixels.', bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1E40AF), followers: 1240, followingCount: 410),
    Person(id: 'sophia', name: 'Sophia Reynolds', username: 'sophiareynolds', bio: 'Community organizer and weekend photographer. Book club: starchat.app/readingcorner', bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E), followers: 980, followingCount: 255),
    Person(id: 'james', name: 'James Turner', username: 'jamesturner', bio: 'Developer who loves open source.', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534), followers: 2100, followingCount: 190),
    Person(id: 'nadia', name: 'Nadia Anggraini', username: 'nadiaang', bio: 'Volunteer, reader, and tea enthusiast. Volunteer with us: starchat.app/volunteernetwork', bg: const Color(0xFFEDE9FE), fg: const Color(0xFF5B21B6), followers: 640, followingCount: 300),
    Person(id: 'rina', name: 'Rina Lestari', username: 'rinalestari', bio: 'English teacher. Let’s practice together! starchat.app/englishlearners', bg: const Color(0xFFFFE4E6), fg: const Color(0xFF9F1239), followers: 1520, followingCount: 220),
    Person(id: 'budi', name: 'Budi Santoso', username: 'budisan', bio: 'Tech community volunteer.', bg: const Color(0xFFE0F2FE), fg: const Color(0xFF075985), followers: 870, followingCount: 400),
    Person(id: 'sari', name: 'Sari Wulandari', username: 'sariwulan', bio: 'Landscape and street photography.', bg: const Color(0xFFFEF9C3), fg: const Color(0xFF854D0E), followers: 560, followingCount: 150),
    Person(id: 'rudi', name: 'Rudi Pratama', username: 'rudipratama', bio: '', bg: const Color(0xFFECEAF2), fg: kMuted, followers: 120, followingCount: 80),
    Person(id: 'kevin', name: 'Kevin Saputra', username: 'kevinsap', bio: '', bg: const Color(0xFFECEAF2), fg: kMuted, followers: 95, followingCount: 60),
    Person(id: 'admin', name: 'Admin', username: 'starchatadmin', bio: 'Group administrator.', bg: kPrimaryLight, fg: const Color(0xFF5B21B6), followers: 0, followingCount: 0),
  ];

  final Set<String> following = {'emma', 'daniel', 'sophia', 'james', 'nadia'};
  final Set<String> followerIds = {'emma', 'daniel', 'nadia', 'rina', 'budi', 'sari'};
  final Set<String> blocked = {'rudi', 'kevin'};
  final Set<String> muted = {};

  bool isMuted(String id) => muted.contains(id);

  void toggleMute(String id) {
    if (!muted.remove(id)) muted.add(id);
    notifyListeners();
  }

  final Map<String, List<Message>> chats = {};
  final Map<String, int> unread = {};
  final List<Group> groups = [];

  int _groupSeq = 0;
  int _replySeq = 0;

  static const _replies = [
    'Got it!',
    'Sounds good to me.',
    'Haha, nice one.',
    'Okay, I’ll check it later.',
    'Thanks for letting me know!',
    'Sure, see you there.',
  ];

  void _seed() {
    final now = DateTime.now();
    DateTime ago({int days = 0, int minutes = 0}) =>
        now.subtract(Duration(days: days, minutes: minutes));

    chats['emma'] = [
      Message('Hi Alex!', 'emma', ago(minutes: 40)),
      Message('Have you joined the Design Community group?', 'emma', ago(minutes: 38)),
      Message('Yes, I just joined. It looks great!', null, ago(minutes: 30)),
      Message('Awesome! Let’s discuss the event there later.', 'emma', ago(minutes: 12)),
      Message('Sure, I’ll join later', 'emma', ago(minutes: 10)),
    ];
    chats['daniel'] = [
      Message('Are we still meeting tomorrow?', null, ago(minutes: 70)),
      Message('Okay, see you then!', 'daniel', ago(minutes: 55)),
    ];
    chats['sophia'] = [
      Message('I sent you the photos from the event.', null, ago(days: 1, minutes: 20)),
      Message('Great, thank you!', 'sophia', ago(days: 1, minutes: 10)),
    ];
    chats['james'] = [
      Message('Can you share the project file?', 'james', ago(days: 1, minutes: 200)),
      Message('I’ve sent the file', null, ago(days: 1, minutes: 180)),
    ];
    chats['nadia'] = [
      Message('What time is the meeting tomorrow?', 'nadia', ago(days: 3)),
    ];
    unread['emma'] = 2;
    unread['daniel'] = 1;

    groups.addAll([
      Group(
        id: 'g_design', name: 'Design Community', username: 'designcommunity',
        description: 'A friendly place to share design work, feedback, and events.',
        members: 1248, joined: true, bg: kPrimaryLight, fg: const Color(0xFF5B21B6),
        announcement: 'Welcome! Please read the group rules before posting.', unread: 5,
        messages: [
          Message('Hello everyone! Glad to have you here.', 'admin', ago(minutes: 90)),
          Message('Thanks, Admin!', 'daniel', ago(minutes: 80)),
          Message('Is there a meetup this month?', 'sophia', ago(minutes: 70)),
          Message('I’d love to join if there is one.', null, ago(minutes: 60)),
          Message('Welcome to our new members!', 'admin', ago(minutes: 15)),
        ],
      ),
      Group(
        id: 'g_english', name: 'English Learners', username: 'englishlearners',
        description: 'Practice English together every week.',
        members: 843, joined: true, bg: const Color(0xFFFCE7F3), fg: const Color(0xFF9D174D),
        announcement: 'Speaking class every Tuesday at 7 PM.',
        messages: [
          Message('Today’s topic: travel stories.', 'rina', ago(minutes: 150)),
          Message('Anyone joining tonight’s class?', 'rina', ago(minutes: 100)),
        ],
      ),
      Group(
        id: 'g_tech', name: 'Tech Community', username: 'techcommunity',
        description: 'News, tutorials, and meetups for tech enthusiasts.',
        members: 2510, joined: true, bg: const Color(0xFFDBEAFE), fg: const Color(0xFF1E40AF),
        announcement: '', unread: 12,
        messages: [
          Message('Thanks for coming to the workshop!', 'budi', ago(days: 1, minutes: 30)),
          Message('The slides are now shared', 'budi', ago(days: 1, minutes: 20)),
        ],
      ),
      Group(
        id: 'g_photo', name: 'Photography Club', username: 'photographyclub',
        description: 'Photo walks and weekly photo challenges.',
        members: 631, joined: true, bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E),
        announcement: '',
        messages: [
          Message('Photo walk this Sunday?', 'sari', ago(days: 2)),
        ],
      ),
      Group(
        id: 'g_reading', name: 'Reading Corner', username: 'readingcorner',
        description: 'One book a month, discussed together.',
        members: 412, joined: false, bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534),
        announcement: 'This month’s book will be announced on Friday.',
        messages: [
          Message('Welcome to Reading Corner!', 'admin', ago(days: 4)),
          Message('Can’t wait for the next book.', 'nadia', ago(days: 3)),
        ],
      ),
      Group(
        id: 'g_volunteer', name: 'Volunteer Network', username: 'volunteernetwork',
        description: 'Find and share volunteering opportunities near you.',
        members: 1980, joined: false, bg: const Color(0xFFE0F2FE), fg: const Color(0xFF075985),
        announcement: 'New volunteer opportunities are posted every Monday.',
        messages: [
          Message('We need 10 volunteers for Saturday’s event.', 'admin', ago(days: 1)),
        ],
      ),
      Group(
        id: 'g_food', name: 'Local Food Lovers', username: 'foodlovers',
        description: 'Recommendations for the best local food spots.',
        members: 356, joined: false, bg: const Color(0xFFFFE4E6), fg: const Color(0xFF9F1239),
        announcement: '',
        messages: [
          Message('Any good noodle place around here?', 'sophia', ago(days: 2)),
        ],
      ),
    ]);
  }

  // ---- People ---------------------------------------------------------------
  Person person(String id) => people.firstWhere((p) => p.id == id);

  Person? maybePerson(String? id) {
    if (id == null) return null;
    for (final p in people) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Person> get followingPeople =>
      people.where((p) => following.contains(p.id) && !blocked.contains(p.id)).toList();

  List<Person> get followerPeople =>
      people.where((p) => followerIds.contains(p.id) && !blocked.contains(p.id)).toList();

  List<Person> get blockedPeople => people.where((p) => blocked.contains(p.id)).toList();

  /// All users that can be found by search (excludes the admin account and blocked users).
  List<Person> searchUsers(String query) {
    final q = query.trim().toLowerCase().replaceFirst('@', '');
    return people.where((p) {
      if (p.id == 'admin' || blocked.contains(p.id)) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) || p.username.contains(q);
    }).toList();
  }

  bool isFollowing(String id) => following.contains(id);
  bool isBlocked(String id) => blocked.contains(id);

  void toggleFollow(String id) {
    final p = person(id);
    if (following.contains(id)) {
      following.remove(id);
      p.followers -= 1;
    } else {
      following.add(id);
      p.followers += 1;
    }
    notifyListeners();
  }

  void block(String id) {
    blocked.add(id);
    if (following.remove(id)) person(id).followers -= 1;
    notifyListeners();
  }

  void unblock(String id) {
    blocked.remove(id);
    notifyListeners();
  }

  bool isUserUsernameTaken(String u) =>
      people.any((p) => p.username == u) && u != myUsername;

  void updateProfile({
    required String name,
    required String username,
    required String bio,
    required DateTime? dob,
  }) {
    myName = name;
    myUsername = username;
    myBio = bio;
    myDob = dob;
    notifyListeners();
  }

  // ---- Private chats -----------------------------------------------------------
  List<String> get chatIds {
    final ids = chats.keys.where((id) => !blocked.contains(id) && chats[id]!.isNotEmpty).toList();
    ids.sort((a, b) => chats[b]!.last.time.compareTo(chats[a]!.last.time));
    return ids;
  }

  List<Message> messagesWith(String id) => chats.putIfAbsent(id, () => []);

  /// Unread messages across private chats and joined groups (for the Home badge).
  int get totalUnread {
    var n = 0;
    for (final id in chatIds) {
      n += unread[id] ?? 0;
    }
    for (final g in groups) {
      if (g.joined) n += g.unread;
    }
    return n;
  }

  void markRead(String id) {
    if ((unread[id] ?? 0) > 0) {
      unread[id] = 0;
      notifyListeners();
    }
  }

  void sendToPerson(String id, String text) {
    messagesWith(id).add(Message(text, null, DateTime.now()));
    notifyListeners();
    // Simulated reply so the demo feels alive. Nothing leaves the phone.
    Timer(const Duration(milliseconds: 1600), () {
      if (blocked.contains(id)) return;
      final reply = _replies[_replySeq % _replies.length];
      _replySeq++;
      messagesWith(id).add(Message(reply, id, DateTime.now()));
      notifyListeners();
    });
  }

  // ---- Groups -----------------------------------------------------------------------
  Group group(String id) => groups.firstWhere((g) => g.id == id);

  Group? groupByUsername(String username) {
    final u = username.toLowerCase();
    for (final g in groups) {
      if (g.username == u) return g;
    }
    return null;
  }

  List<Group> get joinedGroups {
    final list = groups.where((g) => g.joined).toList();
    list.sort((a, b) {
      final ta = a.messages.isEmpty ? DateTime(2000) : a.messages.last.time;
      final tb = b.messages.isEmpty ? DateTime(2000) : b.messages.last.time;
      return tb.compareTo(ta);
    });
    return list;
  }

  List<Group> searchGroups(String query) {
    var q = query.trim().toLowerCase();
    q = q.replaceFirst(RegExp(r'^(https?://)?(www\.)?starchat\.app/'), '');
    q = q.replaceFirst('@', '');
    if (q.isEmpty) return List.of(groups);
    return groups
        .where((g) => g.name.toLowerCase().contains(q) || g.username.contains(q))
        .toList();
  }

  bool isGroupUsernameTaken(String u) => groups.any((g) => g.username == u);

  String createGroup({
    required String name,
    required String username,
    required String description,
    required Set<String> memberIds,
  }) {
    _groupSeq++;
    final id = 'g_new_$_groupSeq';
    final now = DateTime.now();
    groups.add(Group(
      id: id,
      name: name,
      username: username,
      description: description,
      members: memberIds.length + 1,
      joined: true,
      bg: kPrimaryLight,
      fg: const Color(0xFF5B21B6),
      announcement: '',
      messages: [
        Message('You created this group. Share starchat.app/$username to invite others.', 'system', now),
      ],
    ));
    notifyListeners();
    return id;
  }

  void joinGroup(String id) {
    final g = group(id);
    if (!g.joined) {
      g.joined = true;
      g.members += 1;
      g.messages.add(Message('You joined the group.', 'system', DateTime.now()));
      notifyListeners();
    }
  }

  void leaveGroup(String id) {
    final g = group(id);
    if (g.joined) {
      g.joined = false;
      g.members -= 1;
      notifyListeners();
    }
  }

  void markGroupRead(String id) {
    final g = group(id);
    if (g.unread > 0) {
      g.unread = 0;
      notifyListeners();
    }
  }

  void sendToGroup(String id, String text) {
    group(id).messages.add(Message(text, null, DateTime.now()));
    notifyListeners();
  }
}

final app = AppState();
