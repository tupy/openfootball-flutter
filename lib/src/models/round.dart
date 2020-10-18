import 'dart:convert';
import 'package:meta/meta.dart';

import './match.dart';

/*
API: https://raw.githubusercontent.com/openfootball/football.json/master/2019-20/cl.json
Sample:
{
  "name": "Matchday 1",
  "matches": [
    {
      "date": "2019-09-18",
      "team1": "Club Brugge",
      "team2": "Galatasaray İstanbul AŞ",
      "score": {
        "ft": [
          0,
          0
        ]
      },
      "group": "Group A"
    }
  ]
}
*/
@immutable
class Round {
  final String name;
  final List<Match> matches;

  Round({
    this.name,
    this.matches = const [],
  });

  @override
  String toString() => 'Round(name: $name, matches: $matches)';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'matches': matches?.map((x) => x?.toMap())?.toList(),
    };
  }

  factory Round.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Round(
      name: map['name'],
      matches: List<Match>.from(map['matches']?.map((x) => Match.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Round.fromJson(String source) => Round.fromMap(json.decode(source));
}
