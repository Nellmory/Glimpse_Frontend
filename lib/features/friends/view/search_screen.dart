import 'dart:async';
import 'package:flutter/material.dart';
import 'package:glimpse/features/common/data/models.dart';
import 'package:glimpse/features/friends/domain/friend_entity.dart';
import 'package:glimpse/features/friends/domain/search_users.dart';
import 'package:glimpse/features/friends/domain/add_friend.dart';
import 'package:glimpse/features/common/domain/useful_methods.dart';

class SearchScreen extends StatefulWidget {
  final User user;

  const SearchScreen({Key? key, required this.user}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Friend> _searchResults = [];
  bool _isLoading = false;
  String _image = 'assets/images/add_friend.png';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future _friendManager(Friend friend) async {
    if (_image == 'assets/images/add_friend.png') {
      try {
        await addFriend(context, widget.user.userId, friend.userId);
        setState(() {
          _image = 'assets/images/remove_friend.png';
        });
      } catch (e) {
        showErrorMessage('Ошибка при добавлении в друзья', context);
      }
    } else {
      if (_image == 'assets/images/remove_friend.png') {
        try {
          //await removeFriend(context, friend.userId, widget.user.userId);
          setState(() {
            _image = 'assets/images/add_friend.png';
          });
        } catch (e) {
          showErrorMessage('Ошибка при удалении заявки', context);
        }
      }
    }
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchUsers(_searchController.text);
      } else {
        setState(() {
          _searchResults.clear();
        });
      }
    });
  }

  Future<void> _searchUsers(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final usersData = await searchUsers(context, query);
      setState(() {
        _searchResults = usersData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching users: $e');
      showErrorMessage('Ошибка при поиске: $e', context);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Поиск друзей',
          style: TextStyle(
            color: Colors.blueGrey[200],
            fontFamily: "Playball",
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.blueGrey[200]),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Поиск пользователей',
                labelStyle: TextStyle(color: Colors.blueGrey[200]),
                hintText: 'Введите никнейм...',
                hintStyle: TextStyle(color: Colors.blueGrey[600]),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.blueGrey[400],
                ),
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
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey[400]!),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Text(
          'Введите никнейм для поиска',
          style: TextStyle(
            color: Colors.blueGrey[400],
            fontSize: 20,
            fontFamily: "Raleway",
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'Пользователи не найдены',
          style: TextStyle(
            color: Colors.blueGrey[400],
            fontSize: 16,
            fontFamily: "Raleway",
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildFriendTile(_searchResults[index]);
      },
    );
  }

  Widget _buildFriendTile(Friend friend) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blueGrey[700]!,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: friend.profilePic != null
              ? NetworkImage(friend.profilePic!)
              : AssetImage('assets/images/user_icon.jpg') as ImageProvider,
          radius: 20,
        ),
        title: Text(
          friend.username ?? 'Unknown',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontFamily: "Raleway",
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: friend.status.isNotEmpty
            ? Text(
                friend.status,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blueGrey[100],
                  fontFamily: "Raleway",
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: InkWell(
          onTap: () => _friendManager(friend),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Image.asset(
              _image,
              width: 40,
              height: 40,
            ),
          ),
        ),
      ),
    );
  }
}
