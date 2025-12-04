import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'injection_container.dart';

/// Main application widget
class RideShareGoApp extends StatefulWidget {
  const RideShareGoApp({super.key});

  @override
  State<RideShareGoApp> createState() => _RideShareGoAppState();
}

class _RideShareGoAppState extends State<RideShareGoApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    debugPrint('[App] initState called');
    _appRouter = AppRouter();
    debugPrint('[App] AppRouter created');

    // Check authentication status on app start
    debugPrint('[App] Dispatching AuthCheckRequested');
    sl<AuthBloc>().add(const AuthCheckRequested());
    debugPrint('[App] AuthCheckRequested dispatched');
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: sl<AuthBloc>()),
      ],
      child: MaterialApp.router(
        title: 'RideShareGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.router,
        builder: (context, child) {
          return MediaQuery(
            // Prevent text scaling from breaking layouts
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
