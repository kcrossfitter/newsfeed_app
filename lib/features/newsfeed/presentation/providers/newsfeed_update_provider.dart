import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/newsfeed_display.dart';

part 'newsfeed_update_provider.g.dart';

@riverpod
class NewsfeedUpdateEvent extends _$NewsfeedUpdateEvent {
  @override
  NewsfeedDisplay? build() {
    return null;
  }

  void update(NewsfeedDisplay newsfeed) {
    state = newsfeed;
  }
}
