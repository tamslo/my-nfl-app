import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_nfl_app/src/season/season.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _seasonCacheKey = 'seasonCache';

Future<Season> _loadFullSeasonData() async {
  // If not cached, should get season info from
  // https://sports.core.api.espn.com/v2/sports/football/leagues/nfl/season
  // Should get types info from all items in
  // http://sports.core.api.espn.com/v2/sports/football/leagues/nfl/seasons/2024/types
    // Get all current weeks of current type
    // http://sports.core.api.espn.com/v2/sports/football/leagues/nfl/seasons/2024/types/3/weeks
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
    lastUpdated: DateTime.now(),
    weeks: weeks,
  );
}

Future<Season> _updateSeasonData(String cachedSeasonData) async {
  final cachedSeason = Season.fromJson(jsonDecode(cachedSeasonData));
  // May want to update cached week information, depending on last fetch date
  // and last game date
  return _loadFullSeasonData();
}

Future<Season> getSeasonData() async {
  final sharedPreferences = SharedPreferencesAsync();
  final cachedSeasonData = await sharedPreferences.getString(_seasonCacheKey);
  final season = cachedSeasonData == null
    ? await _loadFullSeasonData()
    : await _updateSeasonData(cachedSeasonData);
  await sharedPreferences.setString(
    _seasonCacheKey,
    jsonEncode(season.toJson()),
  );
  return season;
}