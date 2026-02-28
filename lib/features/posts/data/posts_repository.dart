import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'package:glimpse/features/common/data/models.dart';
import 'package:glimpse/features/posts/data/posts_service.dart';
import 'package:path_provider/path_provider.dart';

class PostsRepository {
  final PostsService _postsService;

  PostsRepository({required PostsService postsService})
      : _postsService = postsService;

  Future<int?> uploadImage(File imageFile, int userId) async {
    final response1;
    try {
      response1 = await _postsService.uploadImage(imageFile.path, userId);
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Error uploading image: $e');
    }
    try {
      final response2 =
          await _postsService.createPost(userId, response1['image_url'], null);

      if (response2.containsKey('post_id')) {
        // Сохранение прошло успешно
        return response2['post_id'];
      }
      return null;
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Error creating post: $e');
    }
  }

  Future<Post?> getUserPost(int userId) async {
    try {
      final List<dynamic> posts = await _postsService.getUserPost(userId);

      if (posts.isNotEmpty) {
        final Map<String, dynamic> postData = posts[0];
        return Post.fromJson(postData);
      }
      return null;
    } catch (e) {
      print('Error getting post: $e');
      throw Exception('Error getting post: $e');
    }
  }

  Future<List<Post>> getFriendsPosts(int userId) async {
    try {
      final List<dynamic> raw = await _postsService.getFriendsPosts(userId);
      return raw.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting friends posts: $e');
      throw Exception('Error getting friends posts: $e');
    }
  }

  Future<File> getImageAsFile(String imagePath) async {
    final Uint8List bytes = await _postsService.getImage(imagePath);

    // Создаем временный файл
    final tempDir = await getTemporaryDirectory();
    final tempFile =
        File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Записываем байты в файл
    return await tempFile.writeAsBytes(bytes);
  }

  Future<void> updatePostCaption(int postId, String caption) async {
    try {
      final response = await _postsService.updatePostCaption(postId, caption);
    } catch (e) {
      print('Error updating caption in repository: $e');
      throw Exception('Error updating caption in repository: $e');
    }
  }

  Future<String?> getPostLikeCount(int postId) async {
    try {
      final response = await _postsService.getPostLikesCount(postId);

      if (response.containsKey('likes_count')) {
        return response['likes_count'].toString();
      }
      return null;
    } catch (e) {
      print('Error getting post like count: $e');
      throw Exception('Error getting post like count: $e');
    }
  }

  Future<void> likePost(int postId, int userId) async {
    try {
      final response = await _postsService.likePost(postId, userId);
    } catch (e) {
      print('Error liking post in repository: $e');
      throw Exception('Error liking post in repository: $e');
    }
  }

  Future<void> unlikePost(int postId, int userId) async {
    try {
      await _postsService.unlikePost(postId, userId);
    } catch (e) {
      print('Error unliking post in repository: $e');
      throw Exception('Error unliking post in repository: $e');
    }
  }

  Future<List<Comment>> getPostComments(int postId) async {
    try {
      final List<dynamic> raw = await _postsService.getPostComments(postId);
      return raw
          .map((e) => Comment.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting post comments: $e');
      throw Exception('Error getting post comments: $e');
    }
  }

  Future<void> addComment(int postId, int userId, String text) async {
    try {
      await _postsService.addComment(postId, userId, text);
    } catch (e) {
      print('Error adding comment in repository: $e');
      throw Exception('Error adding comment in repository: $e');
    }
  }
}
