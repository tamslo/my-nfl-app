import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_nfl_app/src/season/season.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _seasonCacheKey = 'seasonCache';

Future<dynamic> _getData(String url) async {
  final response = await http.get(Uri.parse(url));
  final data = await json.decode(response.body);
  return data;
}

Future<dynamic> _getQueryData(String query) async {
  const baseUrl =
    'https://sports.core.api.espn.com/v2/sports/football/leagues/nfl';
  return _getData('$baseUrl/$query');
}

Uri _getYoutubeSearchLink(String query) => Uri.parse(
  'https://m.youtube.com/results?search_query='
  '${query.replaceAll(' ', '+')}'
);

Video _getWeekHighlightsVideo(String weekName) {
  return Video(
    name: 'All Highlights',
    url: _getYoutubeSearchLink('NFL Every $weekName Highlight!'),
  );
}

Video _getScriptedVideo(String weekName) {
  return Video(
    name: 'Scripted',
    url:_getYoutubeSearchLink('Tom Grossi If the NFL Was Scripted: $weekName'),
  );
}

Future<Season> _loadFullSeasonData() async {
  final currentDate = DateTime.now();
  final seasonData = await _getQueryData('season');
  final seasonYear = seasonData['year'];
  final seasonStart = DateTime.parse(seasonData['startDate']);
  if (seasonStart.isAfter(currentDate)) {
    return Season(year: seasonYear, lastUpdated: currentDate);
  }
  final typesUrlPrefix = 'seasons/$seasonYear/types';
  final seasonTypesRefs = await _getQueryData(typesUrlPrefix);
  final weeks = <Week>[];
  for (final seasonType in seasonTypesRefs['items']) {
    final seasonTypeData = await _getData(seasonType['\$ref']);
    final seasonTypeId = int.parse(seasonTypeData['id']);
    final weeksData = await _getQueryData('$typesUrlPrefix/$seasonTypeId/weeks');
    for (final weekData in weeksData['items']) {
      final weekInfo = await _getData(weekData['\$ref']);
      final weekName = weekInfo['text'];
      final games = <Game>[];
      // For event in 'events' ...
        // Not sure what makes sense in preseason
        // If regular season, should get game info of favorite team (SEA for now,
        // should be changeable in settings); add game with datetime and scores, if
        // present, and game highlight link, if done
        // If postseason, should get info of all games
      // Should use last game date here (week often longer)
      final weekEnd = DateTime.parse(weekInfo['endDate']);
      final videos = seasonTypeId == 1 || weekEnd.isAfter(currentDate)
        ? null
        : seasonTypeId == 2
          ? [
              _getWeekHighlightsVideo(weekName),
              _getScriptedVideo(weekName),
            ]
          : [_getScriptedVideo(weekName)];
      final week = Week(
        seasonType: seasonTypeId,
        number: weekInfo['number'],
        name: weekName,
        games: games,
        videos: videos,
      );
      weeks.add(week);
      if (weekEnd.isAfter(currentDate)) break;
    }
    final seasonTypeEnd = DateTime.parse(seasonTypeData['endDate']);
    if (seasonTypeEnd.isAfter(currentDate)) break;
  }
  return Season(year: seasonYear, lastUpdated: currentDate, weeks: weeks);
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