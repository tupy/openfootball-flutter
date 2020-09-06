import 'package:openfootball/openfootball.dart';

void main(List<String> args) async {
  final championsLeague = 'cl';
  final client = JsonClient(league: championsLeague, season: '2019-20');
  // clubs
  final clubs = await client.clubs();
  print('Number of clubs: ${clubs.length}');
  print('First club: ${clubs.first}');

  // groups
  final groups = await client.groups();
  print('Number of groups: ${groups.length}');
  print('First group: ${groups.first}');

  // rounds
  final rounds = await client.rounds();
  print('Number of rounds: ${rounds.length}');
  print('First round: ${rounds.first.name}');
  print('Number of matches on first round: ${rounds.first.matches.length}');

  // matches
  final matches = await client.matches();
  print('Number of matches: ${matches.length}');
  print('First match: ${matches.first}');

  // competition
  final competition = await client.competition();
  print('Competition name: ${competition.name}');
  print('Number of clubs: ${competition.clubs.length}');
  print('Number of groups: ${competition.groups.length}');
  print('Number of rounds: ${competition.rounds.length}');
  print('Number of matches: ${competition.matches.length}');
}
