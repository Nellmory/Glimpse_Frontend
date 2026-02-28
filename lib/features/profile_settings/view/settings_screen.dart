import 'package:flutter/material.dart';
import 'package:glimpse/features/authentication/view/authentication.dart';
import 'package:glimpse/features/common/data/models.dart';
import 'package:glimpse/features/common/domain/useful_methods.dart';
import 'package:glimpse/features/common/di/service_locator.dart';
import 'package:glimpse/features/authentication/domain/token_manager.dart';
import 'package:glimpse/features/home/data/home_page_repository.dart';
import 'package:glimpse/features/profile_settings/view/set_status_screen.dart';
import 'package:glimpse/features/common/data/api_client.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class Settings extends StatefulWidget {
  final User user;
  final void Function(String newProfilePicUrl)? onAvatarUpdated;

  const Settings({Key? key, required this.user, this.onAvatarUpdated}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late String _status;
  String _selectedLanguage = 'Русский';
  String? _profilePicUrl;
  bool _avatarUploading = false;

  static final _homeRepo = getIt<HomePageRepository>();
  static const _baseUrl = ApiClient.baseUrl;

  String? get _avatarDisplayUrl =>
      _profilePicUrl ?? _buildProfilePicUrl(widget.user.profilePic);

  static String? _buildProfilePicUrl(String? relativeOrFull) {
    if (relativeOrFull == null || relativeOrFull.isEmpty) return null;
    if (relativeOrFull.startsWith('http')) return relativeOrFull;
    return '$_baseUrl/images/$relativeOrFull';
  }

  @override
  void initState() {
    super.initState();
    _status = widget.user.status.isEmpty
        ? 'Здесь пусто...Добавьте статус!'
        : widget.user.status;
  }

  Future<void> _changeAvatar() async {
    if (_avatarUploading) return;
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null || !mounted) return;
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: xFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 85,
      compressFormat: ImageCompressFormat.jpg,
    );
    if (croppedFile == null || !mounted) return;
    setState(() => _avatarUploading = true);
    try {
      final relativePath = await _homeRepo.uploadAvatar(widget.user.userId, croppedFile.path);
      final newUrl = '$_baseUrl/images/$relativePath';
      if (mounted) {
        setState(() {
          _profilePicUrl = newUrl;
          _avatarUploading = false;
        });
        widget.onAvatarUpdated?.call(newUrl);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _avatarUploading = false);
        showErrorMessage(
          e.toString().contains('403') ? 'Нельзя изменить чужой аватар' : 'Ошибка загрузки аватарки',
          context,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings',
            style: TextStyle(
                color: Colors.blueGrey[200],
                fontFamily: "Playball",
                fontSize: 30)),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height -
              AppBar().preferredSize.height -
              MediaQuery.of(context).padding.top,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // Выравнивание вверху
              crossAxisAlignment: CrossAxisAlignment.center,
              // Центрирование по горизонтали
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _avatarDisplayUrl != null
                      ? NetworkImage(_avatarDisplayUrl!)
                      : AssetImage('assets/images/user_icon.jpg') as ImageProvider,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _avatarUploading ? null : _changeAvatar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    // Цвет фона кнопки
                    foregroundColor: Colors.white,
                    // Цвет текста кнопки
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    textStyle: TextStyle(
                        fontSize: 16,
                        fontFamily: "Raleway",
                        fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(_avatarUploading ? 'Загрузка...' : 'Сменить аватарку'),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Статус:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SetStatusScreen(
                                currentStatus: widget.user.status,
                                user: widget.user,
                                onStatusUpdated: (newStatus) {
                                  setState(() {
                                    _status = newStatus;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[900],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _status,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: "Raleway",
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Icon(
                                Icons.edit,
                                color: Colors.blueGrey[400],
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Язык:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[900],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: DropdownButton<String>(
                          dropdownColor: Colors.blueGrey[900],
                          value: _selectedLanguage,
                          items: <String>['Русский', 'Английский']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Raleway",
                                      fontWeight: FontWeight.w600)),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedLanguage = newValue!;
                            });
                          },
                          style: TextStyle(color: Colors.white),
                          underline: Container(),
                          // Убираем подчеркивание
                          isExpanded: true, // Занимает всю доступную ширину
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await deleteToken();
                      // После удаления токена перенаправляем на экран авторизации
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Authentication()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      // Красный цвет для кнопки выхода
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      textStyle: TextStyle(
                          fontSize: 16,
                          fontFamily: "Raleway",
                          fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Выйти из профиля'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
