import 'package:flutter_test/flutter_test.dart';

import 'package:student_lms/services/mock/mock_auth_service.dart';

void main() {
  test('Mock login dengan kredensial seed berhasil', () async {
    final auth = MockAuthService();
    final user = await auth.signIn(
      email: 'admin@sekolah.id',
      password: 'password',
    );
    expect(user.email, 'admin@sekolah.id');
  });
}
