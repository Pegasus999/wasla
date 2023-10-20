import 'package:html/dom.dart' as dom;
import 'package:http/http.dart' as http;

class Model {
  String name = "";
  String url = "";
  Model({required this.name, required this.url});

  Model.toModel(dom.Element element) {
    name = element.querySelector("h4")!.text;

    url = element.attributes['href']!;
  }

  Model.fromJson(Map<String, dynamic> json)
      : name = json['title'],
        url = json['url'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };
}
