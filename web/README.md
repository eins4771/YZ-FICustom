# ESP32向けWeb UI

Flutterアプリとは別に、ESP32から配信する軽量なHTML/CSS/TypeScriptの開発環境です。外部CDN・外部フォントに依存せず、ビルド後は静的ファイルになります。

現時点では開発用の起動画面のみです。ECU通信、MAP操作、OTA、ログ取得は未実装で、画面の数値や接続状態を実機データとして表示しません。

## 開発

Node.js 22.12以降を使用します。このPCではNode.js 24系を利用できます。

```powershell
cd web
npm install
npm run dev
```

表示されたローカルURLをブラウザで開きます。開発サーバーは既定で `127.0.0.1` にのみ接続を受け付けます。

```powershell
npm run check       # TypeScriptの型検査
npm run build       # 型検査と静的ビルド: dist/
npm run preview     # 静的ビルドをPC上で確認
npm run build:esp32 # ビルドして ../firmware/data/www/ に配置
```

`build:esp32` はファイルをコピーするだけで、接続されたESP32への書込みは行いません。配置先の既存ファイルは削除しません。今後アセット構成を変更したときは、古い生成ファイルが残っていないか確認します。

## 次の実装

- Flutterアプリと共有するHTTP/WebSocket通信仕様を定義する。
- ESP32側で `firmware/data/www/` の静的ファイルを配信する。
- 接続・認証、MAP検証と確定、時刻付きログ、OTA検証と復旧を実装する。
- 実機のFlash容量とOTA用パーティションに合わせて、Webアセットの容量を確認する。

Web UI自体にはBLEを使いません。スマホがESP32のWi-Fiネットワークに接続し、ブラウザで操作する方式を予定しています。
