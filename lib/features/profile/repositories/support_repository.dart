import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/constants/app_constants.dart';
import 'package:sport_connect/core/services/firebase_service.dart';
import 'package:sport_connect/core/services/talker_service.dart';

part 'support_repository.g.dart';

@Riverpod(keepAlive: true)
SupportRepository supportRepository(Ref ref) {
  return SupportRepository(
    ref.watch(firebaseServiceProvider).firestore,
    ref.watch(firebaseServiceProvider).storage,
  );
}

/// Handles submission of user reports and support tickets to Firestore,
/// including optional file-attachment uploads to Firebase Storage.
class SupportRepository {
  SupportRepository(this._firestore, this._storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  // ─── Reports ──────────────────────────────────────────────────────────────

  /// Submits a user or ride report and optionally uploads [attachments].
  ///
  /// Returns the new document ID.

  Future<String> submitReport({
    required String reporterId,
    required String reporterEmail,
    required String type,
    required String severity,
    required String description,
    String? reportedUserId,
    String? rideId,
    List<File> attachments = const [],
  }) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.reportsCollection)
          .doc();
      final urls = attachments.isEmpty
          ? <String>[]
          : await _uploadFiles(attachments, 'report_attachments/${docRef.id}');

      await docRef.set({
        'reporterId': reporterId,
        'reporterEmail': reporterEmail,
        'reportedUserId': reportedUserId,
        'rideId': rideId,
        'type': type,
        'severity': severity,
        'description': description,
        'attachmentUrls': urls,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      TalkerService.info('Report submitted: ${docRef.id}');
      return docRef.id;
    } on Exception catch (e) {
      TalkerService.error('Error submitting report: $e');
      rethrow;
    }
  }

  // ─── Support tickets ───────────────────────────────────────────────────────

  /// Submits a support ticket and optionally uploads [attachments].
  ///
  /// Returns the new document ID.

  Future<String> submitSupportTicket({
    required String userId,
    required String userEmail,
    required String userName,
    required String category,
    required String subject,
    required String message,
    List<File> attachments = const [],
  }) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.supportTicketsCollection)
          .doc();
      final urls = attachments.isEmpty
          ? <String>[]
          : await _uploadFiles(attachments, 'support_attachments/${docRef.id}');

      await docRef.set({
        'userId': userId,
        'userEmail': userEmail,
        'userName': userName,
        'category': category,
        'subject': subject,
        'message': message,
        'attachmentUrls': urls,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });

      TalkerService.info('Support ticket submitted: ${docRef.id}');
      return docRef.id;
    } on Exception catch (e) {
      TalkerService.error('Error submitting support ticket: $e');
      rethrow;
    }
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  Future<List<String>> _uploadFiles(
    List<File> files,
    String storagePath,
  ) async {
    final urls = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ext = file.path.split('.').last;
      final ref = _storage.ref().child(storagePath).child('file_$i.$ext');
      await ref.putFile(file);
      urls.add(await ref.getDownloadURL());
    }
    return urls;
  }
}
