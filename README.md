# openfootball

A Flutter api client for [Open Football Data](https://github.com/openfootball/football.json).

This package contains a high-level client to fetch data from HTTP resources.

## Using

Fetch clubs from Europe Champions League season 2019-2020: 
```dart
import 'package:openfootball/openfootball.dart';

final championsLeague = 'cl';
final client = JsonClient(league: championsLeague, season: '2019-20');
final clubs = await client.clubs();
print('Number of clubs: ${clubs.length}');
print('First club: ${clubs.first}');
```

Output
```
flutter: Number of clubs: 32
flutter: First club: Club(name: FC RB Salzburg, code: RBS, country: Austria)
```

Fetch groups:
```dart
final groups = await client.groups();
print('Number of groups: ${groups.length}');
print('First group: ${groups.first}')
```

Output
```
flutter: Number of groups: 8
flutter: First group: Group(name: Group A, teams: [Real Madrid, Paris Saint-Germain, Galatasaray İstanbul AŞ, Club Brugge])
```

Fetch rounds:
```dart
final rounds = await client.rounds();
print('Number of rounds: ${rounds.length}');
print('First round: ${rounds.first.name}');
print('Number of matches on first round: ${rounds.first.matches.length}');
```

Output:
```
flutter: Number of rounds: 7
flutter: First round: Matchday 1
flutter: Number of matches on first round: 16
```

Fetch matches:
```dart
final matches = await client.matches();
print('Number of matches: ${matches.length}');
print('First match: ${matches.first}');
```

Output
```
flutter: Number of matches: 112
flutter: First match: Match(date: 2019-09-18 00:00:00.000, team1: Club Brugge, team2: Galatasaray İstanbul AŞ, group: Group A, score1: 0, score2: 0)
```

Put everything together:
```dart
final competition = await client.competition();
print('Competition name: ${competition.name}');
print('Number of clubs: ${competition.clubs.length}');
print('Number of groups: ${competition.groups.length}');
print('Number of rounds: ${competition.rounds.length}');
print('Number of matches: ${competition.matches.length}');
```

Output
```
flutter: Competition name: Champions League 2019/20
flutter: Number of clubs: 32
flutter: Number of groups: 8
flutter: Number of rounds: 7
flutter: Number of matches: 112
```