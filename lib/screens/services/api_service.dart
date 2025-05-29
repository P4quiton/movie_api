import 'dart:convert';
import 'package:http/http.dart' as http;
import '/../constants.dart';

class ApiService {
  Future<List<dynamic>> fetchMovies() async {
    final url = Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&page=1');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Error al cargar películas');
    }
  }

  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar detalles de la película');
    }
  }

  Future<List<dynamic>> fetchMovieCredits(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId/credits?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['cast'];
    } else {
      throw Exception('Error al cargar los créditos');
    }
  }

  Future<List<dynamic>> fetchMovieVideos(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Filtra para obtener solo videos relevantes, como trailers
      return data['results']
          .where((video) => video['type'] == 'Trailer' && video['site'] == 'YouTube')
          .toList();
    } else {
      throw Exception('Error al cargar videos');
    }
  }

  Future<List<dynamic>> fetchMoviesByIds(List<int> movieIds) async {
    final List<dynamic> movies = [];

    for (var id in movieIds) {
      final url = Uri.parse('$baseUrl/movie/$id?api_key=$apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        movies.add(json.decode(response.body));
      } else {
        throw Exception('Error al cargar película con ID $id');
      }
    }

    return movies;
  }
}
