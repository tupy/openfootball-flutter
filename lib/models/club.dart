import 'dart:convert';

import 'package:meta/meta.dart';

/*
API: https://raw.githubusercontent.com/openfootball/football.json/master/2019-20/cl.clubs.json
Sample:
{
  "name": "FC RB Salzburg",
  "code": "RBS",
  "country": "Austria"
}
*/
@immutable
class Club {
  final String name;
  final String code;
  final String country;

  Club({
    this.name,
    this.code,
    this.country,
  });

  @override
  String toString() => 'Club(name: $name, code: $code, country: $country)';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'country': country,
    };
  }

  factory Club.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Club(
      name: map['name'],
      code: map['code'],
      country: map['country'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Club.fromJson(String source) => Club.fromMap(json.decode(source));

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Club &&
        o.name == name &&
        o.code == code &&
        o.country == country;
  }

  @override
  int get hashCode => name.hashCode ^ code.hashCode ^ country.hashCode;
}
