class Message {
  Message({
    required this.msg,
    required this.formid,
    required this.read,
    required this.told,
    required this.type,
    required this.sent,
  });
  late String msg;
  late String formid;
  late String read;
  late String told;
  late Type type;
  late String sent;

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'];
    formid = json['formid'];
    read = json['read'];
    told = json['told'];
    type = json['type'] == Type.image.name ? Type.image : Type.text;
    sent = json['sent'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['formid'] = formid;
    data['read'] = read;
    data['told'] = told;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
