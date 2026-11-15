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
    return ChoiceChip(
      label: Text('$label $count'),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => setState(() => _filter = f),
      selectedColor: kPrimary,
      backgroundColor: kSurface,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        color: selected ? Colors.white : kText,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Text('Contacts',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kText)),
      ),
      body: ListenableBuilder(
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
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: SearchBox(
                  hint: 'Search users...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
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
