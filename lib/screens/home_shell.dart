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
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: kBorder))),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Contacts',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

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
          title: const Text('Home',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kText)),
          actions: [
            IconButton(
              tooltip: 'Find groups',
              icon: const Icon(Icons.search_rounded),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchGroupsScreen()),
              ),
            ),
            IconButton(
              tooltip: 'New chat',
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: () => _newChat(context),
            ),
            const SizedBox(width: 8),
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
    return ListView(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      children: [
        _ActionRow(
          icon: Icons.group_add_rounded,
          label: 'Create New Group',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          ),
        ),
        _ActionRow(
          icon: Icons.travel_explore_rounded,
          label: 'Find Groups',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchGroupsScreen()),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 2),
          child: Divider(),
        ),
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: kPrimaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: kPrimary),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kPrimary)),
          ],
        ),
      ),
    );
  }
}
