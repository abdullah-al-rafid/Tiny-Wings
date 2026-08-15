import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/firebase_providers.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/post_model.dart';
import '../../../core/models/notification_model.dart';
import '../../notifications/data/notification_repository.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final notificationRepo = ref.watch(notificationRepositoryProvider);
  final storage = ref.watch(storageServiceProvider);
  return PostRepository(firestore, notificationRepo, storage);
});

class PostRepository {
  final FirebaseFirestore _firestore;
  final NotificationRepository _notificationRepo;
  final StorageService _storage;

  PostRepository(this._firestore, this._notificationRepo, this._storage);

  Future<void> createPost(Post post, {List<int>? imageBytes, String? extension}) async {
    String? imageUrl = post.imageData;
    String postId = _firestore.collection('posts').doc().id;
    
    if (imageBytes != null && extension != null) {
      final mimeType = (extension.toLowerCase() == 'jpg' || extension.toLowerCase() == 'jpeg') 
          ? 'image/jpeg' 
          : 'image/${extension.toLowerCase()}';
          
      try {
        imageUrl = await _storage.uploadImage(
          path: 'posts/$postId.$extension',
          bytes: Uint8List.fromList(imageBytes),
          mimeType: mimeType,
        );
      } catch (e) {
        final base64String = base64Encode(imageBytes);
        imageUrl = 'data:$mimeType;base64,$base64String';
      }
    }
    
    final postToSave = post.copyWith(id: postId, imageData: imageUrl);
    await _firestore.collection('posts').doc(postId).set(postToSave.toMap());
  }

  Future<List<Post>> getPosts() async {
    final snapshot = await _firestore.collection('posts').orderBy('timestamp', descending: true).get();
    return snapshot.docs.map((doc) => Post.fromMap(doc.id, doc.data())).toList();
  }

  Stream<List<Post>> watchPosts() {
    return _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Post.fromMap(doc.id, doc.data())).toList();
    });
  }

  Future<void> updatePost(Post post) async {
    await _firestore.collection('posts').doc(post.id).update(post.toMap());
  }

  Future<void> deletePost(String id) async {
    await _firestore.collection('posts').doc(id).delete();
  }

  Future<void> likePost(String postId, String userId, bool isLiked) async {
    final postRef = _firestore.collection('posts').doc(postId);
    
    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayUnion([userId])
      });
      
      // Send notification
      final doc = await postRef.get();
      if (doc.exists) {
        final post = Post.fromMap(doc.id, doc.data()!);
        if (post.authorId != userId) {
          final notification = AppNotification(
            id: '',
            userId: post.authorId,
            title: 'New Love on your post ❤️',
            message: 'Someone loved your impact update!',
            type: NotificationType.social,
            timestamp: DateTime.now(),
            relatedId: postId,
          );
          await _notificationRepo.sendNotification(notification);
        }
      }
    } else {
      await postRef.update({
        'likes': FieldValue.arrayRemove([userId])
      });
    }
  }

  Future<void> addComment(String postId, PostComment comment) async {
    final postRef = _firestore.collection('posts').doc(postId);
    
    await postRef.update({
      'comments': FieldValue.arrayUnion([comment.toMap()])
    });

    // Send notification
    final doc = await postRef.get();
    if (doc.exists) {
      final post = Post.fromMap(doc.id, doc.data()!);
      if (post.authorId != comment.userId) {
        final notification = AppNotification(
          id: '',
          userId: post.authorId,
          title: 'New Comment 💬',
          message: '${comment.userName} commented: "${comment.content}"',
          type: NotificationType.social,
          timestamp: DateTime.now(),
          relatedId: postId,
        );
        await _notificationRepo.sendNotification(notification);
      }
    }
  }
}
