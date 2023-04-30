import 'dart:convert';

AppInfo appInformationFromJson(String str) => AppInfo.fromJson(json.decode(str));

class AppInfo {
    AppInfo({
        required this.name,
        required this.version,
        required this.status,
        required this.alert,
    });

    String name;
    int version;
    String status;
    Alert alert;

    factory AppInfo.fromJson(Map<String, dynamic> json) => AppInfo(
        name: json["name"],
        version: json["version"],
        status: json["status"],
        alert: Alert.fromJson(json["alert"]),
    );
}

class Alert {
    Alert({
        required this.title,
        required this.content,
        required this.status,
        required this.link,
    });

    String title;
    String content;
    int status;
    String link;

    factory Alert.fromJson(Map<String, dynamic> json) => Alert(
        title: json["title"],
        content: json["content"],
        status: json["status"],
        link: json["link"],
    );
}
