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
    required this.lastUpdated,
    this.weeks,
  });
  final int year;
  final DateTime lastUpdated;
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

  bool get isPreseason => seasonType == 1;  
  bool get isRegularSeason => seasonType == 2;
  bool get isPostseason => seasonType == 3;
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
