# ESP32ファームウェア

PlatformIO / Arduinoを使う最小のビルド用スターターです。シリアルに起動メッセージを出すだけで、噴射・点火・その他のGPIO出力、Wi-Fi、BLE、OTA、Web配信は実装していません。

## ボード設定

`platformio.ini` の `esp32dev` は**汎用の仮設定**です。実際のESP32モジュール名、ボード、Flash容量が決まり次第、`board` とパーティション構成を変更してください。ESP32-S3/C3などには、そのまま流用できません。

OTA用の複数アプリ領域、MAP保存領域、Web UI領域、ログ保存領域の構成は実機に合わせて別途決定します。現在の設定は更新・復旧を保証するものではありません。

## ビルド

VS CodeでこのフォルダーをPlatformIOプロジェクトとして開くか、PlatformIO CLIを使用します。

```powershell
cd firmware
pio run -e esp32dev
```

このコマンドはビルドのみです。実機への書込みは行いません。PlatformIOが初回にツールチェーンとArduinoフレームワークを取得します。

## Web UIファイル

```powershell
cd web
npm run build:esp32
```

リポジトリ直下から上のコマンドを実行すると、Web UIの成果物が `firmware/data/www/` に配置されます。`board_build.filesystem = littlefs` は将来のファイルシステム作成用の設定ですが、現時点のファームウェアはLittleFSのマウント・静的ファイルの配信を行いません。

型番・パーティション・復旧方法を決定し、配信処理を実装した後に、実機へのファームウェア／ファイルシステム書込み手順を追加します。
