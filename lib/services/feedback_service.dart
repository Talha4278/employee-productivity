import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/feedback_model.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Stream<List<FeedbackModel>> getFeedbackForCustomer(String customerId) {
    return _firestore
        .collection('feedback')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Stream<List<FeedbackModel>> getAllFeedback() {
    return _firestore
        .collection('feedback')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FeedbackModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Future<String> submitFeedback(FeedbackModel feedback) async {
    try {
      final feedbackId = _uuid.v4();
      await _firestore.collection('feedback').doc(feedbackId).set({
        ...feedback.copyWith(id: feedbackId).toMap(),
        'id': feedbackId,
      });
      return feedbackId;
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }

  Future<void> respondToFeedback(
    String feedbackId,
    String response,
  ) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).update({
        'response': response,
        'respondedAt': DateTime.now(),
        'status': FeedbackStatus.reviewed.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to respond to feedback: $e');
    }
  }

  Future<void> updateFeedbackStatus(
    String feedbackId,
    FeedbackStatus status,
  ) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update feedback status: $e');
    }
  }
}

