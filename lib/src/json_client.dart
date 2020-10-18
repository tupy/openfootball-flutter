import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

import 'api.dart';
import 'models/club.dart';
import 'models/group.dart';
import 'models/match.dart';
import 'models/competition.dart';
import 'models/round.dart';

class JsonClient implements OpenFootballAPI {
  static const String GITHUB_URL =
      'https://raw.githubusercontent.com/openfootball/football.json/master';
  final String baseUrl;
  final String league;
  final String season;
  http.Client client;

  JsonClient({
    @required this.league,
    @required this.season,
    this.client,
    this.baseUrl = GITHUB_URL,
  })  : assert(league != null),
        assert(season != null),
        assert(baseUrl != null) {
    client = client ?? http.Client();
  }

  @override
  Future<List<Club>> clubs() async {
    final response = await client.get('$baseUrl/$season/$league.clubs.json');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> jClubs = data['clubs'];
      return jClubs.map((jClub) => Club.fromMap(jClub)).toList();
    } else {
      throw Exception('Failed to load clubs: ${response.body}');
    }
  }

  @override
  Future<List<Group>> groups() async {
    final response = await client.get('$baseUrl/$season/$league.groups.json');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> jGroups = data['groups'];
      return jGroups.map((jGroup) => Group.fromMap(jGroup)).toList();
    } else {
      throw Exception('Failed to load groups: ${response.body}');
    }
  }

  @override
  Future<Competition> competition() async {
    final response = await client.get('$baseUrl/$season/$league.json');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rounds = data.containsKey('rounds')
          ? _parseRounds(data['rounds'])
          : data.containsKey('matches')
              ? _roundsFromMatches(data['matches'])
              : <Round>[];
      return Competition(
        name: data['name'],
        clubs: await clubs(),
        groups: await groups(),
        rounds: rounds,
      );
    } else {
      throw Exception('Failed to load rounds: ${response.body}');
    }
  }

  @override
  Future<List<Round>> rounds() async {
    final response = await client.get('$baseUrl/$season/$league.json');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('rounds')) {
        return _parseRounds(data['rounds']);
      } else if (data.containsKey('matches')) {}
      return _roundsFromMatches(data['matches']);
    } else {
      throw Exception('Failed to load rounds');
    }
  }

  List<Round> _parseRounds(List<dynamic> jRounds) {
    return jRounds.map((jRound) => Round.fromMap(jRound)).toList();
  }

  List<Round> _roundsFromMatches(List<dynamic> jMatches) {
    final matches = _parseMatches(jMatches);
    final rounds = <String, Round>{};
    matches.forEach((match) {
      if (rounds.containsKey(match.round)) {
        rounds[match.round].matches.add(match);
      } else {
        rounds[match.round] = Round(name: match.round, matches: []);
      }
    });
    return rounds.values.toList();
  }

  @override
  Future<List<Match>> matches() async {
    final response = await client.get('$baseUrl/$season/$league.json');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data.containsKey('matches')
          ? _parseMatches(data['matches'])
          : data.containsKey('rounds')
              ? _matchesFromRounds(data['rounds'])
              : <Match>[];
    } else {
      throw Exception('Failed to load rounds');
    }
  }

  List<Match> _parseMatches(List<dynamic> jMatches) =>
      List<Match>.from(jMatches.map((x) => Match.fromMap(x)));

  List<Match> _matchesFromRounds(List<dynamic> jRounds) {
    final rounds = _parseRounds(jRounds);
    final matches = <Match>[];
    rounds.forEach((round) => matches.addAll(round.matches));
    return matches;
  }
}
