import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'router/app_router.dart';
import 'services/api/api_auth_service.dart';
import 'services/api/api_client.dart';
import 'services/api/api_data_service.dart';
import 'services/auth_service.dart';
import 'services/data_service.dart';
import 'services/mock/mock_auth_service.dart';
import 'services/mock/mock_data_service.dart';
import 'theme/app_theme.dart';

/// Aktifkan untuk memakai backend FastAPI (lihat folder `backend/`).
/// Bila `false`, aplikasi memakai data mock in-memory (mode demo mandiri,
/// dipakai untuk build GitHub Pages).
///
/// Dapat ditimpa saat build/run:
///   flutter run --dart-define=USE_API=true \
///               --dart-define=API_BASE_URL=http://localhost:8000
const bool useApi =
    bool.fromEnvironment('USE_API', defaultValue: false);

/// Base URL backend FastAPI (tanpa garis miring di akhir).
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  late final AuthService authService;
  late final DataService dataService;

  if (useApi) {
    final apiClient = ApiClient(baseUrl: apiBaseUrl);
    authService = ApiAuthService(apiClient);
    dataService = ApiDataService(apiClient);
  } else {
    authService = MockAuthService();
    dataService = MockDataService();
  }

  // Restore any persisted session before runApp so the router sees the
  // correct initial auth state (no flash of /login on refresh).
  await authService.init();

  runApp(StudentLmsApp(
    authService: authService,
    dataService: dataService,
  ));
}

class StudentLmsApp extends StatefulWidget {
  const StudentLmsApp({
    super.key,
    required this.authService,
    required this.dataService,
  });

  final AuthService authService;
  final DataService dataService;

  @override
  State<StudentLmsApp> createState() => _StudentLmsAppState();
}

class _StudentLmsAppState extends State<StudentLmsApp> {
  late final AuthProvider _auth = AuthProvider(widget.authService);
  late final DataProvider _data = DataProvider(widget.dataService);

  @override
  void dispose() {
    _auth.dispose();
    _data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = buildRouter(_auth);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
        ChangeNotifierProvider<DataProvider>.value(value: _data),
      ],
      child: MaterialApp.router(
        title: 'SMK Negeri 1 Pati',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: router,
        locale: const Locale('id', 'ID'),
      ),
    );
  }
}
