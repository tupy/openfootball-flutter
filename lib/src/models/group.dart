import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/*
API: https://raw.githubusercontent.com/openfootball/football.json/master/2019-20/cl.groups.json
Sample:
{
  "name": "Group A",
  "teams": [
    "Real Madrid",
    "Paris Saint-Germain",
    "Galatasaray İstanbul AŞ",
    "Club Brugge"
  ]
}
*/
@immutable
class Group {
  final String name;
  final List<String> teams;

  Group({
    this.name,
    this.teams,
  });

  @override
  String toString() => 'Group(name: $name, teams: $teams)';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teams': teams,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Group(
      name: map['name'],
      teams: List<String>.from(map['teams']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Group.fromJson(String source) => Group.fromMap(json.decode(source));

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Group && o.name == name && listEquals(o.teams, teams);
  }

  @override
  int get hashCode => name.hashCode ^ teams.hashCode;
}
