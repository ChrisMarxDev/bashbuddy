import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';


const settingsBox = 'settings';

final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box(settingsBox);
});

final darkModeProvider =
    StateNotifierProvider<SettingsNotifier<bool>, bool>((ref) {
  return SettingsNotifier(ref, 'darkMode', false);
});

final showPathInformationProvider =
    StateNotifierProvider<SettingsNotifier<bool>, bool>((ref) {
  return SettingsNotifier(ref, 'showPathInformation', true);
});

class SettingsNotifier<T> extends StateNotifier<T> {
  final Ref ref;
  final String key;
  final T defaultValue;

  SettingsNotifier(this.ref, this.key, this.defaultValue)
      : super(defaultValue) {
    final box = ref.read(settingsBoxProvider);
    final value = box.get(key, defaultValue: defaultValue);
    if (value != null) {
      state = value;
    }
  }

  void save(T value) {
    final box = ref.read(settingsBoxProvider);
    box.put(key, value);
    state = value;
  }
}
