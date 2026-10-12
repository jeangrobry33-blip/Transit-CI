import 'package:supabase_flutter/supabase_flutter.dart';

/// Accès partagé au client Supabase (base de données transport réelle).
/// Lecture seule : l'écriture publique est bloquée par les policies RLS.
/// Chaque feature parse les lignes retournées dans son propre modèle de
/// domaine pour garder `core` indépendant des types métier.
class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchTripPlaces() async {
    final rows = await _client.from('trip_places').select().order('name');
    return List<Map<String, dynamic>>.from(rows as List);
  }

  Future<List<Map<String, dynamic>>> fetchCompanies() async {
    final rows = await _client.from('companies').select().order('name');
    return List<Map<String, dynamic>>.from(rows as List);
  }
}
