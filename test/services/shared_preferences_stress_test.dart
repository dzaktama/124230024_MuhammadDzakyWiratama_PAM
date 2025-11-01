import 'dart:convert';
import 'dart:math'; 
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:projek_akhir_mobile/models/hafalan_model.dart'; 
import 'package:projek_akhir_mobile/services/hafalan_save.dart'; 

void main() {
  group('Shared Preferences Stress Test - Individual Operations', () {
    final int numberOfItems = 10000; 
    final Duration writeTimeout = const Duration(seconds: 60); 
    final Duration readTimeout = const Duration(seconds: 60); 

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Stress - Should handle individual creation of $numberOfItems hafalan items', () async {
      final stopwatch = Stopwatch()..start();
      List<Future<bool>> writeFutures = [];

      for (int i = 0; i < numberOfItems; i++) {
        final hafalan = Hafalan(
          id: i,
          idHafalan: i + 1,
          namaHafalan: 'Surat Uji-$i',
          tipeHafalan: 'surat',
          tanggalMulai: DateTime.now().toIso8601String(),
          tanggalSelesai: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        );
        writeFutures.add(SharedPreferences.getInstance().then((prefs) {
          return prefs.setString('hafalan_${hafalan.id}', jsonEncode(hafalan.toJson()));
        }));
      }

      await expectLater(Future.wait(writeFutures), completes);

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;
      print('[$numberOfItems Individual Writes] Completed in $elapsed ms');

      expect(elapsed, lessThan(writeTimeout.inMilliseconds), reason: 'Individual Writes took too long!');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('hafalan_0'), isTrue);
      expect(prefs.containsKey('hafalan_${numberOfItems - 1}'), isTrue);
    }, timeout: Timeout(writeTimeout + const Duration(seconds: 10))); 

    test('Stress - Should handle individual retrieval of $numberOfItems hafalan items', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      for (int i = 0; i < numberOfItems; i++) {
        final hafalan = Hafalan(
          id: i,
          idHafalan: i + 1,
          namaHafalan: 'Surat Uji-$i',
          tipeHafalan: 'surat',
          tanggalMulai: DateTime.now().toIso8601String(),
          tanggalSelesai: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        );
        await prefs.setString('hafalan_${hafalan.id}', jsonEncode(hafalan.toJson()));
      }

      final stopwatch = Stopwatch()..start();
      List<Future<Hafalan?>> readFutures = [];

      for (int i = 0; i < numberOfItems; i++) {
        readFutures.add(SharedPreferences.getInstance().then((prefs) {
          final jsonString = prefs.getString('hafalan_$i');
          if (jsonString != null) {
            return Hafalan.fromJson(jsonDecode(jsonString));
          }
          return null;
        }));
      }

      final results = await Future.wait(readFutures);

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;
      print('[$numberOfItems Individual Reads] Completed in $elapsed ms');

      expect(elapsed, lessThan(readTimeout.inMilliseconds), reason: 'Individual Reads took too long!');
      expect(results.length, numberOfItems); 
      expect(results.first, isNotNull); 
      expect(results.last, isNotNull); 

    }, timeout: Timeout(readTimeout + const Duration(seconds: 10))); 
  });

  group('Shared Preferences Stress Test - Mixed Concurrent Operations', () {
    late HafalanSave hafalanSave;
    final int numberOfOperations = 500; 
    final Duration timeout = const Duration(seconds: 30); 
    final Random random = Random();

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      hafalanSave = HafalanSave();
    });

    test('Stress - Should handle $numberOfOperations concurrent read/write/key operations', () async {
      final stopwatch = Stopwatch()..start();
      List<Future<void>> operationFutures = [];

      for (int i = 0; i < numberOfOperations; i++) {
        final operationType = random.nextInt(3); 
        final hafalanId = random.nextInt(numberOfOperations); 

        if (operationType == 0) { 
          final hafalan = Hafalan(
            id: hafalanId,
            idHafalan: hafalanId + 1,
            namaHafalan: 'Surat Mixed-$hafalanId',
            tipeHafalan: 'surat',
            tanggalMulai: DateTime.now().toIso8601String(),
            tanggalSelesai: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
          );
          operationFutures.add(SharedPreferences.getInstance().then((prefs) {
            return prefs.setString('mixed_hafalan_${hafalan.id}', jsonEncode(hafalan.toJson()));
          }));
        } else if (operationType == 1) { 
          operationFutures.add(SharedPreferences.getInstance().then((prefs) {
            final jsonString = prefs.getString('mixed_hafalan_$hafalanId');
            if (jsonString != null) {
              return Hafalan.fromJson(jsonDecode(jsonString));
            }
            return null;
          }));
        } else { 
          operationFutures.add(SharedPreferences.getInstance().then((prefs) {
            return prefs.getKeys();
          }));
        }
      }

      await expectLater(Future.wait(operationFutures), completes);

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;
      print('[$numberOfOperations Mixed Concurrent Operations] Completed in $elapsed ms');

      expect(elapsed, lessThan(timeout.inMilliseconds), reason: 'Mixed operations took too long!');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isNotEmpty);
    }, timeout: Timeout(timeout + const Duration(seconds: 10))); 
  });

  group('Shared Preferences Stress Test - Large Collection Save', () {
    late HafalanSave hafalanSave;
    final int numberOfLargeItems = 15000; 
    final Duration timeout = const Duration(seconds: 70); 
    const String mockUsername = 'stress_test_user';

    setUp(() {
      SharedPreferences.setMockInitialValues({
        'username': mockUsername,
      });
      hafalanSave = HafalanSave();
    });

    test('Stress - Memory and time for adding $numberOfLargeItems hafalan items with saveHafalanList', () async {
      List<Hafalan> largeHafalanList = [];
      for (int i = 0; i < numberOfLargeItems; i++) {
        largeHafalanList.add(Hafalan(
          id: i,
          idHafalan: i + 1,
          namaHafalan: 'Surat Besar-${i}',
          tipeHafalan: 'surat',
          tanggalMulai: DateTime.now().toIso8601String(),
          tanggalSelesai: DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        ));
      }

      final stopwatch = Stopwatch()..start();
      final success = await hafalanSave.saveHafalanList(largeHafalanList);
      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;
      print('[$numberOfLargeItems Large Collection Save] Completed in $elapsed ms');

      expect(success, isTrue, reason: 'Failed to save large hafalan list');
      expect(elapsed, lessThan(timeout.inMilliseconds), reason: 'Saving large collection took too long!');

      final prefs = await SharedPreferences.getInstance();
      
      const String expectedKey = 'hafalan_list_$mockUsername';
      final savedList = prefs.getStringList(expectedKey);
      
      expect(savedList, isNotNull);
      expect(savedList!.length, numberOfLargeItems);

    }, timeout: Timeout(timeout + const Duration(seconds: 10))); 
  });
}