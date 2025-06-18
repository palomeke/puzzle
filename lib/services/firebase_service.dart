import 'package:cloud_firestore/cloud_firestore.dart';

/// Servicio para leaderboard usando Firebase Firestore.
class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Guarda la puntuación del jugador en la colección 'leaderboard'.
  Future<void> submitScore(String playerId, int moves, Duration time) async {
    await _db.collection('leaderboard').add({
      'playerId': playerId,
      'moves': moves,
      'time': time.inSeconds,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Obtiene el top N de la leaderboard ordenado por movimientos y tiempo.
  Stream<QuerySnapshot> getTopScores(int limit) {
    return _db
        .collection('leaderboard')
        .orderBy('moves')
        .orderBy('time')
        .limit(limit)
        .snapshots();
  }
}
