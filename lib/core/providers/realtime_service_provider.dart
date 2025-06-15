import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/realtime_service.dart';

part 'realtime_service_provider.g.dart';

@Riverpod(keepAlive: true)
RealtimeService realtimeService(Ref ref) {
  final service = RealtimeService(ref);
  ref.onDispose(() => service.cancel());
  return service;
}

@riverpod
Stream<Map<String, dynamic>> newPostStream(Ref ref) {
  // realtimeServiceProvider를 watch하여 서비스 인스턴스를 가져옴
  final realtimeService = ref.watch(realtimeServiceProvider);
  // 서비스의 payloadStream을 반환
  return realtimeService.payloadStream;
}
