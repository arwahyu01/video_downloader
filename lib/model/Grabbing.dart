import 'dart:convert';

List<Grabbing> grabbingFromJson(String str) => List<Grabbing>.from(json.decode(str).map((x) => Grabbing.fromJson(x)));

class Grabbing {
  String url;
  String title;
  String image;

  Grabbing({
    required this.url,
    required this.title,
    required this.image,
  });

  factory Grabbing.fromJson(Map<String, dynamic> json) => Grabbing(
        url: json["url"],
        title: json["title"],
        image: json["image"],
      );
}
