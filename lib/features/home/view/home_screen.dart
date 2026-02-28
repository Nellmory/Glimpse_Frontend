import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:glimpse/features/authentication/view/authentication.dart';
import 'package:glimpse/features/common/data/models.dart';
import 'package:glimpse/features/common/domain/useful_methods.dart';
import 'package:glimpse/features/home/domain/load_data.dart';
import 'package:glimpse/features/home/domain/download_image.dart';
import 'package:glimpse/features/home/domain/share_image.dart';
import 'package:glimpse/features/home/domain/update_caption.dart';
import 'package:glimpse/features/posts/domain/like_post.dart';
import 'package:glimpse/features/profile_settings/view/settings_screen.dart';
import 'package:glimpse/features/authentication/domain/token_manager.dart';
import 'package:glimpse/features/home/domain/new_post_upload.dart';
import 'package:glimpse/features/friends/view/search_screen.dart';
import 'package:glimpse/features/friends/view/friend_post_screen.dart';
import 'package:glimpse/features/common/di/service_locator.dart';
import 'package:glimpse/features/posts/data/posts_repository.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements UserAndPostState {
  User? _user;
  Post? _post;
  File? _postImage;
  String? _postCaption;
  String? _likeCount;
  String _likePic = 'assets/images/heart_empty.png';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(true);
  }

  File? _image;
  double _opacity = 0.7;
  final ImagePicker _picker = ImagePicker();

  Future<void> _loadData(bool start) async {
    try {
      if (start) {
        await loadUserData(context, this);
      } else {
        await uploadImageToServer(_image!, _user!, context);
      }
      if (_user != null) {
        await loadPostData(context, this);
        _loadPostScreenData();
      }
    } catch (e) {
      print('Error in _loadData: $e');
      showErrorMessage('Ошибка при загрузке данных', context);
    }
  }

  Future<void> _loadPostScreenData() async {
    if (_post != null) {
      try {
        File image = await getImage(_post!.imagePath);
        String? count = await getLikeCount(_post!.postId);
        setState(() {
          _postImage = image;
          _postCaption = _post!.caption?.isEmpty ?? true
              ? 'Подпись к изображению'
              : _post!.caption!;
          _likeCount = count;
          _opacity = 1.0;
        });
      } catch (e) {
        showErrorMessage('Ошибка при загрузке данных поста', context);
      }
    }
  }

  Future _getImage() async {
    // Если пост уже существует, не позволяем делать новый
    if (_post != null) {
      return;
    }

    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _opacity = 1.0;
        _loadData(false);
      } else {
        print('No image selected.');
        _opacity = 0.7;
      }
    });
  }

  Widget _buildImageWidget() {
    // Если есть существующий пост, показываем его изображение
    if (_post != null && _postImage != null) {
      return Image.file(
        _postImage!,
        width: 170,
        height: 300,
        fit: BoxFit.cover,
      );
    }
    // Если поста нет, показываем либо выбранное изображение, либо заглушку
    return _image == null
        ? Image.asset(
            'assets/images/black_gradient.jpeg',
            width: 170,
            height: 300,
            fit: BoxFit.cover,
          )
        : Image.file(
            _image!,
            width: 170,
            height: 300,
            fit: BoxFit.cover,
          );
  }

  Future _likeManager() async {
    if (_post != null) {
      if (_likePic == 'assets/images/heart_empty.png') {
        try {
          await likePost(_post!.postId, _user!.userId);
          String? count = await getLikeCount(_post!.postId);
          setState(() {
            _likePic = 'assets/images/heart_full.png';
            _likeCount = count;
          });
        } catch (e) {
          showErrorMessage('Ошибка при лайке поста', context);
        }
      } else {
        if (_likePic == 'assets/images/heart_full.png') {
          try {
            await unlikePost(_post!.postId, _user!.userId);
            String? count = await getLikeCount(_post!.postId);
            setState(() {
              _likePic = 'assets/images/heart_empty.png';
              _likeCount = count;
            });
          } catch (e) {
            showErrorMessage('Ошибка при анлайке поста', context);
          }
        }
      }
    } else {
      return;
    }
  }

  Future<void> _showCaptionDialog() async {
    final TextEditingController captionController = TextEditingController();
    captionController.text = _post?.caption ?? '';

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.blueGrey[400]!,
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Изменить подпись',
                  style: TextStyle(
                    color: Colors.blueGrey[200],
                    fontFamily: "Playball",
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: captionController,
                  style: TextStyle(color: Colors.white),
                  maxLength: 50,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Подпись к изображению',
                    labelStyle: TextStyle(color: Colors.blueGrey[200]),
                    hintText: 'Введите подпись...',
                    hintStyle: TextStyle(color: Colors.blueGrey[600]),
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
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blueGrey[400],
                          padding: EdgeInsets.symmetric(vertical: 12),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text('Отмена'),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          updatePostCaption(captionController.text, _post!, this);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Сохранить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.black,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen(user: _user!)),
              );
            },
            child: Icon(
              Icons.search,
              color: Colors.blueGrey[200]!,
              size: 32.0,
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Glimpse",
              style: TextStyle(
                  color: Colors.blueGrey[200],
                  fontFamily: "Playball",
                  fontSize: 50),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Settings(user: _user!)),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: _user?.profilePic != null
                        ? NetworkImage(_user!.profilePic!)
                        : const AssetImage('assets/images/user_icon.jpg'),
                    radius: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Левая колонка с иконками
              Container(
                height: 316,
                // Высота должна соответствовать высоте центральной колонки
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 150.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_post == null) {
                                showErrorMessage(
                                  'Опубликуйте пост, чтобы смотреть комментарии к нему :)',
                                  context,
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FriendPostScreen(
                                      currentUser: _user!,
                                      friend: _user!,
                                      post: _post!,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Image.asset(
                              'assets/images/comments.png',
                              width: 38,
                              height: 38,
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: _post != null
                                ? () => shareImage(_postImage!)
                                : null,
                            child: Image.asset(
                              'assets/images/share.png',
                              width: 35,
                              height: 35,
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: _post != null
                                ? () => downloadImage(context, _postImage!)
                                : null,
                            child: Image.asset(
                              'assets/images/download.png',
                              width: 33,
                              height: 33,
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Центральная колонка с основным контентом
              Container(
                margin: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(255, 160, 140, 1),
                      //Colors.amberAccent[400]!,
                      Colors.pinkAccent[400]!,
                      Colors.blueGrey[300]!,
                      Colors.blueGrey[700]!,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: _post == null ? _getImage : null,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Opacity(
                          opacity: _opacity,
                          child: _buildImageWidget(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        width: 170,
                        child: InkWell(
                          onTap: _post != null ? _showCaptionDialog : null,
                          child: Text(
                            _postCaption ?? 'Подпись к изображению',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Raleway",
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Правая колонка
              Container(
                height: 316,
                // Высота должна соответствовать высоте центральной колонки
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 150.0),
                      child: Column(
                        children: [
                          Text(
                            _likeCount ?? '',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 160, 140, 1),
                                fontFamily: "Raleway",
                                fontSize: 22,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 5),
                          InkWell(
                            onTap: _post != null ? _likeManager : null,
                            child: Image.asset(
                              _likePic,
                              width: 43,
                              height: 43,
                            ),
                          ),
                          SizedBox(height: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Заголовок Friends и список друзей
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Friends',
                style: TextStyle(
                    color: Colors.blueGrey[200],
                    fontFamily: "Playball",
                    fontSize: 30),
              ),
            ),
          ),
          if (_user != null)
            Expanded(
              child: _user != null
                  ? FriendList(userId: _user!.userId, currentUser: _user!)
                  : Center(child: Text('Загрузка данных пользователя...')),
            ),
          if (_user == null)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  set user(User value) {
    setState(() {
      _user = value;
    });
  }

  @override
  set post(Post? value) {
    setState(() {
      _post = value;
      if (value != null) {
        _loadPostScreenData();
      }
    });
  }

  @override
  void updateLoadingState(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  @override
  User get user => _user!;

  @override
  Post? get post => _post;
}

class FriendList extends StatefulWidget {
  final int userId;
  final User currentUser;

  FriendList({required this.userId, required this.currentUser});

  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  List<User> _friends = [];
  Map<int, Post> _friendToLatestTodayPost = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendsAndPosts();
  }

  Future<void> _loadFriendsAndPosts() async {
    final token = await getToken();
    if (token != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final List<dynamic> friendsData = await loadFriends(context, widget.userId);
        final friends = friendsData.map((json) => User.fromJson(json)).toList();

        final now = DateTime.now();
        final todayStr = DateFormat('yyyy-MM-dd').format(now);
        final allFriendsPosts = await getIt<PostsRepository>().getFriendsPosts(widget.userId);
        final todayPosts = allFriendsPosts.where((p) =>
            DateFormat('yyyy-MM-dd').format(p.timestamp) == todayStr).toList();
        final Map<int, Post> friendToPost = {};
        for (var p in todayPosts) {
          if (!friendToPost.containsKey(p.userId)) {
            friendToPost[p.userId] = p;
          }
        }

        setState(() {
          _friends = friends;
          _friendToLatestTodayPost = friendToPost;
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading friends: $e');
        showErrorMessage('Ошибка при загрузке списка друзей: $e', context);
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Authentication()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (_friends.isEmpty) {
      return Center(
        child: Text(
          'No friends yet.',
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return _buildFriendList();
    }
  }

  Widget _buildFriendList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: _friends.length,
      itemBuilder: (context, i) {
        return _buildFriendRow(_friends[i]);
      },
    );
  }

  Widget _buildFriendRow(User friend) {
    final hasPostToday = _friendToLatestTodayPost.containsKey(friend.userId);
    final post = _friendToLatestTodayPost[friend.userId];

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        backgroundImage: friend.profilePic != null
            ? NetworkImage(friend.profilePic!)
            : AssetImage('assets/images/user_icon.jpg') as ImageProvider,
        radius: 18,
      ),
      title: Text(friend.username,
          style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
              fontFamily: "Raleway",
              fontWeight: FontWeight.w600)),
      trailing: hasPostToday
          ? GestureDetector(
              onTap: () {
                if (post != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FriendPostScreen(
                        currentUser: widget.currentUser,
                        friend: friend,
                        post: post,
                      ),
                    ),
                  );
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: AssetImage('assets/images/bell.png'),
                radius: 18,
              ),
            )
          : SizedBox(width: 36, height: 36),
    );
  }
}
