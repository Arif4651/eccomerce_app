import 'package:ecommerce_app/model/model.dart';
import 'package:http/http.dart' as http;

import '../model/model.dart';

class services {
  Future<List<ProductElement>?> getpost() async {
    var client = http.Client();

    var response = await client.get(
      Uri.parse("https://fakestoreapi.in/api/products"),
    );
    if (response.statusCode == 200) {
      var json = response.body;
      return productFromJson(json).products;
    } else {
      print('Error :${response.body}');
    }

    return null;
  }
}
