import 'models/club.dart';
import 'models/competition.dart';
import 'models/group.dart';
import 'models/round.dart';
import 'models/match.dart';

abstract class OpenFootballAPI {
  Future<List<Club>> clubs();
  Future<List<Group>> groups();
  Future<List<Round>> rounds();
  Future<Competition> competition();
  Future<List<Match>> matches();
}
