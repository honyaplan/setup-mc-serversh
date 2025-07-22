了解です！
**Minecraft Paperサーバー自動セットアップ＋systemd運用用のREADMEサンプル**を用意しました。
このまま `README.md` にコピペしてOKです。
（内容はあなたの構成・手順をベースに具体的・実践的にしています）

---

## 📘 README: PaperMC サーバー自動構築・運用手順

---

### 概要

このプロジェクトは、Debian系サーバー上で**PaperMC (1.21.8)** サーバーを自動セットアップし、主要プラグインを最新版で自動導入、さらに systemd サービスとして安定運用するためのスクリプト・設定例です。

---

### セットアップ手順

#### 1. **セットアップスクリプトのダウンロード＆実行**

```bash
curl -O https://your.repo.or.gist/setup-mc-server.sh   # ←ご自身の設置先URL
chmod +x setup-mc-server.sh
./setup-mc-server.sh
```

> スクリプトが行うこと：
>
> * Java 21（Adoptium）リポジトリの追加＋インストール
> * PaperMC本体の最新版ダウンロード
> * `plugins` ディレクトリに主要プラグイン自動導入（BlueMap, LuckPerms, Geyser, Multiverse, spark等）
> * eula.txt 自動作成
> * 各種プラグインjarの自動リネーム・シンボリックリンク化
>   ※ LunaChat は手動導入が必要

---

#### 2. **LunaChat だけは手動でDLしてください**

* 公式: [https://www.spigotmc.org/resources/lunachat.1615/](https://www.spigotmc.org/resources/lunachat.1615/)
* `minecraft/plugins/` に配置

---

#### 3. **systemdサービスの登録**

1. `/etc/systemd/system/minecraft-server.service` を作成し、以下を記入：

   ```ini
   [Unit]
   Description=Minecraft PaperMC Server
   After=network.target

   [Service]
   User=honya
   WorkingDirectory=/home/honya/minecraft
   ExecStart=/usr/bin/java -Xmx4G -jar paper.jar nogui
   Restart=on-failure
   RestartSec=10
   SuccessExitStatus=0 143
   StandardOutput=journal
   StandardError=journal

   [Install]
   WantedBy=multi-user.target
   ```

2. 有効化＆起動

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable minecraft-server
   sudo systemctl start minecraft-server
   ```

---

#### 4. **バックアップや旧サーバーからのデータ移行**

* 必要なら `/home/honya/minecraft/` 以下の `world/`, `plugins/`, `config` などを旧サーバーから `rsync` 等でコピーしてください。

---

### よくある運用コマンド

| 操作          | コマンド例                                                |
| ----------- | ---------------------------------------------------- |
| サーバー起動      | `sudo systemctl start minecraft-server`              |
| サーバー停止      | `sudo systemctl stop minecraft-server`               |
| サーバー再起動     | `sudo systemctl restart minecraft-server`            |
| サーバーステータス確認 | `systemctl status minecraft-server`                  |
| ログ確認        | `journalctl -u minecraft-server -e`                  |
| 手動起動        | `cd ~/minecraft && java -Xmx4G -jar paper.jar nogui` |

---

### 注意点

* **`User`と`WorkingDirectory`は必ずご自身のユーザー名・ディレクトリに合わせて変更してください**
* プラグインの互換性やバージョン、PaperMC側の仕様変更は各自で定期的にご確認ください
* Java 21 環境が必須です（スクリプトで自動導入）

---

### 参考リンク

* [PaperMC 公式](https://papermc.io/)
* [Modrinth プラグイン配布](https://modrinth.com/)
* [SpigotMC Plugin一覧](https://www.spigotmc.org/resources/)
* [Geyser/Floodgate](https://geysermc.org/)

---

### 著作権等

* 各プラグイン・サーバー本体のライセンスは配布元に準じます。

---

> スクリプトや systemd 設定例などカスタマイズ自由です。
> 不明点や追加したい項目があれば追記・ご相談ください！

---

必要に応じて細かくアレンジ・追記もサポートします。
**`setup-mc-server.sh`の最新内容**と一緒に運用してご利用ください！
