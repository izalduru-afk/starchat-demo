import 'package:flutter/material.dart';

import '../data.dart';
import '../widgets.dart';
import 'chat_screens.dart';
import 'contacts_screens.dart';
import 'group_screens.dart';
import 'profile_screens.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomeTab(), ContactsTab(), MyProfileTab()],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: app,
        builder: (context, _) => _FloatingNav(
          index: _index,
          homeBadge: app.totalUnread,
          onSelect: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

/// Rounded, floating bottom navigation bar.
class _FloatingNav extends StatelessWidget {
  const _FloatingNav({required this.index, required this.homeBadge, required this.onSelect});

  final int index;
  final int homeBadge;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.people_outline_rounded, Icons.people_rounded, 'Contacts'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: kBorder),
              boxShadow: const [
                BoxShadow(color: Color(0x1F1F1A2E), blurRadius: 24, offset: Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: index == i ? items[i].$2 : items[i].$1,
                      label: items[i].$3,
                      selected: index == i,
                      badge: i == 0 ? homeBadge : 0,
                      onTap: () => onSelect(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? kPrimary : kMuted;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? kPrimaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (badge > 0)
                Positioned(
                  top: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.translate(
                      offset: const Offset(16, 0),
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        height: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          badge > 99 ? '99+' : '$badge',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
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

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        Widget option(IconData icon, String title, String subtitle, VoidCallback onTap) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: kPrimary),
            ),
            title: Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText)),
            subtitle: Text(subtitle, style: const TextStyle(color: kMuted)),
            onTap: () {
              Navigator.of(sheetContext).pop();
              onTap();
            },
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                option(
                  Icons.chat_bubble_outline_rounded,
                  'New Chat',
                  'Message someone you follow',
                  () => _newChat(context),
                ),
                option(
                  Icons.group_add_rounded,
                  'New Group',
                  'Create a group with its own link',
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _newChat(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        final people = app.followingPeople;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text('New Chat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kText)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final p in people)
                      PersonTile(
                        person: p,
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ChatScreen(personId: p.id)),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          titleSpacing: 20,
          title: const Text('StarChat',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: kText)),
          actions: [
            IconButton(
              tooltip: 'Find users',
              style: IconButton.styleFrom(
                backgroundColor: kSurface,
                foregroundColor: kText,
                fixedSize: const Size(44, 44),
              ),
              icon: const Icon(Icons.search_rounded, size: 22),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FindUsersScreen()),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'New chat or group',
              style: IconButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                fixedSize: const Size(44, 44),
              ),
              icon: const Icon(Icons.edit_outlined, size: 21),
              onPressed: () => _showCreateMenu(context),
            ),
            const SizedBox(width: 16),
          ],
          bottom: const TabBar(
            labelColor: kPrimary,
            unselectedLabelColor: kMuted,
            indicatorColor: kPrimary,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: kBorder,
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            tabs: [Tab(text: 'Chats'), Tab(text: 'Groups')],
          ),
        ),
        body: ListenableBuilder(
          listenable: app,
          // Not const on purpose, so the lists rebuild when the data changes.
          // ignore: prefer_const_constructors
          builder: (context, _) => TabBarView(
            // ignore: prefer_const_literals_to_create_immutables, prefer_const_constructors
            children: [_ChatList(), _GroupList()],
          ),
        ),
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  const _ChatList();

  @override
  Widget build(BuildContext context) {
    final ids = app.chatIds;
    if (ids.isEmpty) {
      return const Center(child: Text('No chats yet', style: TextStyle(color: kMuted)));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      itemCount: ids.length,
      itemBuilder: (context, i) {
        final p = app.person(ids[i]);
        final last = app.messagesWith(p.id).last;
        return ConversationTile(
          leading: Avatar.person(p, size: 52),
          title: p.name,
          preview: last.mine ? 'You: ${last.text}' : last.text,
          time: fmtTime(last.time),
          unread: app.unread[p.id] ?? 0,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ChatScreen(personId: p.id)),
          ),
        );
      },
    );
  }
}

class _GroupList extends StatelessWidget {
  const _GroupList();

  @override
  Widget build(BuildContext context) {
    final groups = app.joinedGroups;
    if (groups.isEmpty) {
      return const Center(child: Text('No groups yet', style: TextStyle(color: kMuted)));
    }
    return ListView(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      children: [
        for (final g in groups)
          ConversationTile(
            leading: GroupAvatar(group: g),
            title: g.name,
            preview: _groupPreview(g),
            time: g.messages.isEmpty ? '' : fmtTime(g.messages.last.time),
            unread: g.unread,
            subtitle: '${fmtCount(g.members)} members',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => GroupChatScreen(groupId: g.id)),
            ),
          ),
      ],
    );
  }

  String _groupPreview(Group g) {
    if (g.messages.isEmpty) return 'No messages yet';
    final m = g.messages.last;
    if (m.mine) return 'You: ${m.text}';
    final sender = app.maybePerson(m.senderId);
    if (sender == null) return m.text;
    return '${sender.name.split(' ').first}: ${m.text}';
  }
}
