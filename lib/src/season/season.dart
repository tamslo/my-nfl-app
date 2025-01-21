import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

part 'season.g.dart';

final Map<int, String> seasonTypes = {
  1: 'Preseason',
  2: 'Regular season',
  3: 'Postseason',
};

@JsonSerializable(explicitToJson: true)
class Season {
  const Season({
    required this.year,
    this.weeks,
  });
  final int year;
  final List<Week>? weeks;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
  Map<String, dynamic> toJson() => _$SeasonToJson(this);

}

@JsonSerializable(explicitToJson: true)
class Week {
  Week({
    required this.seasonType,
    required this.number,
    required this.games,
    this.videos,
    this.hasUpdates = false,
  });

  final int seasonType;
  final int number;
  @JsonKey(includeToJson: false)
  @JsonKey(includeFromJson: false)
  final bool hasUpdates;
  final List<Game> games;
  final List<Video>? videos;

  factory Week.fromJson(Map<String, dynamic> json) => _$WeekFromJson(json);
  Map<String, dynamic> toJson() => _$WeekToJson(this);

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
@JsonSerializable(explicitToJson: true)
class Game {
  Game({
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    this.score,
    this.video,
  });

  factory Game.fromJson(Map<String, dynamic> json) =>
    _$GameFromJson(json);
  Map<String, dynamic> toJson() => _$GameToJson(this);

  final String homeTeam;
  final String awayTeam;
  final String date;
  final String? score;
  final Video? video;
}

@JsonSerializable()
class Video {
  Video({
    required this.name,
    required this.url,
  });

  factory Video.fromJson(Map<String, dynamic> json) =>
    _$VideoFromJson(json);
  Map<String, dynamic> toJson() => _$VideoToJson(this);

  final String name;
  final Uri url;
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
    // Should add game infos here
    games: [],
  );
  // This will be fixed once stuff is more generic for cache
  final tempLastWeek = Week(
    seasonType: seasonType,
    number: weekNumber - 1,
    hasUpdates: true,
    // Should add game infos here
    games: [],
  );
  // If regular season, also add "NFL: every week y highlight!" to links
  final weeks = weekNumber > 1
    ? [
        Week(
          seasonType: seasonType,
          number: weekNumber - 1,
          hasUpdates: true,
          // Should add game infos here
          games: [],
          videos: [
            Video(
              url: Uri.parse(
                'https://m.youtube.com/results?search_query=Tom+Grossi+If+the+NFL+was+scripted+${tempLastWeek.title}'
              ),
              name: 'Scripted',
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