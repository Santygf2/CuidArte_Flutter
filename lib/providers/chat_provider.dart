import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/chat_message_model.dart';
import '../models/chat_thread_model.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  List<ChatThreadModel> _threads = [];
  List<ChatMessageModel> _messages = [];
  ChatThreadModel? _activeThread;
  bool _isLoadingThreads = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _errorMessage;

  List<ChatThreadModel> get threads => _threads;
  List<ChatMessageModel> get messages => _messages;
  ChatThreadModel? get activeThread => _activeThread;
  bool get isLoadingThreads => _isLoadingThreads;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  int get unreadTotal => _threads.fold(0, (sum, thread) => sum + thread.unread);

  Future<void> loadThreads() async {
    _isLoadingThreads = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _api.get('/requests/');
      final list = data is List ? data : const [];
      _threads = list
          .whereType<Map>()
          .map(
            (item) => ChatThreadModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No se pudieron cargar tus conversaciones.';
    } finally {
      _isLoadingThreads = false;
      notifyListeners();
    }
  }

  Future<ChatThreadModel> startThread(String caregiverId) async {
    final id = int.tryParse(caregiverId);
    if (id == null) {
      throw ApiException(null, 'El cuidador no es válido.');
    }
    final data = await _api.post('/requests/', body: {'caregiver': id});
    final thread = ChatThreadModel.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
    _threads.removeWhere((item) => item.id == thread.id);
    _threads.insert(0, thread);
    notifyListeners();
    return thread;
  }

  Future<void> openThread(ChatThreadModel thread) async {
    _activeThread = thread;
    _messages = [];
    _errorMessage = null;
    notifyListeners();
    await loadMessages();
  }

  Future<void> loadMessages({bool silent = false}) async {
    final thread = _activeThread;
    if (thread == null) return;
    if (!silent) {
      _isLoadingMessages = true;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final data = await _api.get('/requests/${thread.id}/messages/');
      final list = data is List ? data : const [];
      _messages = list
          .whereType<Map>()
          .map(
            (item) =>
                ChatMessageModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      final index = _threads.indexWhere((item) => item.id == thread.id);
      if (index != -1) {
        _threads[index] = ChatThreadModel(
          id: thread.id,
          otherName: thread.otherName,
          otherAvatar: thread.otherAvatar,
          otherRole: thread.otherRole,
          lastMessage: _messages.isNotEmpty
              ? _messages.last.text
              : thread.lastMessage,
          lastMine: _messages.isNotEmpty
              ? _messages.last.mine
              : thread.lastMine,
          lastTime: _messages.isNotEmpty
              ? _messages.last.time
              : thread.lastTime,
          unread: 0,
          status: thread.status,
          caregiverId: thread.caregiverId,
        );
        _activeThread = _threads[index];
      }
    } on ApiException catch (error) {
      if (!silent) {
        _errorMessage = error.message;
      }
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    final thread = _activeThread;
    final content = text.trim();
    if (thread == null || content.isEmpty || _isSending) return;
    _isSending = true;
    notifyListeners();
    try {
      final data = await _api.post(
        '/requests/${thread.id}/messages/',
        body: {'text': content},
      );
      if (data is Map) {
        _messages = [
          ..._messages,
          ChatMessageModel.fromJson(Map<String, dynamic>.from(data)),
        ];
      }
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void reset() {
    _threads = [];
    _messages = [];
    _activeThread = null;
    _isLoadingThreads = false;
    _isLoadingMessages = false;
    _isSending = false;
    _errorMessage = null;
    notifyListeners();
  }
}
