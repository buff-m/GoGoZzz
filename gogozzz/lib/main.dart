import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库
  await DatabaseService.instance.database;

  runApp(
    const ProviderScope(
      child: GoGoZzzAppWrapper(),
    ),
  );
}

/// 应用包装器
class GoGoZzzAppWrapper extends StatelessWidget {
  const GoGoZzzAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return GoGoZzzApp();
  }
}
