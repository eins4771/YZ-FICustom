import 'package:flutter/material.dart';

void main() {
  runApp(const YzFICustomApp());
}

class YzFICustomApp extends StatelessWidget {
  const YzFICustomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YZ-FICustom',
      theme: ThemeData(colorSchemeSeed: Colors.teal),
      home: Scaffold(
        appBar: AppBar(title: const Text('YZ-FICustom')),
        body: const SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESP32 ECU / MOBILE'),
                  SizedBox(height: 16),
                  Text('ECU 未接続', style: TextStyle(fontSize: 24)),
                  SizedBox(height: 24),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.grid_on),
                    title: Text('MAP'),
                    subtitle: Text('読出し・編集・書込み（未実装）'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.system_update),
                    title: Text('ファームウェア'),
                    subtitle: Text('更新ファイルの転送・OTA（未実装）'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.show_chart),
                    title: Text('データ・ログ'),
                    subtitle: Text('表示・記録・ダウンロード（未実装）'),
                  ),
                  SizedBox(height: 24),
                  Text('開発環境の確認用画面です。現在は実機への通信・書込みを行いません。'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
