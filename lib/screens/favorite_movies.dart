import 'dart:ui';
import 'package:flutter/material.dart';
import './services/favorites_service.dart';
import './services/api_service.dart';
import './movie_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteMovieIds = FavoritesService.getFavorites();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: favoriteMovieIds.isEmpty
          ? const Center(
              child: Text(
                'No tienes películas favoritas.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : FutureBuilder<List<dynamic>>(
              future: apiService.fetchMoviesByIds(favoriteMovieIds),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  final movies = snapshot.data!;
                  return Stack(
                    children: [
                      // Fondo difuminado del póster de la primera película
                      Positioned.fill(
                        child: Image.network(
                          movies.isNotEmpty
                              ? 'https://image.tmdb.org/t/p/w500${movies.first['poster_path']}'
                              : '',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(color: Colors.black.withOpacity(0.6)),
                        ),
                      ),
                      ListView.builder(
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                            child: Card(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              elevation: 8.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 250.0,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      movie['title'],
                                      style: const TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text(
                                      'Calificación: ${movie['vote_average']}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          FavoritesService.toggleFavorite(movie['id']);
                                        },
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => MovieDetails(movieId: movie['id']),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.amber[700]!, Colors.orange[600]!],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              bottomRight: Radius.circular(16),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                                          child: const Text(
                                            'Ver Detalles',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
    );
  }
}
