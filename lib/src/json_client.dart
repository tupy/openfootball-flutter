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
      return Competition(
        name: data['name'],
        clubs: await clubs(),
        groups: await groups(),
        rounds: _parseRounds(data['rounds']),
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
      return _parseRounds(data['rounds']);
    } else {
      throw Exception('Failed to load rounds');
    }
  }

  List<Round> _parseRounds(List<dynamic> jRounds) {
    return jRounds.map((jRound) => Round.fromMap(jRound)).toList();
  }

  @override
  Future<List<Match>> matches() async {
    return rounds().then((rounds) => rounds
        .map((round) => round.matches)
        .expand((i) => i) // flatten
        .toList());
  }
}
