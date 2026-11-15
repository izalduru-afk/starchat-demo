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
  final _username = TextEditingController();
  final _description = TextEditingController();
  final Set<String> _selected = {};
  bool _usernameEdited = false;
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _description.dispose();
    super.dispose();
  }

  String? get _usernameError {
    final u = _username.text.trim();
    if (u.isEmpty) return _submitted ? 'Group username is required' : null;
    if (!kUsernamePattern.hasMatch(u)) return 'Use 3–30 lowercase letters, numbers, or _';
    if (app.isGroupUsernameTaken(u)) return 'This link is already taken';
    return null;
  }

  void _onNameChanged(String value) {
    if (!_usernameEdited) {
      final slug = slugify(value);
      _username.text = slug.length > 30 ? slug.substring(0, 30) : slug;
    }
    setState(() {});
  }

  void _create() {
    setState(() => _submitted = true);
    final name = _name.text.trim();
    final username = _username.text.trim();
    if (name.isEmpty || username.isEmpty || _usernameError != null) {
      showSnack(context, 'Please complete the group name and link');
      return;
    }
    final id = app.createGroup(
      name: name,
      username: username,
      description: _description.text.trim(),
      memberIds: _selected,
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => GroupChatScreen(groupId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usernameError = _usernameError;
    final usernameOk = _username.text.trim().isNotEmpty && usernameError == null;
    final people = app.followingPeople;

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
                  onChanged: _onNameChanged,
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
          TextField(
            controller: _username,
            autocorrect: false,
            onChanged: (_) => setState(() => _usernameEdited = true),
            decoration: InputDecoration(
              labelText: 'Group Username / Link',
              prefixText: 'starchat.app/',
              prefixStyle: const TextStyle(color: kMuted, fontSize: 16),
              suffixIcon:
                  usernameOk ? const Icon(Icons.check_circle_rounded, color: kGreen) : null,
              helperText: usernameOk
                  ? 'Available — people can find and join with this link'
                  : 'People can find and join your group with this link',
              helperStyle: TextStyle(color: usernameOk ? kGreen : kMuted),
              helperMaxLines: 2,
              errorText: usernameError,
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
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: Text('Add Members',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText)),
              ),
              Text('${_selected.length} selected',
                  style: const TextStyle(fontSize: 13, color: kMuted)),
            ],
          ),
          const SizedBox(height: 2),
          const Text('From people you follow', style: TextStyle(fontSize: 13, color: kMuted)),
          const SizedBox(height: 6),
          for (final p in people)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _selected.contains(p.id),
              activeColor: kPrimary,
              onChanged: (v) => setState(() {
                if (v == true) {
                  _selected.add(p.id);
                } else {
                  _selected.remove(p.id);
                }
              }),
              secondary: Avatar.person(p, size: 44),
              title: Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: kText)),
              subtitle: Text('@${p.username}', style: const TextStyle(color: kMuted)),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton(onPressed: _create, child: const Text('Create Group')),
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

/// Shown when someone opens a group link or taps a group they haven't joined.
class GroupPreviewScreen extends StatelessWidget {
  const GroupPreviewScreen({super.key, required this.groupId, this.fromChat = false});

  final String groupId;

  /// True when opened from inside the group chat, so "Open Chat" just goes back.
  final bool fromChat;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final g = app.group(groupId);
        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              Center(child: GroupAvatar(group: g, size: 104)),
              const SizedBox(height: 16),
              Text(g.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kText)),
              const SizedBox(height: 4),
              Text(g.link,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: kPrimary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              StatBox(items: [
                (fmtCount(g.members), 'Members'),
                (g.joined ? 'Joined' : 'Open', 'Status'),
              ]),
              const SizedBox(height: 22),
              if (g.description.isNotEmpty) InfoSection(title: 'About', body: g.description),
              if (g.announcement.isNotEmpty)
                InfoSection(title: 'Announcement', body: g.announcement),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: FilledButton(
                onPressed: () {
                  if (fromChat) {
                    app.joinGroup(g.id);
                    Navigator.of(context).pop();
                    return;
                  }
                  if (!g.joined) app.joinGroup(g.id);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => GroupChatScreen(groupId: g.id)),
                  );
                },
                child: Text(g.joined ? 'Open Chat' : 'Join Group'),
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
      RegExp(r'(?:https?://)?(?:www\.)?starchat\.app/([A-Za-z0-9_]+)');

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
      showSnack(context, 'Group starchat.app/$username was not found');
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
