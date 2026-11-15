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

  Widget _chip(_ContactFilter f, String label, int count) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected ? Colors.white : kText,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? const Color(0x40FFFFFF) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : kText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: SearchBox(
                  hint: 'Search users...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _chip(_ContactFilter.following, 'Following', followingList.length),
                    const SizedBox(width: 8),
                    _chip(_ContactFilter.followers, 'Followers', followerList.length),
                    const SizedBox(width: 8),
                    _chip(_ContactFilter.blocked, 'Blocked', blockedList.length),
                  ],
                ),
              ),
              if (_filter == _ContactFilter.blocked)
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Text(
                    'Blocked users can’t message you or see your profile.',
                    style: TextStyle(fontSize: 13, color: kMuted, height: 1.5),
                  ),
                ),
              const SizedBox(height: 6),
              Expanded(
                child: people.isEmpty
                    ? Center(
                        child: Text(
                          _query.isNotEmpty ? 'No users found' : 'No one here yet',
                          style: const TextStyle(color: kMuted),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: people.length,
                        itemBuilder: (context, i) => _row(people[i]),
                      ),
              ),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget _row(Person p) {
                          switch (_filter) {
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final results = app.searchUsers(_query);
        return Scaffold(
          appBar: AppBar(title: const Text('Find Users')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: SearchBox(
                  hint: 'Search by name or @username',
                  autofocus: true,
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: _query.trim().isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Type a name or @username to find someone.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: kMuted, height: 1.5),
                          ),
                        ),
                      )
                    : results.isEmpty
                    ? const Center(
                        child: Text('No users found', style: TextStyle(color: kMuted)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final p = results[i];
                          final follows = app.isFollowing(p.id);
                          return PersonTile(
                            person: p,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => UserProfileScreen(personId: p.id)),
                            ),
                            trailing: follows
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
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
