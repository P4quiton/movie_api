import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import './services/api_service.dart';
import 'movie_details_screen.dart';
import './favorite_movies.dart';
import './services/favorites_service.dart';

class MovieList extends StatefulWidget {
  const MovieList({super.key});

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas Populares'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchMovies(),
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
            return ListView.separated(
              itemCount: movies.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                final movie = movies[index];
                final imageUrl = movie['poster_path'] != null
                    ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                    : 'https://via.placeholder.com/500x750?text=No+Image';

                return ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 75,
                    ),
                  ),
                  title: Text(
                    movie['title'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Calificación: ${(movie['vote_average'] / 2).toStringAsFixed(1)} / 5',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      RatingBarIndicator(
                        rating: (movie['vote_average'] / 2),
                        itemCount: 5,
                        itemSize: 16.0,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  trailing: FavoriteButton(movieId: movie['id']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetails(movieId: movie['id']),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final int movieId;

  const FavoriteButton({super.key, required this.movieId});

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = FavoritesService.isFavorite(widget.movieId);
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      FavoritesService.toggleFavorite(widget.movieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: Colors.red,
      ),
      onPressed: _toggleFavorite,
    );
  }
}
