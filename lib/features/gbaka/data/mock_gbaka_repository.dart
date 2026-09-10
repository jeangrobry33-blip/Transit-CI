import '../../../core/widgets/status_badge.dart';
import '../domain/transit_line.dart';

/// Données simulées des lignes de gbaka, wôrô-wôrô et bus urbains.
/// À remplacer par les flux GPS temps réel des véhicules partenaires.
class MockGbakaRepository {
  Future<List<TransitLine>> lines({LineMode? mode}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final all = _lines;
    if (mode == null) return all;
    return all.where((l) => l.mode == mode).toList();
  }

  Future<TransitLine> lineDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _lines.firstWhere((l) => l.id == id);
  }

  static const _lines = [
    TransitLine(
      id: 'line_1',
      code: 'Gbaka 12',
      mode: LineMode.gbaka,
      origin: 'Adjamé',
      destination: 'Yopougon',
      stops: ['Adjamé Gare', 'Sicogi', 'Niangon', 'Yopougon Siporex'],
      waitMinutes: 6,
      averagePrice: 300,
      affluence: AffluenceLevel.medium,
    ),
    TransitLine(
      id: 'line_2',
      code: 'Gbaka 04',
      mode: LineMode.gbaka,
      origin: 'Plateau',
      destination: 'Abobo',
      stops: ['Plateau Gare Sud', 'Adjamé', 'Abobo Gare'],
      waitMinutes: 4,
      averagePrice: 350,
      affluence: AffluenceLevel.high,
    ),
    TransitLine(
      id: 'line_3',
      code: 'Wôrô 21',
      mode: LineMode.woroworo,
      origin: 'Cocody',
      destination: 'Marcory',
      stops: ['Cocody Angré', 'Riviera 2', 'Zone 4', 'Marcory Résidentiel'],
      waitMinutes: 3,
      averagePrice: 500,
      affluence: AffluenceLevel.low,
    ),
    TransitLine(
      id: 'line_4',
      code: 'Wôrô 09',
      mode: LineMode.woroworo,
      origin: 'Treichville',
      destination: 'Koumassi',
      stops: ['Treichville Gare', 'Biafra', 'Koumassi Grand Marché'],
      waitMinutes: 5,
      averagePrice: 400,
      affluence: AffluenceLevel.medium,
    ),
    TransitLine(
      id: 'line_5',
      code: 'SOTRA Ligne 51',
      mode: LineMode.busUrbain,
      origin: 'Gare Sud Plateau',
      destination: 'Bingerville',
      stops: ['Plateau', 'Cocody', 'Riviera', 'Bingerville Centre'],
      waitMinutes: 12,
      averagePrice: 250,
      affluence: AffluenceLevel.low,
    ),
    TransitLine(
      id: 'line_6',
      code: 'SOTRA Ligne 08',
      mode: LineMode.busUrbain,
      origin: 'Adjamé',
      destination: 'Port-Bouët',
      stops: ['Adjamé', 'Treichville', 'Marcory', 'Port-Bouët'],
      waitMinutes: 10,
      averagePrice: 250,
      affluence: AffluenceLevel.medium,
    ),
  ];
}
