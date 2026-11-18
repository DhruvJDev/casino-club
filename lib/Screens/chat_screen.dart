import 'dart:async';

import 'package:flutter/material.dart';

import '../services/app_storage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<AppUser> _contacts = [];
  List<ChatMessage> _messages = [];
  AppUser? _selectedContact;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _loadContacts();
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final accounts = await AppStorage.getAccounts();
    final contacts = accounts
        .where((account) =>
            account.username.toLowerCase() !=
            widget.user.username.toLowerCase())
        .toList();
    if (!mounted) return;
    setState(() {
      _contacts = contacts;
      _selectedContact ??= contacts.isNotEmpty ? contacts.first : null;
    });
  }

  Future<void> _loadMessages({bool force = false}) async {
    final contact = _selectedContact;
    if (contact == null) return;
    final messages = await AppStorage.getConversation(
        widget.user.username, contact.username);
    final unchanged = messages.length == _messages.length &&
        (messages.isEmpty ||
            messages.last.id == (_messages.isEmpty ? '' : _messages.last.id));
    if (!mounted || (!force && unchanged)) return;
    setState(() => _messages = messages);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _selectContact(AppUser contact) async {
    setState(() {
      _selectedContact = contact;
      _messages = [];
    });
    await _loadMessages(force: true);
  }

  Future<void> _send() async {
    final contact = _selectedContact;
    final text = _controller.text.trim();
    if (contact == null || text.isEmpty) return;
    await AppStorage.sendDirectMessage(
      widget.user.username,
      contact.username,
      ChatMessage(
        id: '${DateTime.now().microsecondsSinceEpoch}-${widget.user.username}',
        sender: widget.user.username,
        text: text,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    _controller.clear();
    await _loadMessages(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Padding(
        padding: EdgeInsets.all(isWide ? 18 : 8),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF171A23),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              if (isWide || _selectedContact == null)
                SizedBox(
                  width: isWide ? 300 : MediaQuery.sizeOf(context).width,
                  child: _buildInbox(),
                ),
              if (isWide || _selectedContact != null)
                Expanded(
                  child: _selectedContact == null
                      ? const Center(
                          child: Text(
                            'Select or create a user to start chatting',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : _buildThread(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInbox() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 22, 22, 14),
            child: Text(
              'Messages',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users',
                prefixIcon: const Icon(Icons.search, size: 21),
                filled: true,
                fillColor: const Color(0xFF20242F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _contacts.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No other accounts yet. Register another account to chat.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      final selected =
                          _selectedContact?.username == contact.username;
                      return InkWell(
                        onTap: () => _selectContact(contact),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF6966F6)
                                    .withValues(alpha: 0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF6966F6),
                                child: Text(
                                  contact.name.isEmpty
                                      ? '?'
                                      : contact.name[0].toUpperCase(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(contact.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700)),
                                    Text('@${contact.username}',
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.white38),
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
  }

  Widget _buildThread() {
    final contact = _selectedContact!;
    return Column(
      children: [
        Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10)),
          ),
          child: Row(
            children: [
              if (MediaQuery.sizeOf(context).width < 760)
                IconButton(
                  onPressed: () => setState(() => _selectedContact = null),
                  icon: const Icon(Icons.arrow_back),
                ),
              CircleAvatar(
                backgroundColor: const Color(0xFF6966F6),
                child: Text(contact.name[0].toUpperCase()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(contact.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const Text('Direct message',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _messages.isEmpty
              ? const Center(
                  child: Text(
                    'Send your first message',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final mine = message.sender.toLowerCase() ==
                        widget.user.username.toLowerCase();
                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 520),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: mine
                              ? const Color(0xFF6966F6)
                              : const Color(0xFF262B38),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(mine ? 16 : 4),
                            bottomRight: Radius.circular(mine ? 4 : 16),
                          ),
                        ),
                        child: Text(message.text),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Write a message...',
                    filled: true,
                    fillColor: const Color(0xFF20242F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _send,
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  backgroundColor: const Color(0xFF6966F6),
                ),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
