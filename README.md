# YZ-FICustom

ESP32を使う自作ECU向けの開発リポジトリです。スマホアプリと、ESP32から配信するブラウザ用画面を並行して開発します。

| フォルダー | 用途 | 開発環境 |
| --- | --- | --- |
| `mobile/` | Android・iOS用スマホアプリ | Flutter / Dart |
| `web/` | ESP32配信用の軽量Web画面 | TypeScript / Vite |
| `firmware/` | ESP32ファームウェア | PlatformIO / Arduino |
| `docs/` | 共通通信仕様・開発手順 | Markdown |
| `tools/` | Windows環境の設定用スクリプト | PowerShell |

現時点は開発を始めるための初期構成です。実機への接続、MAP読書き、データ取得、OTA更新はまだ実装していません。

## 開発を始める

`YZ-FICustom.code-workspace`をVS Codeで開きます。SDK導入やPATH変更後は、VS Codeとターミナルを再起動してください。

### スマホアプリ

```powershell
cd mobile
flutter pub get
flutter devices
flutter run
```

Android実機を使う場合は、端末の開発者向けオプションとUSBデバッグを有効にします。iOSのビルド・署名・実機デバッグにはMacとXcodeが必要です。BLEとWi-Fiの権限・バックグラウンド動作は両OSの実機で確認します。

### ブラウザ用画面

```powershell
cd web
npm ci
npm run dev
```

開発サーバーはPCの`http://127.0.0.1:5173`で開きます。`npm run build:esp32`で生成ファイルを`firmware/data/www/`に配置します。このコマンドは実機へ書き込みません。ESP32側のファイル配信は今後実装します。

### ESP32ファームウェア

```powershell
cd firmware
platformio run
```

`esp32dev`はコンパイル確認用の仮ボードです。使用するESP32の型番、Flash容量、OTAとLittleFSのパーティション構成を決定してから実機用設定を確定します。初期ファームウェアはシリアルへの起動表示のみです。

## WindowsのSDK設定を再実行する場合

Git、公式Flutter安定版、Node.js、PythonをインストールしたPCで実行します。Android Studio同梱JDKがない場合は公式Eclipse Temurin JDK 21をユーザーフォルダーへ導入します。SDKの取得、Android SDKライセンスの承諾、ユーザー環境変数の設定を行います。内容を確認してから実行してください。

```powershell
powershell -ExecutionPolicy Bypass -File tools/configure-windows.ps1
powershell -ExecutionPolicy Bypass -File tools/setup-platformio.ps1
flutter doctor -v
```

既定のSDK保存先は`%USERPROFILE%\develop\flutter`、Android SDKは`%LOCALAPPDATA%\Android\Sdk`です。SDK本体、ビルド成果物、端末固有設定、署名鍵、Wi-Fi認証情報はGitへ登録しません。

## 今後共有する通信仕様

スマホアプリとWeb画面は、ESP32の同じHTTP / WebSocket APIを利用する方針です。BLEはスマホアプリ用の追加トランスポートとして扱います。詳細は[通信設計のメモ](docs/architecture.md)に記載します。
