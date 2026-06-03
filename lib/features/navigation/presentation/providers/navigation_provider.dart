import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

@riverpod
class NavigationIndex extends _$NavigationIndex {
  @override
  int build() {
    return 0; // Default to HOME
  }

  void setIndex(int index) {
    state = index;
  }
}
