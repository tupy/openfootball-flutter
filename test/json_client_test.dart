import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'package:openfootball/src/json_client.dart';
import 'package:openfootball/src/models/club.dart';
import 'package:openfootball/src/models/group.dart';
import 'package:openfootball/src/models/match.dart';

import './fixture.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  final baseUrl = 'https://test.local/';
  final league = 'cl';
  final season = '2019-2020';

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
              statusCode == 200 ? fixture('cl.rounds.json') : '{}',
              statusCode,
              headers: headers,
            ));
    return mockClient;
  }

  MockClient withMatchesMock({MockClient mockClient, statusCode = 200}) {
    mockClient = mockClient ?? MockClient();
    when(mockClient.get('$baseUrl/$season/$league.json'))
        .thenAnswer((_) async => http.Response(
              statusCode == 200 ? fixture('cl.matches.json') : '{}',
              statusCode,
              headers: headers,
            ));
    return mockClient;
  }

  test('assert invalid parameters', () {
    expect(
      () => JsonClient(league: league, season: null),
      throwsAssertionError,
    );
    expect(
      () => JsonClient(league: null, season: season),
      throwsAssertionError,
    );
    expect(
      () => JsonClient(league: league, season: season, baseUrl: null),
      throwsAssertionError,
    );
  });

  group('clubs', () {
    test('fetch clubs with success', () async {
      var jsonClient = buildClient(withClubsMock());
      var clubs = await jsonClient.clubs();
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
      var jsonClient = buildClient(withClubsMock(statusCode: 404));
      expect(jsonClient.clubs(), throwsException);
    });
  });

  group('groups', () {
    test('fetch with success', () async {
      var jsonClient = buildClient(withGroupsMock());
      var groups = await jsonClient.groups();
      expect(groups.length, 8);
      expect(
          groups.first,
          Group(
            name: 'Group A',
            teams: [
              'Real Madrid',
              'Paris Saint-Germain',
              'Galatasaray İstanbul AŞ',
              'Club Brugge'
            ],
          ));
    });

    test('throws an exception on fetch with error', () {
      var jsonClient = buildClient(withGroupsMock(statusCode: 404));
      expect(jsonClient.groups(), throwsException);
    });
  });

  group('rounds', () {
    test('fetch with success', () async {
      var jsonClient = buildClient(withRoundsMock());
      var rounds = await jsonClient.rounds();
      expect(rounds.length, 7);
      expect(rounds.first.name, 'Matchday 1');
      expect(rounds.first.matches.length, 16);
    });

    test('from matches with success', () async {
      var jsonClient = buildClient(withMatchesMock());
      var rounds = await jsonClient.rounds();
      expect(rounds.length, 7);
      expect(rounds.first.name, 'Round of 16');
      expect(rounds.first.matches.length, 15);
    });

    test('throws an exception on fetch with error', () {
      var jsonClient = buildClient(withRoundsMock(statusCode: 404));
      expect(jsonClient.rounds(), throwsException);
    });
  });

  group('matches', () {
    test('fetch with success', () async {
      var jsonClient = buildClient(withMatchesMock());
      var matches = await jsonClient.matches();
      expect(matches.length, 112);
      expect(
          matches.first,
          Match(
            date: DateTime.tryParse('2020-02-18'),
            round: 'Round of 16',
            team1: 'Borussia Dortmund',
            team2: 'Paris Saint-Germain',
            score1: 2,
            score2: 1,
            group: null,
          ));
      expect(matches.first.round, 'Round of 16');
    });

    test('from rounds with success', () async {
      var jsonClient = buildClient(withRoundsMock());
      var matches = await jsonClient.matches();
      expect(matches.length, 112);
      expect(
          matches.first,
          Match(
            date: DateTime.tryParse('2019-09-18'),
            round: null,
            team1: 'Club Brugge',
            team2: 'Galatasaray İstanbul AŞ',
            score1: 0,
            score2: 0,
            group: 'Group A',
          ));
      expect(matches.first.round, null);
    });

    test('throws an exception on fetch with error', () {
      var jsonClient = buildClient(withRoundsMock(statusCode: 404));
      expect(jsonClient.matches(), throwsException);
    });
  });

  group('competition', () {
    test('fetch with success', () async {
      var mockClient = MockClient();
      withRoundsMock(mockClient: mockClient);
      withGroupsMock(mockClient: mockClient);
      withClubsMock(mockClient: mockClient);
      var jsonClient = buildClient(mockClient);

      var competition = await jsonClient.competition();
      expect(competition.name, 'Champions League 2019/20');
      expect(competition.groups.length, 8);
      expect(competition.rounds.length, 7);
      expect(competition.clubs.length, 32);
      expect(competition.matches.length, 112);
    });

    test('throws an exception on fetch with error', () {
      var jsonClient = buildClient(withRoundsMock(statusCode: 404));
      expect(jsonClient.competition(), throwsException);
    });
  });
}
