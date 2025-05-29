import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import './services/api_service.dart';

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
        mute: false,
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
        title: const Text('Detalles'),
        backgroundColor: Colors.deepPurple[900],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _movieDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar detalles',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final movie = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Image.network(
                      'https://image.tmdb.org/t/p/w500${movie['backdrop_path']}',
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.deepPurple[900]!.withOpacity(0.9),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        movie['title'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.deepPurple[200], size: 16),
                          const SizedBox(width: 8),
                          Text(
                            movie['release_date'],
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            movie['vote_average'].toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sinopsis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie['overview'] ?? 'No disponible',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<List<dynamic>>(
                        future: _movieCredits,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Colors.deepPurpleAccent,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error al cargar el reparto',
                              style: TextStyle(color: Colors.white),
                            );
                          }

                          final credits = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reparto Principal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 160,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: credits.length,
                                  itemBuilder: (context, index) {
                                    final credit = credits[index];
                                    return Container(
                                      width: 100,
                                      margin: const EdgeInsets.only(right: 12),
                                      child: Column(
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
                                              color: Colors.grey[800],
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.grey[400],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            credit['name'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
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
                      // Versión corregida del bloque del trailer:
                      FutureBuilder<List<dynamic>>(
                        future: _movieTrailers,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Colors.deepPurpleAccent,
                              ),
                            );
                          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(); // Ocultar sección si no hay trailers
                          }

                          final trailerKey = snapshot.data![0]['key'];
                          _youtubeController.loadVideoById(videoId: trailerKey);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tráiler',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: YoutubePlayer(
                                    controller: _youtubeController,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}