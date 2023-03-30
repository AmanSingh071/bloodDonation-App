class Chatuser {
  Chatuser({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.lastActive,
    required this.id,
    required this.isOnline,
    required this.pushToken,
    required this.email,
    required this.latitute,
    required this.longitude,
  });
  late String image;
  late String name;
  late String about;
  late String createdAt;
  late String lastActive;
  late String id;
  late bool isOnline;
  late String pushToken;
  late String email;
  late String latitute;
  late String longitude;

  Chatuser.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    createdAt = json['created_at'] ?? '';
    lastActive = json['last_active'] ?? '';
    id = json['id'] ?? '';
    isOnline = json['is_online'] ?? '';
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
    latitute = json['latitute'] ?? '';
    longitude = json['longitude'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['last_active'] = lastActive;
    data['id'] = id;
    data['is_online'] = isOnline;
    data['push_token'] = pushToken;
    data['email'] = email;
    data['latitute'] = latitute;
    data['longitude'] = longitude;
    return data;
  }
}
