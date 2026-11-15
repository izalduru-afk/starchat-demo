import 'package:flutter/material.dart';

import '../data.dart';
import '../widgets.dart';
import 'chat_screens.dart';
import 'profile_screens.dart';

enum _ContactFilter { following, followers, blocked }

class ContactsTab extends StatefulWidget {
  const ContactsTab({super.key});

  @override
  State<ContactsTab> createState() => _ContactsTabState();
}

class _ContactsTabState extends State<ContactsTab> {
  _ContactFilter _filter = _ContactFilter.following;
  String _query = '';

  List<Person> _filtered(List<Person> list) {
    final q = _query.trim().toLowerCase().replaceFirst('@', '');
    if (q.isEmpty) return list;
    return list
        .where((p) => p.name.toLowerCase().contains(q) || p.username.contains(q))
        .toList();
  }

  void _openProfile(Person p) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserProfileScreen(personId: p.id)),
    );
  }

  void _openChat(Person p) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatScreen(personId: p.id)),
    );
  }

  Widget _chip(_ContactFilter f, String label) {
    final selected = _filter == f;
    return Expanded(
      child: Material(
        color: selected ? kPrimary : kSurface,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => setState(() => _filter = f),
          child: SizedBox(
            height: 40,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: selected ? Colors.white : kText,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 2),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: kMuted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final followingList = app.followingPeople;
          final followerList = app.followerPeople;
          final blockedList = app.blockedPeople;

          final List<Person> source = switch (_filter) {
            _ContactFilter.following => followingList,
            _ContactFilter.followers => followerList,
            _ContactFilter.blocked => blockedList,
          };
          final people = _filtered(source);
          final searching = _query.trim().isNotEmpty;

          // While searching, look through all three lists (each person shown once).
          final seen = <String>{};
          List<Person> unique(List<Person> list) =>
              _filtered(list).where((p) => seen.add(p.id)).toList();
          final foundFollowing = searching ? unique(followingList) : <Person>[];
          final foundFollowers = searching ? unique(followerList) : <Person>[];
          final foundBlocked = searching ? unique(blockedList) : <Person>[];
          final foundAny =
              foundFollowing.isNotEmpty || foundFollowers.isNotEmpty || foundBlocked.isNotEmpty;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: SearchBox(
                  hint: 'Search contacts...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              if (!searching) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _chip(_ContactFilter.following, 'Following'),
                      const SizedBox(width: 8),
                      _chip(_ContactFilter.followers, 'Followers'),
                      const SizedBox(width: 8),
                      _chip(_ContactFilter.blocked, 'Blocked'),
                    ],
                  ),
                ),
                if (_filter == _ContactFilter.blocked)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Text(
                      'Blocked users can\u2019t message you or see your profile.',
                      style: TextStyle(fontSize: 13, color: kMuted, height: 1.5),
                    ),
                  ),
                const SizedBox(height: 6),
              ],
              Expanded(
                child: searching
                    ? (!foundAny
                        ? const Center(
                            child: Text('No contacts found', style: TextStyle(color: kMuted)))
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 12),
                            children: [
                              if (foundFollowing.isNotEmpty) ...[
                                _sectionHeader('Following'),
                                for (final p in foundFollowing)
                                  _row(p, _ContactFilter.following),
                              ],
                              if (foundFollowers.isNotEmpty) ...[
                                _sectionHeader('Followers'),
                                for (final p in foundFollowers)
                                  _row(p, _ContactFilter.followers),
                              ],
                              if (foundBlocked.isNotEmpty) ...[
                                _sectionHeader('Blocked'),
                                for (final p in foundBlocked) _row(p, _ContactFilter.blocked),
                              ],
                            ],
                          ))
                    : people.isEmpty
                        ? const Center(
                            child: Text('No one here yet', style: TextStyle(color: kMuted)))
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 12),
                            itemCount: people.length,
                            itemBuilder: (context, i) => _row(people[i], _filter),
                          ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget _row(Person p, _ContactFilter f) {
                          switch (f) {
                            case _ContactFilter.following:
                              return PersonTile(
                                person: p,
                                onTap: () => _openProfile(p),
                                trailing: IconButton.filledTonal(
                                  tooltip: 'Send message',
                                  style: IconButton.styleFrom(
                                      backgroundColor: kSurface, foregroundColor: kPrimary),
                                  onPressed: () => _openChat(p),
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                                ),
                              );
                            case _ContactFilter.followers:
                              final follows = app.isFollowing(p.id);
                              return PersonTile(
                                person: p,
                                onTap: () => _openProfile(p),
                                trailing: follows
                                    ? IconButton.filledTonal(
                                        tooltip: 'Send message',
                                        style: IconButton.styleFrom(
                                            backgroundColor: kSurface, foregroundColor: kPrimary),
                                        onPressed: () => _openChat(p),
                                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                                            size: 20),
                                      )
                                    : TextButton(
                                        onPressed: () => app.toggleFollow(p.id),
                                        child: const Text('Follow back'),
                                      ),
                              );
                            default:
                              return PersonTile(
                                person: p,
                                trailing: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 40),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  onPressed: () {
                                    app.unblock(p.id);
                                    showSnack(context, '${p.name} has been unblocked');
                                  },
                                  child: const Text('Unblock'),
                                ),
                              );
                          }
  }
}

