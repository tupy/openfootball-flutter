import 'dart:convert';

import 'package:meta/meta.dart';

/*
API: https://raw.githubusercontent.com/openfootball/football.json/master/2019-20/cl.json
Sample:
{
  "date": "2019-09-18",
  "team1": "Club Brugge",
  "team2": "Galatasaray İstanbul AŞ",
  "score": {
    "ft": [0,0]
  },
  "group": "Group A"
}
*/
@immutable
class Match {
  final DateTime date;
  final String team1;
  final String team2;
  final String group;
  final int score1;
  final int score2;

  Match({
    this.date,
    this.team1,
    this.team2,
    this.group,
    this.score1,
    this.score2,
  });

  @override
  String toString() {
    return 'Match(date: $date, team1: $team1, team2: $team2, group: $group, score1: $score1, score2: $score2)';
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date?.millisecondsSinceEpoch,
      'team1': team1,
      'team2': team2,
      'group': group,
      'score': {
        'ft': [score1, score2]
      },
    };
  }

  factory Match.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Match(
      date: DateTime.tryParse(map['date']),
      team1: map['team1'],
      team2: map['team2'],
      group: map['group'],
      // FIXME
      score1: map.containsKey('score') ? map['score']['ft'][0] : null,
      score2: map.containsKey('score') ? map['score']['ft'][1] : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Match.fromJson(String source) => Match.fromMap(json.decode(source));

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Match &&
        o.date == date &&
        o.team1 == team1 &&
        o.team2 == team2 &&
        o.group == group;
    // o.score1 == score1 &&
    // o.score2 == score2;
  }

  @override
  int get hashCode {
    return date.hashCode ^ team1.hashCode ^ team2.hashCode ^ group.hashCode;
    // score1.hashCode ^
    // score2.hashCode;
  }
}
