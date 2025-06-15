import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/supabase_providers.dart';

class RealtimeService {
  RealtimeService(this._ref) {
    _client = _ref.read(supabaseClientProvider);

    // 1. 앞으로 발생할 Auth 상태 변경을 감지할 리스너
    _authSubscription = _client.auth.onAuthStateChange.listen((
      AuthState authState,
    ) {
      _handleAuthStateChange(authState);
    });

    // 2. 서비스가 생성되는 '현재' 시점의 Auth 상태를 확인하여 초기 구독 결정
    if (_client.auth.currentUser != null) {
      // 앱 시작 시 이미 로그인 된 상태라면, 바로 구독 시작
      print(
        "${DateTime.now()}: [RealtimeService] Initial user found. Subscribing.",
      );
      subscribe();
    } else {
      // 로그인되지 않은 상태라면, 다음 signedIn 이벤트를 기다림
      print(
        "${DateTime.now()}: [RealtimeService] No initial user. Waiting for sign-in.",
      );
    }
  }

  final Ref _ref;
  late final SupabaseClient _client;
  StreamSubscription<AuthState>? _authSubscription;
  RealtimeChannel? _channel;

  final _payloadController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get payloadStream => _payloadController.stream;

  void _handleAuthStateChange(AuthState authState) {
    final event = authState.event;
    // final session = authState.session;

    print("${DateTime.now()}: [RealtimeService] Auth state changed: $event");

    if (event == AuthChangeEvent.initialSession ||
        event == AuthChangeEvent.signedIn) {
      subscribe();
    } else if (event == AuthChangeEvent.signedOut) {
      dispose();
    }
    // else if (event == AuthChangeEvent.tokenRefreshed) {
    //   if (session != null) {
    //     print('🔑 Token refreshed. Resetting realtime subscription.');
    //     _client.realtime.setAuth(session.accessToken);
    //   }
    // }
  }

  void subscribe() {
    if (_channel != null) return;

    print("${DateTime.now()}: [RealtimeService] Subscribing to channel.");
    _channel = _client.channel('public:newsfeeds');
    _channel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'newsfeeds',
          callback: (payload) {
            print('${DateTime.now()}: ✅ [RealtimeService] Event received!');
            _payloadController.add(payload.newRecord);
          },
        )
        .subscribe((status, Object? error) {
          print(
            "${DateTime.now()}: 📢 [RealtimeService] Channel status: $status",
          );

          if (error != null) {
            print(
              '${DateTime.now()}: 🚨 [RealtimeService] Channel error: $error',
            );
          }
        });
  }

  Future<void> dispose() async {
    if (_channel != null) {
      print("${DateTime.now()}: [RealtimeService] Cleaning up channel");
      await _channel!.unsubscribe();
      await _client.removeChannel(_channel!);
      _channel = null;
    }
  }

  void cancel() {
    _authSubscription?.cancel();
    dispose();
  }
}
