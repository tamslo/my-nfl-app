import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_nfl_app/src/season/season.dart';
import 'package:my_nfl_app/theme.dart';
import 'package:url_launcher/url_launcher.dart';

import '../settings/settings_view.dart';

class SeasonView extends StatelessWidget {
  const SeasonView({
    super.key,
    required this.season,
  });

  final Season season;

  @override
  Widget build(BuildContext context) {
    final List<Widget> seasonContent = season.weeks == null
      ? [Text(AppLocalizations.of(context)!.noSeason)]
      : [
          ...season.weeks!.reversed.map((week) => Card(
            child: Padding(
              padding: const EdgeInsets.all(smallSpace),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(week.name),
                  initiallyExpanded: week.hasUpdates,
                  children: [
                    ...week.games?.map(
                      (game) => _buildGameInfo(context, game)
                    ) ?? [const SizedBox.shrink()],
                    ...week.videos?.map(
                      (video) => _buildVideo(context, video)
                    ) ?? [const SizedBox.shrink()],
                  ]
                ),
              ),
            ),
          )),
        ];
    final List<Widget> listItems = [
      Padding(
        padding: const EdgeInsets.only(bottom: mediumSpace),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.seasonTitle(season.year),
            style: const TextStyle(fontSize: headingSize),
          ),
        ),
      ),
      _maybeBuildStandingsLink(context, season.weeks?.last),
      ...seasonContent,
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(mediumSpace),
        child: ListView.builder(
            restorationId: 'SeasonView',
            itemCount: listItems.length,
            itemBuilder: (BuildContext context, int index) => listItems[index],
          ),
        )
    );
  }

  Widget _buildGameInfo(BuildContext context, Game game) {
    return Text('TODO: show game content for ${game.toJson()}');
  }

  Widget _buildVideo(BuildContext context, Video video) {
    return TextButton.icon(
      onPressed: () => launchUrl(video.url),
      icon: const Icon(FontAwesomeIcons.youtube),
      label: Text(AppLocalizations.of(context)!.watchVideo(video.name)),
    );
  }

  Widget _maybeBuildStandingsLink(BuildContext context, Week? lastWeek) {
    if (lastWeek == null) {
      return const SizedBox.shrink();
    }
    final link = lastWeek.isPreseason
      ? 'https://www.google.com/search?q=NFL+Preseason+News'
      : lastWeek.isRegularSeason
        // Division should be dependent on favorite team
        ? 'https://www.google.com/search?q=NFL+NFC+West+Standings'
        : 'https://www.google.com/search?q=NFL+Playoffs';
    return TextButton.icon(
      onPressed: () => launchUrl(Uri.parse(link)),
      icon: const Icon(FontAwesomeIcons.google),
      label: Text(AppLocalizations.of(context)!.viewStandings),
    );
  }
}
