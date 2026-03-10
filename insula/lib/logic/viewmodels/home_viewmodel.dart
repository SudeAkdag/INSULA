import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insula/data/models/glucose_model.dart';
import 'package:insula/data/models/insulin_log_model.dart';
import 'package:insula/data/services/insulin_service.dart';
import 'package:insula/data/services/glucose_service.dart';

/// Ana sayfa ViewModel - veriler asenkron yüklenir, UI donması önlenir.
/// Tip 1 diyabet kullanıcıları için özel kart verilerini sağlar.
class HomeViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final InsulinService _insulinService = InsulinService();
  final GlucoseService _glucoseService = GlucoseService();

  String? get _uid => _auth.currentUser?.uid;

  // ─── State ───────────────────────────────────────────────────────────────
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _diabetesType;
  int _carbRatio = 10;
  int _targetGlucoseMin = 70;
  int _targetGlucoseMax = 140;
  double _todayCarbs = 0;
  double _todayInsulinTotal = 0;
  GlucoseReading? _latestGlucose;
  InsulinLog? _latestActiveInsulin;
  StreamSubscription? _insulinSubscription;
  Timer? _durationRefreshTimer;

  // ─── Getters ──────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isType1 => _diabetesType == 'Tip 1';
  int get carbRatio => _carbRatio;
  int get targetGlucoseMin => _targetGlucoseMin;
  int get targetGlucoseMax => _targetGlucoseMax;
  double get todayCarbs => _todayCarbs;
  double get todayInsulinTotal => _todayInsulinTotal;
  GlucoseReading? get latestGlucose => _latestGlucose;
  InsulinLog? get latestActiveInsulin => _latestActiveInsulin;

  /// Önerilen insülin (karbonhidrat bazlı) = carbs / carbRatio
  double get recommendedInsulinForCarbs {
    if (_todayCarbs <= 0) return 0;
    return _todayCarbs / _carbRatio;
  }

  /// Düzeltme insülini (şeker yüksekse) - opsiyonel, şimdilik sadece karb bazlı
  double get correctionInsulin {
    if (_latestGlucose == null || !isType1) return 0;
    if (_latestGlucose!.value <= _targetGlucoseMax) return 0;
    // Basit formül: (mevcut - hedef) / 50 (duyarlılık faktörü varsayılan)
    final diff = _latestGlucose!.value - _targetGlucoseMax;
    return (diff / 50).clamp(0.0, 10.0);
  }

  /// Toplam önerilen insülin (karb + düzeltme)
  double get totalRecommendedInsulin =>
      recommendedInsulinForCarbs + correctionInsulin;

  /// Kan şekeri değerinin hedef aralıkta olup olmadığı
  String glucoseStatus(int value) =>
      GlucoseReading.statusFromRange(
          value, _targetGlucoseMin, _targetGlucoseMax);

  // ─── Tarih anahtarı ──────────────────────────────────────────────────────
  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // ─── Veri yükleme ────────────────────────────────────────────────────────

  /// İlk yükleme - paralel ve asenkron, UI bloklamaz.
  Future<void> load() async {
    if (_uid == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Paralel yükleme - hepsi aynı anda başlar
      await Future.wait([
        _loadUserProfile(),
        _loadTodayCarbs(),
        _loadTodayInsulinTotal(),
        _loadLatestGlucose(),
        _loadLatestActiveInsulin(),
      ]);

      _startDurationRefreshTimer();
      _listenToActiveInsulin();
    } catch (e) {
      debugPrint('HomeViewModel.load hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final doc = await _firestore.collection('users').doc(_uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _diabetesType = data['diabetesType'] as String?;
        _carbRatio = (data['carbRatio'] as num?)?.toInt() ?? 10;
        _targetGlucoseMin =
            (data['targetGlucoseMin'] as num?)?.toInt() ?? 70;
        _targetGlucoseMax =
            (data['targetGlucoseMax'] as num?)?.toInt() ?? 140;
      }
    } catch (e) {
      debugPrint('HomeViewModel._loadUserProfile hata: $e');
    }
  }

  Future<void> _loadTodayCarbs() async {
    try {
      final dateKey = _dateKey(DateTime.now());
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('meals')
          .doc(dateKey)
          .collection('mealEntries')
          .get();

      double total = 0;
      for (final doc in snapshot.docs) {
        final carbs = (doc.data()['carbs'] as num?)?.toDouble();
        if (carbs != null) total += carbs;
      }
      _todayCarbs = total;
    } catch (e) {
      debugPrint('HomeViewModel._loadTodayCarbs hata: $e');
    }
  }

  Future<void> _loadTodayInsulinTotal() async {
    try {
      _todayInsulinTotal =
          await _insulinService.getTodayInsulinTotal();
    } catch (e) {
      debugPrint('HomeViewModel._loadTodayInsulinTotal hata: $e');
    }
  }

  Future<void> _loadLatestGlucose() async {
    try {
      _latestGlucose = await _glucoseService.getLatestGlucose();
    } catch (e) {
      debugPrint('HomeViewModel._loadLatestGlucose hata: $e');
    }
  }

  Future<void> _loadLatestActiveInsulin() async {
    try {
      _latestActiveInsulin = await _insulinService.getLatestActiveInsulin();
    } catch (e) {
      debugPrint('HomeViewModel._loadLatestActiveInsulin hata: $e');
    }
  }

  void _listenToActiveInsulin() {
    _insulinSubscription?.cancel();
    _insulinSubscription = _insulinService.watchLatestActiveInsulin().listen(
      (log) {
        _latestActiveInsulin = log;
        notifyListeners();
      },
    );
  }

  /// Aktif insülin süresi her dakika güncellenir.
  void _startDurationRefreshTimer() {
    _durationRefreshTimer?.cancel();
    _durationRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_latestActiveInsulin != null && _latestActiveInsulin!.isActive) {
        notifyListeners();
      } else {
        _latestActiveInsulin = null;
        notifyListeners();
      }
    });
  }

  /// Manuel yenileme (pull-to-refresh vb.)
  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    notifyListeners();

    await load();
    _isRefreshing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _insulinSubscription?.cancel();
    _durationRefreshTimer?.cancel();
    super.dispose();
  }
}
