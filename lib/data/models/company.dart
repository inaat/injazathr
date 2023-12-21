class Company {
  Company({
    required this.id,
    required this.name,
    required this.url,
  });
  late final int id;
  late final String name;
  late final String url;

  Company.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    url = json['url'] ?? "";
  }
  // Map<String, dynamic> toJson() {
  //   final data = <String, dynamic>{};
  //   data['id'] = id;
  //   data['name'] = name;
  //   data['url'] = url;
  //   return data;
  // }
}
