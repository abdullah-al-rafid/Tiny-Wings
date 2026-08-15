import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/post_repository.dart';
import '../../../core/models/post_model.dart';

final postsProvider = StreamProvider<List<Post>>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.watchPosts();
});

final postActionsProvider = Provider((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return PostActions(ref, repository);
});

class PostActions {
  final Ref _ref;
  final PostRepository _repository;

  PostActions(this._ref, this._repository);

  Future<void> createPost(Post post, {List<int>? imageBytes, String? extension}) async {
    await _repository.createPost(post, imageBytes: imageBytes, extension: extension);
    _ref.invalidate(postsProvider);
  }

  Future<void> updatePost(Post post) async {
    await _repository.updatePost(post);
    _ref.invalidate(postsProvider);
  }

  Future<void> deletePost(String id) async {
    await _repository.deletePost(id);
    _ref.invalidate(postsProvider);
  }

  Future<void> toggleLike(String postId, String userId, bool isLiked) async {
    await _repository.likePost(postId, userId, isLiked);
    _ref.invalidate(postsProvider);
  }

  Future<void> addComment(String postId, PostComment comment) async {
    await _repository.addComment(postId, comment);
    _ref.invalidate(postsProvider);
  }
}

