import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhd_0_1/src/features/user_data_portal/domain/io/file_picker_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('default should use custom filter then mark unsupported', () async {
    SharedPreferences.setMockInitialValues({});
    final before = await FilePickerPrefs.shouldUseCustomFilter();
    expect(before, isTrue);

    await FilePickerPrefs.markFilterUnsupported();
    final after = await FilePickerPrefs.shouldUseCustomFilter();
    expect(after, isFalse);

    await FilePickerPrefs.reset();
    final reset = await FilePickerPrefs.shouldUseCustomFilter();
    expect(reset, isTrue);
  });
}
