import 'package:flutter/material.dart';

import '../data/api_client.dart';

const String _defaultAvatarAsset = 'assets/images/user_icon.jpg';

/// Возвращает полный URL аватарки: если [profilePic] уже http — как есть,
/// иначе собирает из [baseUrl]. Если [profilePic] пустой — null.
String? getProfilePicUrl(String? profilePic, [String? baseUrl]) {
  final base = baseUrl ?? ApiClient.baseUrl;
  if (profilePic == null || profilePic.isEmpty) return null;
  if (profilePic.startsWith('http')) return profilePic;
  return '$base/images/$profilePic';
}

/// Возвращает [ImageProvider] для аватарки: [NetworkImage] по полному URL
/// или заглушка [AssetImage]. [baseUrl] по умолчанию из [ApiClient].
ImageProvider getProfilePicImageProvider(String? profilePic, [String? baseUrl]) {
  final url = getProfilePicUrl(profilePic, baseUrl);
  if (url == null) return const AssetImage(_defaultAvatarAsset);
  return NetworkImage(url);
}
