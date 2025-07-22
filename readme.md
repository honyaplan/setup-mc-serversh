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


## 📦 導入プラグイン一覧・解説

### BlueMap

* **概要**: MinecraftワールドをWebブラウザで3Dマップとして閲覧できるダイナミックマッププラグイン。地図は自動生成・更新され、URLを知っていれば誰でもアクセス可能。
* **公式**: [https://bluemap.bluecolored.de/](https://bluemap.bluecolored.de/)
* **配布元**: [Modrinth BlueMap](https://modrinth.com/plugin/bluemap)

- サーバー起動後、以下のURLでワールドを3Dマップとして閲覧できます：
    - `http://<サーバーIP>:8100/`
- ポート番号は `bluemap/webserver.conf` で変更できます
- ファイアウォールやルーターのポート開放設定も必要な場合があります
- 詳細・設定: https://bluemap.bluecolored.de/
- 
---

### Chunky

* **概要**: ワールド全域や一部を「事前レンダリング」しておくことで、後からプレイする人のチャンク生成ラグを抑えるツール。BlueMapやDynmap導入時の負荷軽減にも有効。
* **公式**: [https://github.com/pop4959/Chunky](https://github.com/pop4959/Chunky)
* **配布元**: [Modrinth Chunky](https://modrinth.com/plugin/chunky)

---

### Floodgate / Geyser

* **概要**:

  * **Geyser**: Java版サーバーにBedrock Edition（Switch/スマホ等）のクライアントがログインできるようにするプロキシサーバー。
  * **Floodgate**: Bedrockユーザーがマイクラ公式アカウント不要で参加できるようにする認証統合プラグイン（Geyserと併用）。
* **公式**: [https://geysermc.org/](https://geysermc.org/)
* **配布元**: [Geyser Releases](https://download.geysermc.org/), [Floodgate Releases](https://download.geysermc.org/)

---

### LuckPerms

* **概要**: サーバー内の権限・グループ管理の定番。GUIツールやコマンドでも設定可能。大規模サーバーでも安心の高性能パーミッションプラグイン。
* **公式**: [https://luckperms.net/](https://luckperms.net/)
* **配布元**: [LuckPerms Releases](https://luckperms.net/download)

---

### LunaChat

* **概要**: 日本語チャット/ローマ字変換や、チャンネル管理ができる国産チャット強化プラグイン。
* **公式**: [https://www.spigotmc.org/resources/lunachat.1615/](https://www.spigotmc.org/resources/lunachat.1615/)
* **導入方法**: 手動ダウンロード推奨（URL構造が変動するため）

---

### Multiverse ファミリー（Core / Inventories / NetherPortals / Portals / SignPortals）

* **概要**: 複数ワールド管理、ワールドごとのインベントリ分離、ネザーポータル同期、ワールド間ゲート、看板ゲート機能などを提供する定番マルチワールドプラグイン群。
* **配布元**: [Multiverse Core (Bukkit)](https://dev.bukkit.org/projects/multiverse-core) 他

---

### spark

* **概要**: サーバーのパフォーマンス計測・プロファイリング・タイミング解析のためのツール。
* **公式**: [https://spark.lucko.me/](https://spark.lucko.me/)
* **配布元**: [spark Releases](https://spark.lucko.me/download)

---

### TerraformGenerator

* **概要**: 超高品質な地形生成を行うワールドジェネレータ。独自のバイオームや地形が出現する「高難度サバイバル」にもおすすめ。
* **公式**: [https://github.com/Hex27/TerraformGenerator](https://github.com/Hex27/TerraformGenerator)
* **配布元**: [Modrinth TerraformGenerator](https://modrinth.com/plugin/terraformgenerator)

---

### ViaVersion / ViaBackwards

* **概要**: クライアント側のバージョン違い（下位/上位）でもサーバーに接続できるようにする互換系プラグイン。バージョンアップ時の「新旧混在」プレイにも必須。
* **公式**: [https://viaversion.com/](https://viaversion.com/)
* **配布元**: [ViaVersion Downloads](https://ci.viaversion.com/)

---

### Simple Voice Chat

* **概要**: サーバー内で「ボイスチャット」ができる人気プラグイン。
* **公式**: [https://modrepo.de/minecraft/voicechat](https://modrepo.de/minecraft/voicechat)
* **配布元**: [Modrinth Simple Voice Chat](https://modrinth.com/plugin/simple-voice-chat)

---

### WorldEdit

* **概要**: ワールド編集の超定番。大規模なブロック操作や範囲選択/複製/貼り付けなどを高速に実現。
* **公式**: [https://enginehub.org/worldedit/](https://enginehub.org/worldedit/)
* **配布元**: [WorldEdit (Bukkit)](https://dev.bukkit.org/projects/worldedit)

---

### その他

* 必要に応じて「plugins/」に独自jar追加、または古いサーバーから設定・データをコピーできます。

---

## 📝 プラグインの更新・追加について

* 配布元のURLやバージョンは時々変わるため、**公式やModrinth等で最新版を確認し、スクリプトを更新してください。**
* 「運用中に追加したい」場合は plugins ディレクトリに jar を手動で配置すればOKです。

---



---

