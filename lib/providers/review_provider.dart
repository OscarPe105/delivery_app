import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/review.dart';

class ReviewProvider with ChangeNotifier {
  final List<Review> _reviews = [];
  final Map<String, List<Review>> _businessReviews = {};
  final Map<String, ReviewStatistics> _businessStatistics = {};
  bool _isLoading = false;
  
  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  
  // Obtener reviews de un negocio específico
  List<Review> getBusinessReviews(String businessId) {
    return _businessReviews[businessId] ?? [];
  }
  
  // Obtener estadísticas de un negocio
  ReviewStatistics? getBusinessStatistics(String businessId) {
    return _businessStatistics[businessId];
  }
  
  // Obtener rating promedio de un negocio
  double? getBusinessRating(String businessId) {
    return _businessStatistics[businessId]?.averageRating;
  }
  
  // Cargar todas las reviews de un negocio
  Future<void> loadBusinessReviews(String businessId) async {
    debugPrint('🚀 Loading reviews for business: $businessId');
    _isLoading = true;
    notifyListeners();
    
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('reviews')
          .where('businessId', isEqualTo: businessId)
          .orderBy('createdAt', descending: true)
          .get();
      
      final reviews = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Review.fromJson({
          'id': doc.id,
          ...data,
        });
      }).toList();
      
      _businessReviews[businessId] = reviews;
      _businessStatistics[businessId] = ReviewStatistics.fromReviews(reviews);
      
      debugPrint('✅ Loaded ${reviews.length} reviews for business $businessId');
    } catch (e) {
      debugPrint('❌ Error loading reviews for business $businessId: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Cargar todas las reviews de todos los negocios
  Future<void> loadAllReviews() async {
    debugPrint('🚀 Loading all reviews');
    _isLoading = true;
    notifyListeners();
    
    try {
      final firestore = FirebaseFirestore.instance;
      final querySnapshot = await firestore
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();
      
      _reviews.clear();
      _businessReviews.clear();
      _businessStatistics.clear();
      
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final review = Review.fromJson({
          'id': doc.id,
          ...data,
        });
        
        _reviews.add(review);
        
        // Agrupar por negocio
        if (_businessReviews[review.businessId] == null) {
          _businessReviews[review.businessId] = [];
        }
        _businessReviews[review.businessId]!.add(review);
      }
      
      // Calcular estadísticas para cada negocio
      _businessReviews.forEach((businessId, reviews) {
        _businessStatistics[businessId] = ReviewStatistics.fromReviews(reviews);
      });
      
      debugPrint('✅ Loaded ${_reviews.length} total reviews for ${_businessReviews.length} businesses');
    } catch (e) {
      debugPrint('❌ Error loading all reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Crear una nueva review
  Future<bool> createReview({
    required String businessId,
    required int rating,
    String? comment,
    String? orderId,
    List<String>? imageUrls,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ User not authenticated');
      return false;
    }
    
    // Validar rating
    if (rating < 1 || rating > 5) {
      debugPrint('❌ Invalid rating: $rating');
      return false;
    }
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Obtener información del usuario
      final userDoc = await firestore.collection('users').doc(currentUser.uid).get();
      final userData = userDoc.data();
      final userName = userData?['name'] ?? currentUser.displayName ?? 'Usuario';
      final userImageUrl = userData?['profileImage'];
      
      // Crear review
      final reviewData = {
        'businessId': businessId,
        'userId': currentUser.uid,
        'userName': userName,
        'userImageUrl': userImageUrl,
        'rating': rating,
        'comment': comment,
        'orderId': orderId,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      final docRef = await firestore.collection('reviews').add(reviewData);
      
      // Crear objeto Review
      final newReview = Review(
        id: docRef.id,
        businessId: businessId,
        userId: currentUser.uid,
        userName: userName,
        userImageUrl: userImageUrl,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
        imageUrls: imageUrls,
        orderId: orderId,
      );
      
      // Agregar a la lista local
      if (_businessReviews[businessId] == null) {
        _businessReviews[businessId] = [];
      }
      _businessReviews[businessId]!.insert(0, newReview);
      _reviews.insert(0, newReview);
      
      // Actualizar estadísticas
      _businessStatistics[businessId] = 
          ReviewStatistics.fromReviews(_businessReviews[businessId]!);
      
      // Actualizar rating del negocio
      await _updateBusinessRating(businessId);
      
      debugPrint('✅ Created review: ${docRef.id}');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error creating review: $e');
      return false;
    }
  }
  
  // Actualizar una review existente
  Future<bool> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ User not authenticated');
      return false;
    }
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Verificar que el usuario es el dueño de la review
      final reviewDoc = await firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) {
        debugPrint('❌ Review not found: $reviewId');
        return false;
      }
      
      final reviewData = reviewDoc.data()!;
      if (reviewData['userId'] != currentUser.uid) {
        debugPrint('❌ User not authorized to update this review');
        return false;
      }
      
      // Actualizar review
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (rating != null) {
        updateData['rating'] = rating;
      }
      if (comment != null) {
        updateData['comment'] = comment;
      }
      if (imageUrls != null) {
        updateData['imageUrls'] = imageUrls;
      }
      
      await firestore.collection('reviews').doc(reviewId).update(updateData);
      
      // Actualizar en la lista local
      final businessId = reviewData['businessId'] as String;
      final index = _businessReviews[businessId]!.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final oldReview = _businessReviews[businessId]![index];
        _businessReviews[businessId]![index] = oldReview.copyWith(
          rating: rating ?? oldReview.rating,
          comment: comment ?? oldReview.comment,
          imageUrls: imageUrls ?? oldReview.imageUrls,
          updatedAt: DateTime.now(),
        );
      }
      
      // Actualizar estadísticas
      _businessStatistics[businessId] = 
          ReviewStatistics.fromReviews(_businessReviews[businessId]!);
      
      // Actualizar rating del negocio
      await _updateBusinessRating(businessId);
      
      debugPrint('✅ Updated review: $reviewId');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error updating review: $e');
      return false;
    }
  }
  
  // Eliminar una review
  Future<bool> deleteReview(String reviewId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ User not authenticated');
      return false;
    }
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Verificar que el usuario es el dueño de la review
      final reviewDoc = await firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) {
        debugPrint('❌ Review not found: $reviewId');
        return false;
      }
      
      final reviewData = reviewDoc.data()!;
      if (reviewData['userId'] != currentUser.uid) {
        debugPrint('❌ User not authorized to delete this review');
        return false;
      }
      
      final businessId = reviewData['businessId'] as String;
      
      // Eliminar review
      await firestore.collection('reviews').doc(reviewId).delete();
      
      // Eliminar de la lista local
      _businessReviews[businessId]?.removeWhere((r) => r.id == reviewId);
      _reviews.removeWhere((r) => r.id == reviewId);
      
      // Actualizar estadísticas
      _businessStatistics[businessId] = 
          ReviewStatistics.fromReviews(_businessReviews[businessId]!);
      
      // Actualizar rating del negocio
      await _updateBusinessRating(businessId);
      
      debugPrint('✅ Deleted review: $reviewId');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting review: $e');
      return false;
    }
  }
  
  // Agregar respuesta del negocio a una review
  Future<bool> addBusinessReply({
    required String reviewId,
    required String reply,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint('❌ User not authenticated');
      return false;
    }
    
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Verificar que el usuario es dueño del negocio
      final reviewDoc = await firestore.collection('reviews').doc(reviewId).get();
      if (!reviewDoc.exists) {
        debugPrint('❌ Review not found: $reviewId');
        return false;
      }
      
      final reviewData = reviewDoc.data()!;
      final businessId = reviewData['businessId'] as String;
      
      // Verificar que el usuario es dueño del negocio
      final businessDoc = await firestore.collection('businesses').doc(businessId).get();
      if (!businessDoc.exists) {
        debugPrint('❌ Business not found: $businessId');
        return false;
      }
      
      final businessData = businessDoc.data()!;
      if (businessData['ownerId'] != currentUser.uid) {
        debugPrint('❌ User not authorized to reply to this review');
        return false;
      }
      
      // Agregar respuesta
      await firestore.collection('reviews').doc(reviewId).update({
        'businessReply': reply,
        'businessReplyAt': FieldValue.serverTimestamp(),
      });
      
      // Actualizar en la lista local
      final index = _businessReviews[businessId]!.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final oldReview = _businessReviews[businessId]![index];
        _businessReviews[businessId]![index] = oldReview.copyWith(
          businessReply: reply,
          businessReplyAt: DateTime.now(),
        );
      }
      
      debugPrint('✅ Added business reply to review: $reviewId');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Error adding business reply: $e');
      return false;
    }
  }
  
  // Actualizar el rating promedio del negocio en Firestore
  Future<void> _updateBusinessRating(String businessId) async {
    try {
      final statistics = _businessStatistics[businessId];
      if (statistics == null) return;
      
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('businesses').doc(businessId).update({
        'rating': statistics.averageRating,
      });
      
      debugPrint('✅ Updated business rating: $businessId -> ${statistics.averageRating}');
    } catch (e) {
      debugPrint('❌ Error updating business rating: $e');
    }
  }
  
  // Obtener reviews de un usuario
  List<Review> getUserReviews(String userId) {
    return _reviews.where((r) => r.userId == userId).toList();
  }
  
  // Verificar si un usuario ya dejó review en un negocio
  bool hasUserReviewedBusiness(String userId, String businessId) {
    return _reviews.any((r) => r.userId == userId && r.businessId == businessId);
  }
  
  // Obtener review de un usuario en un negocio específico
  Review? getUserReviewForBusiness(String userId, String businessId) {
    try {
      return _reviews.firstWhere(
        (r) => r.userId == userId && r.businessId == businessId,
      );
    } catch (e) {
      return null;
    }
  }
}

