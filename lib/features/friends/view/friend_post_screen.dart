import 'dart:io';

import 'package:flutter/material.dart';
import 'package:glimpse/features/common/data/models.dart';
import 'package:glimpse/features/common/domain/useful_methods.dart';
import 'package:glimpse/features/common/di/service_locator.dart';
import 'package:glimpse/features/home/data/home_page_repository.dart';
import 'package:glimpse/features/home/domain/load_data.dart';
import 'package:glimpse/features/posts/data/posts_repository.dart';
import 'package:glimpse/features/posts/domain/like_post.dart';
import 'package:intl/intl.dart';

class FriendPostScreen extends StatefulWidget {
  final User currentUser;
  final User friend;
  final Post post;

  const FriendPostScreen({
    Key? key,
    required this.currentUser,
    required this.friend,
    required this.post,
  }) : super(key: key);

  @override
  State<FriendPostScreen> createState() => _FriendPostScreenState();
}

class _FriendPostScreenState extends State<FriendPostScreen> {
  File? _postImage;
  String? _likeCount;
  String _likePic = 'assets/images/heart_empty.png';
  bool _isLoading = true;
  List<Comment> _comments = [];
  Map<int, User> _commentAuthors = {};
  final TextEditingController _commentController = TextEditingController();

  static final _postsRepo = getIt<PostsRepository>();
  static final _homeRepo = getIt<HomePageRepository>();

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadCommentAuthors(List<Comment> comments) async {
    final ids = comments.map((c) => c.userId).toSet();
    final map = <int, User>{};
    if (ids.contains(widget.currentUser.userId)) {
      map[widget.currentUser.userId] = widget.currentUser;
    }
    for (final id in ids) {
      if (map.containsKey(id)) continue;
      final user = await _homeRepo.getUserById(id);
      if (user != null && mounted) map[id] = user;
    }
    if (mounted) setState(() => _commentAuthors = map);
  }

  Future<void> _loadPostData() async {
    try {
      final image = await getImage(widget.post.imagePath);
      final count = await getLikeCount(widget.post.postId);
      final comments = await _postsRepo.getPostComments(widget.post.postId);
      await _loadCommentAuthors(comments);
      if (mounted) {
        setState(() {
          _postImage = image;
          _likeCount = count;
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorMessage('Ошибка при загрузке поста', context);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _postsRepo.getPostComments(widget.post.postId);
      await _loadCommentAuthors(comments);
      if (mounted) setState(() => _comments = comments);
    } catch (_) {}
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    try {
      await _postsRepo.addComment(
        widget.post.postId,
        widget.currentUser.userId,
        text,
      );
      _commentController.clear();
      await _loadComments();
    } catch (e) {
      if (mounted) showErrorMessage('Ошибка при отправке комментария', context);
    }
  }

  Future<void> _likeManager() async {
    try {
      if (_likePic == 'assets/images/heart_empty.png') {
        await likePost(widget.post.postId, widget.currentUser.userId);
        final count = await getLikeCount(widget.post.postId);
        if (mounted) {
          setState(() {
            _likePic = 'assets/images/heart_full.png';
            _likeCount = count;
          });
        }
      } else {
        await unlikePost(widget.post.postId, widget.currentUser.userId);
        final count = await getLikeCount(widget.post.postId);
        if (mounted) {
          setState(() {
            _likePic = 'assets/images/heart_empty.png';
            _likeCount = count;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorMessage('Ошибка при лайке', context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final caption = widget.post.caption?.isEmpty ?? true
        ? 'Подпись к изображению'
        : widget.post.caption!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.friend.username,
          style: TextStyle(
            color: Colors.blueGrey[200],
            fontFamily: "Playball",
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.blueGrey[200]),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Пост друга — картинка и подпись в том же стиле, что на главной
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromRGBO(255, 160, 140, 1),
                            Colors.pinkAccent[400]!,
                            Colors.blueGrey[300]!,
                            Colors.blueGrey[700]!,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          if (_postImage != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.file(
                                _postImage!,
                                width: double.infinity,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              caption,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Raleway",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                          // Лайк под постом
                          Padding(
                            padding: EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _likeCount ?? '0',
                                  style: TextStyle(
                                    color: Color.fromRGBO(255, 160, 140, 1),
                                    fontFamily: "Raleway",
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                InkWell(
                                  onTap: _likeManager,
                                  child: Image.asset(
                                    _likePic,
                                    width: 43,
                                    height: 43,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Комментарии
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Комментарии',
                        style: TextStyle(
                          color: Colors.blueGrey[200],
                          fontFamily: "Raleway",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.blueGrey[700]!),
                    ),
                    constraints: BoxConstraints(minHeight: 60),
                    child: _comments.isEmpty
                        ? Text(
                            'Пока нет комментариев.',
                            style: TextStyle(
                              color: Colors.blueGrey[400],
                              fontFamily: "Raleway",
                              fontSize: 14,
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final c = _comments[i];
                              final author = _commentAuthors[c.userId];
                              final nickname = c.userId == widget.currentUser.userId
                                  ? 'Вы'
                                  : (author?.username ?? 'Пользователь');
                              final timeStr = DateFormat('HH:mm, dd.MM').format(c.timestamp);
                              final avatarProvider = author?.profilePic != null
                                  ? NetworkImage(author!.profilePic!) as ImageProvider
                                  : AssetImage('assets/images/user_icon.jpg') as ImageProvider;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.blueGrey[700],
                                        backgroundImage: avatarProvider,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        nickname,
                                        style: TextStyle(
                                          color: Colors.blueGrey[200],
                                          fontFamily: "Raleway",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          color: Colors.blueGrey[500],
                                          fontFamily: "Raleway",
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 36.0, top: 4),
                                    child: Text(
                                      c.text,
                                      style: TextStyle(
                                        color: Colors.blueGrey[100],
                                        fontFamily: "Raleway",
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),

                  // Ввод комментария и кнопка отправить
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: TextStyle(color: Colors.white),
                            maxLines: 2,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Написать комментарий...',
                              hintStyle: TextStyle(color: Colors.blueGrey[500]),
                              filled: true,
                              fillColor: Colors.blueGrey[900],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.blueGrey[400]!),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _sendComment,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/images/share.png',
                                width: 36,
                                height: 36,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