class FindUsersScreen extends StatefulWidget {
  const FindUsersScreen({super.key});

  @override
  State<FindUsersScreen> createState() => _FindUsersScreenState();
}

class _FindUsersScreenState extends State<FindUsersScreen> {
  String _query = '';

  String get _q => _query.trim().toLowerCase().replaceFirst('@', '');

  bool _matchPerson(Person p) =>
      _q.isEmpty || p.name.toLowerCase().contains(_q) || p.username.contains(_q);

  bool _matchGroup(Group g) =>
      _q.isEmpty || g.name.toLowerCase().contains(_q);

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: kMuted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final chatPeople =
            app.chatIds.map(app.person).where(_matchPerson).toList();
        final groups = app.joinedGroups.where(_matchGroup).toList();
        final chatIdSet = app.chatIds.toSet();
        final users = _q.isEmpty
            ? <Person>[]
            : app.searchUsers(_query).where((p) => !chatIdSet.contains(p.id)).toList();
        final nothing = chatPeople.isEmpty && groups.isEmpty && users.isEmpty;

        return Scaffold(
          appBar: AppBar(title: const Text('Search')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: SearchBox(
                  hint: 'Search chats, groups, or @username',
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: nothing
                    ? Center(
                        child: Text(
                          _q.isEmpty ? 'No chats or groups yet' : 'No results for "${_query.trim()}"',
                          style: const TextStyle(color: kMuted),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          if (chatPeople.isNotEmpty) ...[
                            _section('Chats'),
                            for (final p in chatPeople)
                              ConversationTile(
                                leading: Avatar.person(p, size: 48),
                                title: p.name,
                                preview: _preview(app.messagesWith(p.id).last),
                                time: fmtTime(app.messagesWith(p.id).last.time),
                                unread: app.unread[p.id] ?? 0,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => ChatScreen(personId: p.id)),
                                ),
                              ),
                          ],
                          if (groups.isNotEmpty) ...[
                            _section('Groups'),
                            for (final g in groups)
                              ConversationTile(
                                leading: GroupAvatar(group: g, size: 48),
                                title: g.name,
                                preview: g.link,
                                time: '',
                                unread: g.unread,
                                subtitle: '${fmtCount(g.members)} members',
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => GroupChatScreen(groupId: g.id)),
                                ),
                              ),
                          ],
                          if (users.isNotEmpty) ...[
                            _section('Users'),
                            for (final p in users)
                              PersonTile(
                                person: p,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => UserProfileScreen(personId: p.id)),
                                ),
                                trailing: app.isFollowing(p.id)
                                    ? OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 36),
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                        ),
                                        onPressed: () => app.toggleFollow(p.id),
                                        child: const Text('Following'),
                                      )
                                    : FilledButton(
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size(0, 36),
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          textStyle: const TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.w600),
                                        ),
                                        onPressed: () => app.toggleFollow(p.id),
                                        child: const Text('Follow'),
                                      ),
                              ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _preview(Message m) => m.mine ? 'You: ${m.text}' : m.text;
}
