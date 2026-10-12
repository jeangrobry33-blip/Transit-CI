/// Configuration du client Supabase (base de données transport réelle).
///
/// La clé publique (publishable) ci-dessous est conçue pour être embarquée
/// côté client — l'écriture est bloquée par des policies RLS côté serveur
/// (lecture publique uniquement, voir docs/BACKEND_ARCHITECTURE.md §7bis).
class SupabaseConfig {
  SupabaseConfig._();

  static const url = 'https://eangcvlflycbficpdyej.supabase.co';
  static const publishableKey = 'sb_publishable_o4cGEwh4EuL3-P9jOg8bzA_IoGIqFOp';
}
