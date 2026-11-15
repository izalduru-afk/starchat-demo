import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../data.dart';
import '../widgets.dart';
import 'chat_screens.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _create() {
    setState(() => _submitted = true);
    final name = _name.text.trim();
    if (name.isEmpty) {
      showSnack(context, 'Please enter a group name');
      return;
    }
    _payAndCreate(name);
  }

  Future<void> _payAndCreate(String name) async {
    final fee = fmtCount(kGroupCreationFee);

    if (!app.canAfford(kGroupCreationFee)) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.star_rounded, color: kStar, size: 36),
          title: const Text('Not enough Stars'),
          content: Text(
            'Creating a group costs $fee Stars. Your balance is ${fmtCount(app.stars)} Stars.\n\n'
            'Top up will be available soon.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.star_rounded, color: kStar, size: 36),
        title: Text('Pay $fee Stars?'),
        content: Text(
          '$fee Stars will be deducted to create "$name".\n'
          'Balance after payment: ${fmtCount(app.stars - kGroupCreationFee)} Stars.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Pay $fee'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    app.spendStars(kGroupCreationFee, 'Create group: $name');
    final id = app.createGroup(
      name: name,
      description: _description.text.trim(),
      memberIds: const <String>{},
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GroupChatScreen(groupId: id)),
    );
    showSnack(context, 'Group created · $fee Stars paid · invite link ready');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Group')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              InkWell(
                onTap: () =>
                    showSnack(context, 'Photo upload will be available in the full version'),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFC4B5FD), width: 2),
                  ),
                  child: const Icon(Icons.add_a_photo_outlined, color: kPrimary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Group Name',
                    errorText:
                        _submitted && _name.text.trim().isEmpty ? 'Group name is required' : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kPrimaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, color: kPrimary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is a private group. A secret invite link (starchat.app/+…) '
                    'will be created automatically. Only people with the link can join.',
                    style: TextStyle(fontSize: 13, height: 1.45, color: kPrimaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _description,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(
            onPressed: _create,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Create Group · ${fmtCount(kGroupCreationFee)}'),
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded, color: Color(0xFFFCD34D), size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchGroupsScreen extends StatefulWidget {
  const SearchGroupsScreen({super.key});

  @override
  State<SearchGroupsScreen> createState() => _SearchGroupsScreenState();
}

class _SearchGroupsScreenState extends State<SearchGroupsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final results = app.searchGroups(_query);
        return Scaffold(
          appBar: AppBar(title: const Text('Find Groups')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: SearchBox(
                  hint: 'Group name or link, e.g. starchat.app/...',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? const Center(
                        child: Text('No groups found', style: TextStyle(color: kMuted)))
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, i) {
                          final g = results[i];
                          return InkWell(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => g.joined
                                  ? GroupChatScreen(groupId: g.id)
                                  : GroupPreviewScreen(groupId: g.id),
                            )),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                children: [
                                  GroupAvatar(group: g),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(g.name,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: kText)),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${g.link} · ${fmtCount(g.members)} members',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 13, color: kMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (g.joined)
                                    const Text('Joined',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: kGreen))
                                  else
                                    const Icon(Icons.chevron_right_rounded, color: kMuted),
                                ],
                              ),
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

/// Shown when someone opens a group invite link.
/// Shows only the group name, member count, description, and the join price.
class GroupPreviewScreen extends StatelessWidget {
  const GroupPreviewScreen({super.key, required this.groupId, this.fromChat = false});

  final String groupId;

  /// True when opened from inside the group chat, so the button just goes back.
  final bool fromChat;

  Future<void> _join(BuildContext context, Group g) async {
    final fee = g.joinFee;

    if (fee > 0) {
      if (!app.canAfford(fee)) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.star_rounded, color: kStar, size: 36),
            title: const Text('Not enough Stars'),
            content: Text(
              'Joining this group costs ${fmtCount(fee)} Stars. '
              'Your balance is ${fmtCount(app.stars)} Stars.\n\nTop up will be available soon.',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
        return;
      }

      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.star_rounded, color: kStar, size: 36),
          title: Text('Pay ${fmtCount(fee)} Stars?'),
          content: Text(
            '${fmtCount(fee)} Stars will be deducted to join "${g.name}".\n'
            'Balance after payment: ${fmtCount(app.stars - fee)} Stars.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Pay ${fmtCount(fee)}'),
            ),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      app.spendStars(fee, 'Join group: ${g.name}');
    }

    app.joinGroup(g.id);
    if (!context.mounted) return;
    if (fromChat) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => GroupChatScreen(groupId: g.id)),
      );
    }
    showSnack(context, fee > 0 ? 'Joined · ${fmtCount(fee)} Stars paid' : 'Joined ${g.name}');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final g = app.group(groupId);
        final free = g.joinFee == 0;

        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Center(child: GroupAvatar(group: g, size: 104)),
              const SizedBox(height: 16),
              Text(
                g.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kText),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.groups_rounded, size: 18, color: kMuted),
                  const SizedBox(width: 6),
                  Text('${fmtCount(g.members)} members',
                      style: const TextStyle(fontSize: 14, color: kMuted)),
                ],
              ),
              if (g.description.isNotEmpty) ...[
                const SizedBox(height: 22),
                Text(
                  g.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF3F3A4F)),
                ),
              ],
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: g.joined
                  ? FilledButton(
                      onPressed: () {
                        if (fromChat) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => GroupChatScreen(groupId: g.id)),
                          );
                        }
                      },
                      child: const Text('Open Chat'),
                    )
                  : FilledButton(
                      onPressed: () => _join(context, g),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(free ? 'Join Group · Free' : 'Join Group · ${fmtCount(g.joinFee)}'),
                          if (!free) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded, color: Color(0xFFFCD34D), size: 22),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// Bio text where group links such as starchat.app/designcommunity can be tapped.
