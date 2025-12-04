import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/env/environment.dart';
import 'core/data/datasources/datasource_interface.dart';
import 'core/mock/mock_service.dart';
import 'core/mock/mock_trip_datasource.dart';
import 'core/mock/mock_wallet_datasource.dart';
import 'core/network/network_info.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/booking/data/repositories/trip_repository_impl.dart';
import 'features/booking/domain/repositories/trip_repository.dart';
import 'features/booking/presentation/bloc/trip_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  debugPrint('[DI] Starting dependency initialization...');

  // Initialize environment
  debugPrint('[DI] Initializing environment...');
  await Environment.initialize();
  debugPrint('[DI] Environment initialized. Mode: ${Environment.isMock ? "MOCK" : Environment.isFirebase ? "FIREBASE" : "REST"}');

  // External dependencies
  debugPrint('[DI] Initializing external dependencies...');
  await _initExternalDependencies();
  debugPrint('[DI] External dependencies initialized');

  // Core
  debugPrint('[DI] Initializing core services...');
  await _initCore();
  debugPrint('[DI] Core services initialized');

  // Data sources
  debugPrint('[DI] Initializing data sources...');
  await _initDataSources();
  debugPrint('[DI] Data sources initialized');

  // Repositories
  debugPrint('[DI] Initializing repositories...');
  await _initRepositories();
  debugPrint('[DI] Repositories initialized');

  // Blocs
  debugPrint('[DI] Initializing blocs...');
  await _initBlocs();
  debugPrint('[DI] All dependencies initialized successfully!');
}

/// Initialize external dependencies (packages)
Future<void> _initExternalDependencies() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Firebase (only if using Firebase backend)
  if (Environment.isFirebase) {
    // Firebase initialization moved to firebase_initializer.dart
    // This requires proper firebase_options.dart configuration
    debugPrint('[DI] Firebase mode selected but Firebase initialization skipped for now');
    debugPrint('[DI] To use Firebase, configure firebase_options.dart and uncomment initialization');
  }

  // Mock service (for testing without Firebase)
  if (Environment.isMock) {
    sl.registerLazySingleton<MockService>(() => MockService.instance);
    sl.registerLazySingleton<MockTripDataSource>(() => MockService.instance.trips);
    sl.registerLazySingleton<MockWalletDataSource>(() => MockService.instance.wallet);
  }
}

/// Initialize core services
Future<void> _initCore() async {
  // Network info
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
}

/// Initialize data sources
Future<void> _initDataSources() async {
  // For now, always use mock data sources for testing
  // When Firebase is properly configured, this can be updated
  if (!sl.isRegistered<MockService>()) {
    sl.registerLazySingleton<MockService>(() => MockService.instance);
    sl.registerLazySingleton<MockTripDataSource>(() => MockService.instance.trips);
    sl.registerLazySingleton<MockWalletDataSource>(() => MockService.instance.wallet);
  }

  await _initMockDataSources();

  // Local data sources (always needed)
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

/// Initialize Mock data sources (for testing without Firebase)
Future<void> _initMockDataSources() async {
  sl.registerLazySingleton<AuthDataSource>(
    () => MockService.instance.auth,
  );
  // MockTripDataSource and MockWalletDataSource are already registered
  // in _initExternalDependencies when in mock mode
}

/// Initialize Firebase data sources
Future<void> _initFirebaseDataSources() async {
  // Firebase data sources require Firebase to be properly configured
  // For now, fall back to mock mode if Firebase is not available
  debugPrint('[DI] Firebase data sources not available, using mock instead');
  await _initMockDataSources();
}

/// Initialize REST API data sources (for future migration)
Future<void> _initRestDataSources() async {
  // TODO: Implement REST data sources when needed
  // sl.registerLazySingleton<ApiClient>(() => ApiClient(baseUrl: Environment.apiBaseUrl));
  // sl.registerLazySingleton<AuthDataSource>(() => RestAuthDataSource(client: sl()));
}

/// Initialize repositories
Future<void> _initRepositories() async {
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(
      // tripDataSource: sl(),
      // locationDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // TODO: Add more repositories
  // sl.registerLazySingleton<WalletRepository>(() => WalletRepositoryImpl(...));
  // sl.registerLazySingleton<LocationRepository>(() => LocationRepositoryImpl(...));
}

/// Initialize Blocs
Future<void> _initBlocs() async {
  // Auth Bloc - singleton (app-wide authentication state)
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(authRepository: sl()),
  );

  // Trip Bloc - factory (new instance per screen)
  sl.registerFactory<TripBloc>(
    () => TripBloc(tripRepository: sl()),
  );

  // TODO: Add more blocs
  // sl.registerFactory<WalletBloc>(() => WalletBloc(walletRepository: sl()));
  // sl.registerFactory<LocationBloc>(() => LocationBloc(locationRepository: sl()));
}

/// Reset dependencies (for testing or logout)
Future<void> resetDependencies() async {
  await sl.reset();
  await initDependencies();
}
