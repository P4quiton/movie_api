class FavoritesService {
  static final List<int> _favoriteMovieIds = [];

  static bool isFavorite(int movieId) {
    return _favoriteMovieIds.contains(movieId);
  }

  static void toggleFavorite(int movieId) {
    if (isFavorite(movieId)) {
      _favoriteMovieIds.remove(movieId);
    } else {
      _favoriteMovieIds.add(movieId);
    }
  }

  static List<int> getFavorites() {
    return _favoriteMovieIds;
  }
}
