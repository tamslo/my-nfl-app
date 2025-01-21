// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Season _$SeasonFromJson(Map<String, dynamic> json) => Season(
      year: (json['year'] as num).toInt(),
      weeks: (json['weeks'] as List<dynamic>?)
          ?.map((e) => Week.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SeasonToJson(Season instance) => <String, dynamic>{
      'year': instance.year,
      'weeks': instance.weeks?.map((e) => e.toJson()).toList(),
    };

Week _$WeekFromJson(Map<String, dynamic> json) => Week(
      seasonType: (json['seasonType'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      games: (json['games'] as List<dynamic>)
          .map((e) => Game.fromJson(e as Map<String, dynamic>))
          .toList(),
      videos: (json['videos'] as List<dynamic>?)
          ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasUpdates: json['hasUpdates'] as bool? ?? false,
    );

Map<String, dynamic> _$WeekToJson(Week instance) => <String, dynamic>{
      'seasonType': instance.seasonType,
      'number': instance.number,
      'games': instance.games.map((e) => e.toJson()).toList(),
      'videos': instance.videos?.map((e) => e.toJson()).toList(),
    };

Game _$GameFromJson(Map<String, dynamic> json) => Game(
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      date: json['date'] as String,
      score: json['score'] as String?,
      video: json['video'] == null
          ? null
          : Video.fromJson(json['video'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
      'homeTeam': instance.homeTeam,
      'awayTeam': instance.awayTeam,
      'date': instance.date,
      'score': instance.score,
      'video': instance.video?.toJson(),
    };

Video _$VideoFromJson(Map<String, dynamic> json) => Video(
      name: json['name'] as String,
      url: Uri.parse(json['url'] as String),
    );

Map<String, dynamic> _$VideoToJson(Video instance) => <String, dynamic>{
      'name': instance.name,
      'url': instance.url.toString(),
    };
