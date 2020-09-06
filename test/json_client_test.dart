import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:openfootball/json_client.dart';
import 'package:openfootball/models/club.dart';
import 'package:openfootball/models/competition.dart';
import 'package:openfootball/models/group.dart';
import 'package:openfootball/models/round.dart';
import 'package:openfootball/models/match.dart';

import 'fixture.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  final String baseUrl = 'https://test.local/';
  final String league = 'cl';
  final String season = '2019-2020';

  // https://stackoverflow.com/questions/61345133/flutter-unittestinvalid-argument-string-contains-invalid-characters
  final headers = {
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8'
  };

  JsonClient buildClient(MockClient mockClient) => JsonClient(
      league: league, season: season, baseUrl: baseUrl, client: mockClient);

  MockClient withClubsMock({MockClient mockClient, int statusCode = 200}) {
    mockClient = mockClient ?? MockClient();
    when(mockClient.get('$baseUrl/$season/$league.clubs.json'))
        .thenAnswer((_) async => http.Response(
              statusCode == 200 ? fixture('cl.clubs.json') : '{}',
              statusCode,
              headers: headers,
            ));
    return mockClient;
  }

  MockClient withGroupsMock({MockClient mockClient, statusCode = 200}) {
    mockClient = mockClient ?? MockClient();
    when(mockClient.get('$baseUrl/$season/$league.groups.json'))
        .thenAnswer((_) async => http.Response(
              statusCode == 200 ? fixture('cl.groups.json') : '{}',
              statusCode,
              headers: headers,
            ));
    return mockClient;
  }

  MockClient withRoundsMock({MockClient mockClient, statusCode = 200}) {
    mockClient = mockClient ?? MockClient();
    when(mockClient.get('$baseUrl/$season/$league.json'))
        .thenAnswer((_) async => http.Response(
              statusCode == 200 ? fixture('cl.json') : '{}',
              statusCode,
              headers: headers,
            ));
    return mockClient;
  }

  group('clubs', () {
    test('fetch clubs with success', () async {
      final jsonClient = buildClient(withClubsMock());
      List<Club> clubs = await jsonClient.clubs();
      expect(clubs.length, 32);
      expect(
          clubs.first,
          Club(
            name: 'FC RB Salzburg',
            code: 'RBS',
            country: 'Austria',
          ));
    });

    test('throws an exception on fetch clubs with error', () {
      final jsonClient = buildClient(withClubsMock(statusCode: 404));
      expect(jsonClient.clubs(), throwsException);
    });
  });

  group('groups', () {
    test('fetch with success', () async {
      final jsonClient = buildClient(withGroupsMock());
      List<Group> groups = await jsonClient.groups();
      expect(groups.length, 8);
      expect(
          groups.first,
          Group(
            name: 'Group A',
            teams: [
              "Real Madrid",
              "Paris Saint-Germain",
              "Galatasaray İstanbul AŞ",
              "Club Brugge"
            ],
          ));
    });

    test('throws an exception on fetch with error', () {
      final jsonClient = buildClient(withGroupsMock(statusCode: 404));
      expect(jsonClient.groups(), throwsException);
    });
  });

  group('rounds', () {
    test('fetch with success', () async {
      final jsonClient = buildClient(withRoundsMock());
      List<Round> rounds = await jsonClient.rounds();
      expect(rounds.length, 7);
      expect(rounds.first.name, 'Matchday 1');
      expect(rounds.first.matches.length, 16);
    });

    test('throws an exception on fetch with error', () {
      final jsonClient = buildClient(withRoundsMock(statusCode: 404));
      expect(jsonClient.rounds(), throwsException);
    });
  });

  group('matches', () {
    test('fetch with success', () async {
      final jsonClient = buildClient(withRoundsMock());
      List<Match> matches = await jsonClient.matches();
      expect(matches.length, 112);
      expect(
          matches.first,
          Match(
            date: DateTime.tryParse('2019-09-18'),
            team1: 'Club Brugge',
            team2: 'Galatasaray İstanbul AŞ',
            score1: 0,
            score2: 0,
            group: 'Group A',
          ));
    });

    test('throws an exception on fetch with error', () {
      final jsonClient = buildClient(withRoundsMock(statusCode: 404));
      expect(jsonClient.matches(), throwsException);
    });
  });

  group('competition', () {
    test('fetch with success', () async {
      final mockClient = MockClient();
      withRoundsMock(mockClient: mockClient);
      withGroupsMock(mockClient: mockClient);
      withClubsMock(mockClient: mockClient);
      final jsonClient = buildClient(mockClient);

      Competition competition = await jsonClient.competition();
      expect(competition.name, 'Champions League 2019/20');
      expect(competition.groups.length, 8);
      expect(competition.rounds.length, 7);
      expect(competition.clubs.length, 32);
      expect(competition.matches().length, 112);
    });

    test('throws an exception on fetch with error', () {
      final jsonClient = buildClient(withRoundsMock(statusCode: 404));
      expect(jsonClient.competition(), throwsException);
    });
  });
}
