class Skill {
  final String name;

  Skill({required this.name});

  Map<String, dynamic> toJson() {
    return {'skillName': name};
  }
}
