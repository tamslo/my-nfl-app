import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:my_nfl_app/src/season/season.dart';
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
              padding: const EdgeInsets.all(6.0),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(week.title),
                  initiallyExpanded: week.hasUpdates,
                  children: week.content.map(
                    (item) => _buildContentItem(context, item)
                  ).toList(),
                ),
              ),
            ),
          )),
        ];
    final List<Widget> listItems = [
      Text(season.year.toString()),
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
        padding: const EdgeInsets.all(6.0),
        child: ListView.builder(
            restorationId: 'SeasonView',
            itemCount: listItems.length,
            itemBuilder: (BuildContext context, int index) => listItems[index],
          ),
        )
    );
  }

  Widget _buildContentItem(BuildContext context, WeekContent item) {
    if (item is LinkWeekContent) {
      return TextButton.icon(
        onPressed: () => item.value != null
          ? launchUrl(Uri.parse(item.value!))
          : null,
        icon: Icon(item.icon),
        label: Text(item.getLabel(context)),
      );
    }
    return Text(item.value!);
  }
}
