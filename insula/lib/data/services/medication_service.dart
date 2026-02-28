import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference for user medications
  CollectionReference<Map<String, dynamic>> _getUserMedicationsCollection() {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception("Kullanıcı girişi yapılmamış!");
    return _firestore.collection('users').doc(uid).collection('medications');
  }

  // 1. Yeni İlaç Kaydetme
  Future<void> saveMedication(Map<String, dynamic> medicationData) async {
    try {
      final collection = _getUserMedicationsCollection();
      
      final Map<String, dynamic> dataToSave = Map<String, dynamic>.from(medicationData);
      
      // doseTimes listesini işle
      if (dataToSave['doseTimes'] != null) {
        final List<dynamic> times = dataToSave['doseTimes'] as List<dynamic>;
        dataToSave['doseTimes'] = times.map((t) {
          if (t is TimeOfDay) {
            return {'hour': t.hour, 'minute': t.minute};
          }
          return t; // Zaten map ise bırak
        }).toList();
      }
      
      dataToSave['createdAt'] = FieldValue.serverTimestamp();

      await collection.add(dataToSave);
      debugPrint("İlaç başarıyla kaydedildi.");
    } catch (e) {
      debugPrint("İlaç Kayıt Hatası: $e");
      rethrow;
    }
  }

  // 2. Mevcut İlacı Güncelleme
  Future<void> updateMedication(String docId, Map<String, dynamic> medicationData) async {
    try {
      final collection = _getUserMedicationsCollection();
      
      final Map<String, dynamic> dataToUpdate = Map<String, dynamic>.from(medicationData);
      
      // doseTimes listesini işle
      if (dataToUpdate['doseTimes'] != null) {
        final List<dynamic> times = dataToUpdate['doseTimes'] as List<dynamic>;
        dataToUpdate['doseTimes'] = times.map((t) {
          if (t is TimeOfDay) {
            return {'hour': t.hour, 'minute': t.minute};
          }
          return t; // Zaten map ise bırak
        }).toList();
      }

      await collection.doc(docId).update(dataToUpdate);
      debugPrint("İlaç başarıyla güncellendi.");
    } catch (e) {
      debugPrint("İlaç Güncelleme Hatası: $e");
      rethrow;
    }
  }

  // 3. İlacı Silme
  Future<void> deleteMedication(String docId) async {
    try {
      final collection = _getUserMedicationsCollection();
      await collection.doc(docId).delete();
      debugPrint("İlaç başarıyla silindi.");
    } catch (e) {
      debugPrint("İlaç Silme Hatası: $e");
      rethrow;
    }
  }

  // 4. Kullanıcının İlaçlarını Dinleme (Stream)
  Stream<List<Map<String, dynamic>>> getMedications() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value([]);
      }

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              
              // Firestore'daki dökümanı UI'ın beklediği formata (TimeOfDay) geri döndür
              if (data['doseTimes'] != null) {
                final List<dynamic> times = data['doseTimes'] as List<dynamic>;
                data['doseTimes'] = times.map((t) {
                  final map = t as Map<String, dynamic>;
                  return TimeOfDay(hour: map['hour'] as int, minute: map['minute'] as int);
                }).toList();
              }
              
              // List<dynamic>'leri List<String>'e ve List<bool>'a zorla (UI için)
              if (data['doseAmounts'] != null) {
                data['doseAmounts'] = List<String>.from(data['doseAmounts'] as List);
              }
              if (data['doseUsageTimes'] != null) {
                data['doseUsageTimes'] = List<String>.from(data['doseUsageTimes'] as List);
              }
              if (data['doseConditions'] != null) {
                data['doseConditions'] = List<String>.from(data['doseConditions'] as List);
              }
              if (data['takenFlags'] != null) {
                data['takenFlags'] = List<bool>.from(data['takenFlags'] as List);
              }

              // Firestore Timestamp -> DateTime dönüşümleri
              if (data['startDate'] != null && data['startDate'] is Timestamp) {
                data['startDate'] = (data['startDate'] as Timestamp).toDate();
              }
              if (data['endDate'] != null && data['endDate'] is Timestamp) {
                data['endDate'] = (data['endDate'] as Timestamp).toDate();
              }

              return data;
            }).toList();
          });
    });
  }
}