class BioText extends StatefulWidget {
  const BioText({super.key, required this.text});

  final String text;

  @override
  State<BioText> createState() => _BioTextState();
}

class _BioTextState extends State<BioText> {
  static final RegExp _linkPattern =
      RegExp(r'(?:https?://)?(?:www\.)?starchat\.app/\+([A-Za-z0-9_]+)');

  final List<TapGestureRecognizer> _recognizers = [];

  void _clearRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  void _openGroup(String username) {
    final g = app.groupByUsername(username);
    if (g == null) {
      showSnack(context, 'This invite link is invalid or has expired');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GroupPreviewScreen(groupId: g.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    _clearRecognizers();
    const baseStyle = TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF3F3A4F));
    const linkStyle = TextStyle(
      fontSize: 15,
      height: 1.5,
      color: kPrimary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
      decorationColor: kPrimary,
    );

    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _linkPattern.allMatches(widget.text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: widget.text.substring(last, m.start)));
      }
      final username = m.group(1)!;
      final recognizer = TapGestureRecognizer()..onTap = () => _openGroup(username);
      _recognizers.add(recognizer);
      spans.add(TextSpan(text: m.group(0), style: linkStyle, recognizer: recognizer));
      last = m.end;
    }
    if (last < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(last)));
    }

    return Text.rich(TextSpan(style: baseStyle, children: spans));
  }
}

class BioSection extends StatelessWidget {
  const BioSection({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bio',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          BioText(text: text),
        ],
      ),
    );
  }
}


const kStar = Color(0xFFD97706);

/// Simple Stars wallet screen: balance and transaction history.
class StarsScreen extends StatelessWidget {
  const StarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Stars')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kPrimaryDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Star Balance',
                        style: TextStyle(fontSize: 14, color: Color(0xFFD9CFF7))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFCD34D), size: 32),
                        const SizedBox(width: 8),
                        Text(
                          '${fmtCount(app.stars)} Stars',
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: null,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kBorder, width: 1.5),
                    disabledForegroundColor: kMuted,
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Top Up Stars · Soon'),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Recent Transactions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(height: 8),
              for (final t in app.starHistory)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.label,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500, color: kText)),
                            const SizedBox(height: 2),
                            Text('${fmtDate(t.time)}, ${fmtClock(t.time)}',
                                style: const TextStyle(fontSize: 12, color: kMuted)),
                          ],
                        ),
                      ),
                      Text(
                        '${t.amount > 0 ? '+' : '−'}${fmtCount(t.amount.abs())}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: t.amount > 0 ? kGreen : kRed,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded, color: kStar, size: 18),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
