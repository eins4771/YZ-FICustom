import './style.css';

const app = document.querySelector<HTMLElement>('#app');
if (!app) throw new Error('Application mount point is missing.');

app.innerHTML = `
  <header>
    <p class="eyebrow">ESP32 ECU / WEB</p>
    <h1>YZ-FICustom</h1>
    <p class="intro">Wi-Fiで使うECU設定画面の開発用スターターです。</p>
    <p class="status"><span aria-hidden="true"></span>ECU 未接続</p>
  </header>
  <section class="features" aria-label="今後開発する機能">
    <article><p class="number">01</p><h2>MAP</h2><p>燃料・点火MAPの読出し、編集、書込み。</p><span class="tag">未実装</span></article>
    <article><p class="number">02</p><h2>ファームウェア</h2><p>対応する更新ファイルの選択とOTA更新。</p><span class="tag">未実装</span></article>
    <article><p class="number">03</p><h2>データ・ログ</h2><p>運転データの表示、記録、ダウンロード。</p><span class="tag">未実装</span></article>
  </section>
  <aside>
    <strong>開発環境の確認用画面です。</strong>
    <p>現在はESP32への通信、MAPの書込み、OTA更新を行いません。実機に接続する前に、通信仕様・認証・更新の復旧方法を実装します。</p>
  </aside>
  <footer>Flutterアプリと共通のECU通信仕様を使用する予定です。<span id="build-mode"></span></footer>
`;

const buildMode = document.querySelector('#build-mode');
if (buildMode) buildMode.textContent = import.meta.env.DEV ? ' 開発サーバーで表示中' : ' 静的ビルド';
