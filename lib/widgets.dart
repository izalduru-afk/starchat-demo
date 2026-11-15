import 'package:flutter/material.dart';

import 'data.dart';

void showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initials,
    required this.bg,
    required this.fg,
    this.size = 48,
  });

  final String initials;
  final Color bg;
  final Color fg;
  final double size;

  factory Avatar.person(Person p, {double size = 48}) =>
      Avatar(initials: p.initials, bg: p.bg, fg: p.fg, size: size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        initials,
        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: size * 0.34),
      ),
    );
  }
}

class GroupAvatar extends StatelessWidget {
  const GroupAvatar({super.key, required this.group, this.size = 52});

  final Group group;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: group.bg,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(Icons.groups_rounded, color: group.fg, size: size * 0.55),
    );
  }
}

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(11)),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// One row in the chat and group lists on the Home screen.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.leading,
    required this.title,
    required this.preview,
    required this.time,
    required this.unread,
    required this.onTap,
    this.subtitle,
  });

  final Widget leading;
  final String title;
  final String preview;
  final String time;
  final int unread;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(time, style: const TextStyle(fontSize: 12, color: kMuted)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: unread > 0 ? kText : kMuted,
                            fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(width: 8),
                        UnreadBadge(count: unread),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: const TextStyle(fontSize: 12, color: kMuted)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonTile extends StatelessWidget {
  const PersonTile({super.key, required this.person, this.trailing, this.onTap});

  final Person person;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Avatar.person(person, size: 50),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(person.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText)),
                  const SizedBox(height: 3),
                  Text('@${person.username}', style: const TextStyle(fontSize: 13, color: kMuted)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.showSender = false});

  final Message message;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    if (message.senderId == 'system') {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(12)),
          child: Text(message.text,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: kMuted)),
        ),
      );
    }

    final mine = message.mine;
    final sender = app.maybePerson(message.senderId);

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.fromLTRB(14, 9, 14, 8),
      decoration: BoxDecoration(
        color: mine ? kPrimary : Colors.white,
        border: mine ? null : Border.all(color: kBorder),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(mine ? 18 : 4),
          bottomRight: Radius.circular(mine ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSender && !mine && sender != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(sender.name,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: sender.fg)),
            ),
          Text(
            message.text,
            style: TextStyle(fontSize: 15, height: 1.4, color: mine ? Colors.white : kText),
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerRight,
            widthFactor: 1,
            child: Text(
              fmtClock(message.time),
              style: TextStyle(fontSize: 11, color: mine ? const Color(0xFFE4DCFB) : kMuted),
            ),
          ),
        ],
      ),
    );

    if (mine) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [bubble]),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showSender && sender != null) ...[
            Avatar.person(sender, size: 32),
            const SizedBox(width: 8),
          ],
          bubble,
        ],
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  const MessageInput({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  void _addEmoji() {
    const emoji = '\u{1F60A}';
    final sel = _controller.selection;
    final text = _controller.text;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    _controller.value = TextEditingValue(
      text: text.replaceRange(start, end, emoji),
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 10, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Add emoji',
                onPressed: _addEmoji,
                icon: const Icon(Icons.sentiment_satisfied_alt_outlined, color: kMuted),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: kSurface,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: kPrimary, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Send',
                onPressed: _send,
                style: IconButton.styleFrom(backgroundColor: kPrimary, foregroundColor: Colors.white),
                icon: const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A light pill-shaped search box.
class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.hint, required this.onChanged, this.autofocus = false});

  final String hint;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autofocus,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, color: kMuted),
        filled: true,
        fillColor: kSurface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),
    );
  }
}

class StatBox extends StatelessWidget {
  const StatBox({super.key, required this.items});

  /// Pairs of (value, label).
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) children.add(Container(width: 1, height: 40, color: kBorder));
      children.add(Expanded(
        child: Column(
          children: [
            Text(items[i].$1,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: kText)),
            const SizedBox(height: 2),
            Text(items[i].$2, style: const TextStyle(fontSize: 13, color: kMuted)),
          ],
        ),
      ));
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: children),
    );
  }
}

class InfoSection extends StatelessWidget {
  const InfoSection({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF3F3A4F))),
        ],
      ),
    );
  }
}
