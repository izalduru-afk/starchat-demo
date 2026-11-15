import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../widgets.dart';
import 'auth_screens.dart';
import 'chat_screens.dart';
import 'group_screens.dart';

// ---------------------------------------------------------------------------
// Shared pieces for menu-style lists
// ---------------------------------------------------------------------------
class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(const Divider(height: 1, indent: 62));
      items.add(children[i]);
    }
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(children: items),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.soon = false,
    this.danger = false,
    this.trailingText,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool soon;
  final bool danger;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? kRed : kText;
    final iconBg = danger ? const Color(0xFFFEF2F2) : kPrimaryLight;
    final iconFg = danger ? kRed : kPrimary;

    Widget? trailing;
    if (soon) {
      trailing = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(8)),
        child: const Text('Soon',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kMuted)),
      );
    } else if (trailingText != null) {
      trailing = Text(trailingText!, style: const TextStyle(fontSize: 14, color: kMuted));
    } else if (!danger) {
      trailing = const Icon(Icons.chevron_right_rounded, color: Color(0xFFA19DB3));
    }

    return Opacity(
      opacity: soon ? 0.6 : 1,
      child: InkWell(
        onTap: soon ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 19, color: iconFg),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: fg)),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// My profile (settings-style menu)
// ---------------------------------------------------------------------------
class MyProfileTab extends StatelessWidget {
  const MyProfileTab({super.key});

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action, style: const TextStyle(color: kRed)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  void _toSignIn(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  Future<void> _logOut(BuildContext context) async {
    final ok = await _confirm(context,
        title: 'Log out?', message: 'You can sign back in at any time.', action: 'Log Out');
    if (ok && context.mounted) _toSignIn(context);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final ok = await _confirm(
      context,
      title: 'Delete account?',
      message:
          'This will permanently delete your profile, chats, and groups. This cannot be undone.\n\n'
          '(Demo: nothing is actually deleted.)',
      action: 'Delete',
    );
    if (ok && context.mounted) _toSignIn(context);
  }

  void _soon(BuildContext context, String feature) {
    showSnack(context, '$feature will be available in the full version');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: app,
          builder: (context, _) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                Center(
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: Stack(
                      children: [
                        Avatar(
                          initials: initialsOf(app.myName),
                          bg: kPrimaryLight,
                          fg: const Color(0xFF5B21B6),
                          size: 96,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: kPrimary,
                            shape: const CircleBorder(
                                side: BorderSide(color: Colors.white, width: 3)),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _soon(context, 'Photo upload'),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.photo_camera_outlined,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(app.myName,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
                const SizedBox(height: 2),
                Text('@${app.myUsername}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: kMuted)),
                const SizedBox(height: 22),
                _MenuGroup(children: [
                  _MenuItem(
                    icon: Icons.edit_outlined,
                    label: 'Edit Profile',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const CompleteProfileScreen(editMode: true)),
                    ),
                  ),
                  _MenuItem(
                    icon: Icons.star_outline_rounded,
                    label: 'Stars',
                    trailingText: '${fmtCount(app.stars)} ⭐',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StarsScreen()),
                    ),
                  ),
                  const _MenuItem(
                      icon: Icons.account_balance_wallet_outlined, label: 'Wallet', soon: true),
                ]),
                const SizedBox(height: 14),
                _MenuGroup(children: [
                  _MenuItem(
                    icon: Icons.lock_outline_rounded,
                    label: 'Privacy & Security',
                    onTap: () => _soon(context, 'Privacy & Security'),
                  ),
                  _MenuItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifications',
                    onTap: () => _soon(context, 'Notification settings'),
                  ),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help',
                    onTap: () => _soon(context, 'Help'),
                  ),
                ]),
                const SizedBox(height: 14),
                _MenuGroup(children: [
                  _MenuItem(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete Account',
                    danger: true,
                    onTap: () => _deleteAccount(context),
                  ),
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Log Out',
                    danger: true,
                    onTap: () => _logOut(context),
                  ),
                ]),
                const SizedBox(height: 18),
                const Text(
                  'StarChat demo · data shown is sample data',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: kMuted),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Another user's profile
// ---------------------------------------------------------------------------
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final p = app.person(personId);
          final following = app.isFollowing(p.id);
          final blocked = app.isBlocked(p.id);
          final muted = app.isMuted(p.id);
          final topInset = MediaQuery.of(context).padding.top;

          return Scaffold(
            backgroundColor: kSurface,
            body: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ---- Colored header ----
                Container(
                  padding: EdgeInsets.fromLTRB(6, topInset + 4, 6, 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF5B21B6),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            color: Colors.white,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'More options',
                            iconColor: Colors.white,
                            onSelected: (v) {
                              if (v == 'block') _confirmBlock(context, p);
                              if (v == 'unblock') app.unblock(p.id);
                            },
                            itemBuilder: (_) => [
                              if (!blocked)
                                const PopupMenuItem(
                                    value: 'block',
                                    child: Text('Block User', style: TextStyle(color: kRed)))
                              else
                                const PopupMenuItem(value: 'unblock', child: Text('Unblock User')),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0x59FFFFFF),
                          shape: BoxShape.circle,
                        ),
                        child: Avatar.person(p, size: 104),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        p.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${p.username} · ${fmtCount(p.followers)} followers',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Color(0xFFDDD6FE)),
                      ),
                    ],
                  ),
                ),

                // ---- Action tiles ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: blocked
                      ? Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'You blocked this user. They can’t message you or see your profile.',
                            style: TextStyle(color: kRed, height: 1.4),
                          ),
                        )
                      : Row(
                          children: [
                            _ActionTile(
                              icon: following
                                  ? Icons.how_to_reg_outlined
                                  : Icons.person_add_alt_1_outlined,
                              label: following ? 'Following' : 'Follow',
                              onTap: () => app.toggleFollow(p.id),
                            ),
                            const SizedBox(width: 10),
                            _ActionTile(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: 'Message',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => ChatScreen(personId: p.id)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _ActionTile(
                              icon: muted
                                  ? Icons.notifications_off_outlined
                                  : Icons.notifications_none_rounded,
                              label: muted ? 'Unmute' : 'Mute',
                              onTap: () {
                                app.toggleMute(p.id);
                                showSnack(context,
                                    muted ? 'Notifications turned on' : 'Notifications muted');
                              },
                            ),
                          ],
                        ),
                ),

                // ---- Info card ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (p.bio.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BioText(text: p.bio),
                                const SizedBox(height: 4),
                                const Text('Bio',
                                    style: TextStyle(fontSize: 13, color: kMuted)),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('@${p.username}',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: kPrimary,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              const Text('Username',
                                  style: TextStyle(fontSize: 13, color: kMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---- Block / unblock ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  child: _MenuGroup(children: [
                    blocked
                        ? _MenuItem(
                            icon: Icons.lock_open_rounded,
                            label: 'Unblock User',
                            onTap: () {
                              app.unblock(p.id);
                              showSnack(context, '${p.name} has been unblocked');
                            },
                          )
                        : _MenuItem(
                            icon: Icons.block_rounded,
                            label: 'Block User',
                            danger: true,
                            onTap: () => _confirmBlock(context, p),
                          ),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: kPrimary, size: 22),
                const SizedBox(height: 6),
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: kPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
