import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_providers.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
Stream<User?> authStateStream(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  final StreamController<User?> controller = StreamController<User?>();

  // 초기 사용자 정보 발행
  controller.add(supabaseClient.auth.currentUser);

  // 인증 상태 변경 감지
  final authSubscription = supabaseClient.auth.onAuthStateChange.listen(
    (AuthState authState) {
      controller.add(authState.session?.user);
    },
    onError: (error, stackTrace) {
      print('Auth State Stream Error: $error');
      controller.addError(error, stackTrace);
    },
  );

  // Provider가 폐기될 때 스트림 구독 해제 및 컨트롤러 종료
  ref.onDispose(() {
    authSubscription.cancel();
    controller.close();
  });

  return controller.stream;
}
