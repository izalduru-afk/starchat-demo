import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../widgets.dart';
import 'group_screens.dart';
import 'profile_screens.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.personId});

  final String personId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => app.markRead(widget.personId));
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => UserProfileScreen(personId: widget.personId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = app.person(widget.personId);

    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final messages = app.messagesWith(p.id);
        final blocked = app.isBlocked(p.id);

        return Scaffold(
          backgroundColor: kChatBg,
          appBar: AppBar(
            titleSpacing: 0,
            shape: const Border(bottom: BorderSide(color: kBorder)),
            title: InkWell(
              onTap: _openProfile,
              child: Row(
                children: [
                  Avatar.person(p, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600, color: kText)),
                        Text(blocked ? 'Blocked' : 'Online',
                            style: TextStyle(fontSize: 12, color: blocked ? kRed : kGreen)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                tooltip: 'More options',
                onSelected: (v) {
                  if (v == 'profile') _openProfile();
                  if (v == 'block') {
                    app.block(p.id);
                    showSnack(context, '${p.name} has been blocked');
                  }
                  if (v == 'unblock') {
                    app.unblock(p.id);
                    showSnack(context, '${p.name} has been unblocked');
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'profile', child: Text('View Profile')),
                  if (!blocked)
                    const PopupMenuItem(
                        value: 'block', child: Text('Block User', style: TextStyle(color: kRed)))
                  else
                    const PopupMenuItem(value: 'unblock', child: Text('Unblock User')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) =>
                      MessageBubble(message: messages[messages.length - 1 - i]),
                ),
              ),
              if (blocked)
                _BlockedBar(onUnblock: () => app.unblock(p.id))
              else
                MessageInput(onSend: (t) => app.sendToPerson(p.id, t)),
            ],
          ),
        );
      },
    );
  }
}

class _BlockedBar extends StatelessWidget {
  const _BlockedBar({required this.onUnblock});

  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
          child: Row(
            children: [
              const Expanded(
                child: Text('You blocked this user.', style: TextStyle(color: kMuted)),
              ),
              TextButton(onPressed: onUnblock, child: const Text('Unblock')),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => app.markGroupRead(widget.groupId));
  }

  void _openInfo() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => GroupPreviewScreen(groupId: widget.groupId, fromChat: true)),
    );
  }

  Future<void> _copyLink(Group g) async {
    await Clipboard.setData(ClipboardData(text: 'https://${g.link}'));
    if (mounted) showSnack(context, 'Invite link copied');
  }

  Future<void> _leave(Group g) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave group?'),
        content: Text('You will no longer receive messages from ${g.name}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Leave', style: TextStyle(color: kRed)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      app.leaveGroup(g.id);
      Navigator.of(context).pop();
      showSnack(context, 'You left ${g.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final g = app.group(widget.groupId);
        final messages = g.messages;

        return Scaffold(
          backgroundColor: kChatBg,
          appBar: AppBar(
            titleSpacing: 0,
            shape: const Border(bottom: BorderSide(color: kBorder)),
            title: InkWell(
              onTap: _openInfo,
              child: Row(
                children: [
                  GroupAvatar(group: g, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600, color: kText)),
                        Text('${g.link} · ${fmtCount(g.members)} members',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: kMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                tooltip: 'More options',
                onSelected: (v) {
                  if (v == 'info') _openInfo();
                  if (v == 'copy') _copyLink(g);
                  if (v == 'leave') _leave(g);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'info', child: Text('Group Info')),
                  PopupMenuItem(value: 'copy', child: Text('Copy Invite Link')),
                  PopupMenuItem(
                      value: 'leave', child: Text('Leave Group', style: TextStyle(color: kRed))),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              if (g.announcement.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.push_pin_rounded, size: 18, color: kPrimaryDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Announcement',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: kPrimaryDark)),
                            const SizedBox(height: 2),
                            Text(g.announcement,
                                style: const TextStyle(
                                    fontSize: 13, height: 1.4, color: kPrimaryDark)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => MessageBubble(
                    message: messages[messages.length - 1 - i],
                    showSender: true,
                  ),
                ),
              ),
              if (g.joined)
                MessageInput(onSend: (t) => app.sendToGroup(g.id, t))
              else
                Container(
                  color: Colors.white,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => GroupPreviewScreen(groupId: g.id, fromChat: true)),
                          ),
                          child: const Text('Join Group'),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
