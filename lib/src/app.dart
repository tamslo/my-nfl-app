import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_nfl_app/src/season/load_data.dart';
import 'package:my_nfl_app/src/season/season.dart';
import 'package:my_nfl_app/src/season/season_view.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class NflUpdatesApp extends StatefulWidget {
  const NflUpdatesApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  State<NflUpdatesApp> createState() => _NflUpdatesAppState();
}
class _NflUpdatesAppState extends State<NflUpdatesApp> {
  late Future<Season> futureSeason;

  @override
  void initState() {
    super.initState();
    futureSeason = getSeasonData();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return SettingsView(controller: widget.settingsController);
                  default:
                    return FutureBuilder<Season>(
                      future: futureSeason,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return SeasonView(season: snapshot.data!);
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      },
                    );
                }
              },
            );
          },
        );
      },
    );
  }
}
