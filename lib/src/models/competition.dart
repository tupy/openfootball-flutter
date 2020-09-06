import 'package:meta/meta.dart';

import 'group.dart';
import 'round.dart';
import 'club.dart';
import 'match.dart';

@immutable
class Competition {
  final String name;
  final List<Club> clubs;
  final List<Group> groups;
  final List<Round> rounds;

  Competition({
    @required this.name,
    this.clubs = const [],
    this.groups = const [],
    this.rounds = const [],
  }) : assert(name != null && name.isNotEmpty);

  @override
  String toString() {
    return 'Competition(name: $name, clubs: ${clubs.map((e) => e.name)}, groups: ${groups.length}, rounds: ${rounds.length}})';
  }

  List<Match> get matches {
    return rounds
        .map((round) => round.matches)
        .expand((i) => i) // flatten
        .toList();
  }
}
