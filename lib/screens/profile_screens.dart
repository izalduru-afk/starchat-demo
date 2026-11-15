import 'package:flutter/material.dart';

import '../data.dart';
import '../widgets.dart';
import 'auth_screens.dart';
import 'chat_screens.dart';

class MyProfileTab extends StatelessWidget {
  const MyProfileTab({super.key});

  Future<void> _logOut(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Text('Profile',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: kText)),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => showSnack(context, 'Settings will be available in the full version'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Center(
                child: Avatar(
                  initials: initialsOf(app.myName),
                  bg: kPrimaryLight,
                  fg: const Color(0xFF5B21B6),
                  size: 104,
                ),
              ),
              const SizedBox(height: 14),
              Text(app.myName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(height: 4),
              Text('@${app.myUsername}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: kMuted)),
              const SizedBox(height: 20),
              StatBox(items: [
                ('${app.followingPeople.length}', 'Following'),
                ('${app.followerPeople.length}', 'Followers'),
                ('${app.joinedGroups.length}', 'Groups'),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CompleteProfileScreen(editMode: true)),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(height: 24),
              InfoSection(title: 'Bio', body: app.myBio.isEmpty ? '—' : app.myBio),
              InfoSection(
                title: 'Date of Birth',
                body: app.myDob == null ? '—' : fmtDate(app.myDob!),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kRed,
                    side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                  ),
                  onPressed: () => _logOut(context),
                  child: const Text('Log Out'),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'StarChat demo · data shown is sample data',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: kMuted),
              ),
            ],
          );
        },
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.personId});

  final String personId;

  Future<void> _confirmBlock(BuildContext context, Person p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Block ${p.name}?'),
        content: const Text(
            'They won’t be able to message you or see your profile. You can unblock them later from Contacts.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Block', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      app.block(p.id);
      showSnack(context, '${p.name} has been blocked');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final p = app.person(personId);
        final following = app.isFollowing(p.id);
        final blocked = app.isBlocked(p.id);

        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Center(child: Avatar.person(p, size: 104)),
              const SizedBox(height: 14),
              Text(p.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(height: 4),
              Text('@${p.username}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: kMuted)),
              const SizedBox(height: 20),
              StatBox(items: [
                (fmtCount(p.followingCount), 'Following'),
                (fmtCount(p.followers), 'Followers'),
              ]),
              const SizedBox(height: 16),
              if (!blocked)
                Row(
                  children: [
                    Expanded(
                      child: following
                          ? OutlinedButton.icon(
                              onPressed: () => app.toggleFollow(p.id),
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Following'),
                            )
                          : FilledButton.icon(
                              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                              onPressed: () => app.toggleFollow(p.id),
                              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                              label: const Text('Follow'),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: kSurface,
                          foregroundColor: kText,
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ChatScreen(personId: p.id)),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                        label: const Text('Message'),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'You blocked this user. They can’t message you or see your profile.',
                    style: TextStyle(color: kRed, height: 1.4),
                  ),
                ),
              const SizedBox(height: 24),
              if (p.bio.isNotEmpty) InfoSection(title: 'Bio', body: p.bio),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: blocked
                    ? OutlinedButton(
                        onPressed: () {
                          app.unblock(p.id);
                          showSnack(context, '${p.name} has been unblocked');
                        },
                        child: const Text('Unblock User'),
                      )
                    : FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFEF2F2),
                          foregroundColor: kRed,
                          minimumSize: const Size(0, 48),
                        ),
                        onPressed: () => _confirmBlock(context, p),
                        icon: const Icon(Icons.block_rounded, size: 18),
                        label: const Text('Block User'),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
