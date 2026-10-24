import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wavemart/presentation/providers/job_seeker_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('home seeker feed is isolated from the dedicated list screen', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final listNotifier = container.read(jobSeekerProfilesProvider.notifier);
    final homeNotifier = container.read(homeJobSeekerProfilesProvider.notifier);

    expect(identical(listNotifier, homeNotifier), isFalse);
  });
}
