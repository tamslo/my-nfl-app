import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

final Map<int, String> seasonTypes = {
  1: 'Preseason',
  2: 'Regular season',
  3: 'Postseason',
};

class Season {
  const Season({
    required this.year,
    this.weeks,
  });
  final int year;
  final List<Week>? weeks;
}

class Week {
  Week({
    required this.seasonType,
    required this.number,
    required this.hasUpdates,
    required this.content,
  });

  final int seasonType;
  final int number;
  final bool hasUpdates;
  final List<WeekContent> content;

  String get title => seasonType == 1
    ? 'Preseason Week $number'
    : seasonType == 2
      ? 'Week $number'
      : number == 1
        ? 'Wild Card Weekend'
        : number == 2
          ? 'Divisional Round'
          : number == 3
            ? 'Conference Championships'
            : 'Super Bowl';
}

class WeekContent {
  WeekContent({required this.value});
  final String? value;
}

class LinkWeekContent extends WeekContent {
  LinkWeekContent({
    required super.value,
    required this.icon,
    required this.getLabel,
  });
  final IconData icon;
  final String Function(BuildContext) getLabel;
}

Future<Season> getSeasonData() async {
  // Should check whether data is cached in shared preferences (JSON string)
  // If data was fetched today, do not check for updates
  // If not cached, should get season info from
  // https://sports.core.api.espn.com/v2/sports/football/leagues/nfl/season
  // Should get types info from all items in
  // http://sports.core.api.espn.com/v2/sports/football/leagues/nfl/seasons/2024/types
    // Get all current weeks of current type
    // http://sports.core.api.espn.com/v2/sports/football/leagues/nfl/seasons/2024/types/3/weeks
    // May want to update information, depending on last fetch date
  // For now: just get current info and info of last week (limitation: if not
  // type change)
  const baseUrl =
    'https://sports.core.api.espn.com/v2/sports/football/leagues/nfl';
  const eventsUrl = '$baseUrl/events';
  final response = await http.get(Uri.parse(eventsUrl));
  final currentEvent = await json.decode(response.body);
  final metaInformation = currentEvent['\$meta']['parameters'];
  final seasonYear = int.parse(metaInformation['season'].first);
  final int seasonType = int.parse(metaInformation['seasontypes'].first);
  final int weekNumber = int.parse(metaInformation['week'].first);
  // If regular season, should get game info of favorite team (SEA for now,
  // should be changeable in settings); add game with datetime and scores, if
  // present, and game highlight link, if done
  // If postseason, should get info of all games
  // Not sure what makes sense in preseason
  // Should try to embed videos (not only create search string)
  // Should try to show table in app (I guess ESPN also has table data)
  final currentWeek = Week(
    seasonType: seasonType,
    number: weekNumber,
    hasUpdates: true,
    // If this is cached this should be more generic
    content: [
      LinkWeekContent(
        value: seasonType == 2
        // This should be dependent on favorite team
        ? 'https://www.google.com/search?q=NFL+NFC+West+Standings'
        : seasonType == 3
          ? 'https://www.google.com/search?q=NFL+Playoffs'
          : null,
        icon: FontAwesomeIcons.google,
        getLabel: (context) => AppLocalizations.of(context)!.viewStandings,
      ),
    ],
  );
  // This will be fixed once stuff is more generic for cache
  final tempLastWeek = Week(
    seasonType: seasonType,
    number: weekNumber - 1,
    hasUpdates: true,
    content: [],
  );
  // If regular season, also add "NFL: every week y highlight!" to links
  final weeks = weekNumber > 1
    ? [
        Week(
          seasonType: seasonType,
          number: weekNumber - 1,
          hasUpdates: true,
          content: [
            LinkWeekContent(
              value: 'https://m.youtube.com/results?search_query=Tom+Grossi+If+the+NFL+was+scripted+${tempLastWeek.title}',
              icon: FontAwesomeIcons.youtube,
              getLabel: (context) => AppLocalizations.of(context)!.watchScripted,
            ),
          ],
        ),
        currentWeek,
      ]
    : [currentWeek];
  return Season(
    year: seasonYear,
    weeks: weeks,
  );
  // Should overwrite cache with season as JSON and date of this data fetch
}