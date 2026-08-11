import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base del backend REST (ejemplo usando la API pública JSONPlaceholder)
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  // 1. Petición GET: Obtener el catálogo de productos desde el servidor
  static Future<List<dynamic>> obtenerProductos() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener productos del servidor');
    }
  }

  // 2. Petición POST: Enviar la orden realizada hacia la API REST
  static Future<bool> enviarPedido(Map<String, dynamic> datosPedido) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(datosPedido),
    );

    // Los códigos 200 o 201 indican que el servidor recibió la petición con éxito
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
