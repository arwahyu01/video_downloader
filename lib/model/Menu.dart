import 'dart:convert';

List<Menu> menuFromJson(String str) => List<Menu>.from(json.decode(str).map((x) => Menu.fromJson(x)));

class Menu {

  Menu({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.url,
  });

  String title;
  String subtitle;
  String icon;
  String url;

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        title: json["title"],
        subtitle: json["subtitle"],
        icon: json["icon"],
        url: json["url"],
      );
}
