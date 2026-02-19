import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';

/// 分享服务
class ShareService {
  /// 分享图片
  Future<void> shareImage(Uint8List imageBytes, {String? text}) async {
    // 创建临时文件
    final tempFile = XFile.fromData(
      imageBytes,
      name: 'gogozzz_share.png',
      mimeType: 'image/png',
    );

    // 分享
    await Share.shareXFiles(
      [tempFile],
      text: text ?? '我的睡眠记录 - GoGoZzz',
    );
  }

  /// 分享纯文本
  Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
