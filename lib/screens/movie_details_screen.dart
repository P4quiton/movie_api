import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import './services/api_service.dart';
import 'dart:ui';

class MovieDetails extends StatefulWidget {
  final int movieId;

  const MovieDetails({super.key, required this.movieId});

  @override
  _MovieDetailsState createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  late Future<Map<String, dynamic>> _movieDetails;
  late Future<List<dynamic>> _movieCredits;
  late Future<List<dynamic>> _movieTrailers;
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _movieDetails = ApiService().fetchMovieDetails(widget.movieId);
    _movieCredits = ApiService().fetchMovieCredits(widget.movieId);
    _movieTrailers = ApiService().fetchMovieVideos(widget.movieId);

    _youtubeController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la película'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error al cargar los detalles: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No se encontraron detalles.'));
          }

          final movie = snapshot.data!;
          return Stack(
            children: [
              // Fondo difuminado del póster
              Positioned.fill(
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cartel principal
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 250.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        movie['title'],
                        style: const TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha de estreno: ${movie['release_date']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Descripción:',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie['overview'] ?? 'No disponible.',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),

                      // Créditos (Reparto)
                      FutureBuilder<List<dynamic>>(
                        future: _movieCredits,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Error al cargar los créditos: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data == null) {
                            return const Center(
                                child: Text('No se encontraron créditos.'));
                          }

                          final credits = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Reparto:',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: credits.length,
                                  itemBuilder: (context, index) {
                                    final credit = credits[index];
                                    return Container(
                                      width: 120,
                                      margin: const EdgeInsets.only(right: 10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: credit['profile_path'] != null
                                                ? Image.network(
                                                    'https://image.tmdb.org/t/p/w500${credit['profile_path']}',
                                                    width: 80,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 80,
                                                    height: 100,
                                                    color: Colors.grey,
                                                  ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            credit['name'],
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Trailer
                      FutureBuilder<List<dynamic>>(
                        future: _movieTrailers,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Error al cargar los trailers: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data == null) {
                            return const Center(child: Text('No se encontraron trailers.'));
                          }

                          final trailers = snapshot.data!;
                          if (trailers.isEmpty) {
                            return const Center(child: Text('No hay trailers disponibles.'));
                          }

                          final trailerKey = trailers[0]['key'];
                          _youtubeController.loadVideoById(videoId: trailerKey);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trailer:',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 300.0,
                                width: double.infinity,
                                child: YoutubePlayer(
                                  controller: _youtubeController,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
