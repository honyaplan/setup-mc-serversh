#!/bin/bash
set -e

VERSION="1.21.8"
INSTALL_DIR="$HOME/minecraft"
PLUGINS_DIR="$INSTALL_DIR/plugins"
JAR_LINK="paper.jar"

echo "[1/6] Java 21 (Adoptium) リポジトリ登録"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/adoptium.gpg > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb bookworm main" \
  | sudo tee /etc/apt/sources.list.d/adoptium.list

echo "[2/6] パッケージ情報更新 & jq/curl/Java 21インストール"
sudo apt update
sudo apt install -y jq curl temurin-21-jre

echo "[3/6] Minecraftディレクトリ作成"
mkdir -p "$PLUGINS_DIR"
cd "$INSTALL_DIR" || exit 1

echo "[4/6] PaperMC最新ビルド取得"
BUILD=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${VERSION}" | jq -r '.builds[-1]')
JAR_NAME="paper-${VERSION}-${BUILD}.jar"
DL_URL="https://api.papermc.io/v2/projects/paper/versions/${VERSION}/builds/${BUILD}/downloads/${JAR_NAME}"
curl -Lo "$JAR_NAME" "$DL_URL"
ln -sf "$JAR_NAME" "$JAR_LINK"

echo "[5/6] EULA同意ファイル生成"
if [ ! -f eula.txt ]; then
  echo "eula=true" > eula.txt
fi

echo "[6/6] プラグイン自動導入"
cd "$PLUGINS_DIR"

# BlueMap
curl -LO "$(curl -s https://api.modrinth.com/v2/project/bluemap/version | jq -r '[.[] | select(.version_type=="release")][0].files[] | select(.filename | test("paper.*\\.jar$")).url')" \
  && ls -t bluemap-*-paper.jar | head -1 | xargs -I{} ln -sf {} BlueMap.jar

# Chunky
curl -LO "$(curl -s https://api.modrinth.com/v2/project/chunky/version | jq -r '[.[] | select(.version_type=="release")][0].files[] | select(.filename | test("Bukkit.*\\.jar$")).url')" \
  && ls -t Chunky-Bukkit-*.jar | head -1 | xargs -I{} ln -sf {} Chunky.jar

# Floodgate
curl -LOJ https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot \
  && ls -t floodgate-*.jar | head -1 | xargs -I{} ln -sf {} Floodgate.jar

# Geyser
curl -LOJ https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot \
  && ls -t Geyser-Spigot*.jar | head -1 | xargs -I{} ln -sf {} Geyser.jar

# LuckPerms
curl -LO https://ci.lucko.me/job/LuckPerms/lastSuccessfulBuild/artifact/bukkit/build/libs/LuckPerms-Bukkit.jar

# LunaChat（要手動DL）
echo "[INFO] LunaChat（日本語チャット拡張）は https://www.spigotmc.org/resources/lunachat.1615/ から手動でダウンロードし、$PLUGINS_DIR へ配置してください"

# Multiverse-Core
curl -LOJ https://dev.bukkit.org/projects/multiverse-core/files/latest
ls -t MultiverseCore-*.jar | head -1 | xargs -I{} ln -sf {} Multiverse-Core.jar

# Multiverse-Inventories
curl -LOJ https://dev.bukkit.org/projects/multiverse-inventories/files/latest
ls -t Multiverse-Inventories-*.jar | head -1 | xargs -I{} ln -sf {} Multiverse-Inventories.jar

# Multiverse-NetherPortals
curl -LOJ https://dev.bukkit.org/projects/multiverse-netherportals/files/latest
ls -t Multiverse-NetherPortals-*.jar | head -1 | xargs -I{} ln -sf {} Multiverse-NetherPortals.jar

# Multiverse-Portals
curl -LOJ https://dev.bukkit.org/projects/multiverse-portals/files/latest
ls -t Multiverse-Portals-*.jar | head -1 | xargs -I{} ln -sf {} Multiverse-Portals.jar

# Multiverse-SignPortals
curl -LOJ https://dev.bukkit.org/projects/multiverse-signportals/files/latest
ls -t Multiverse-SignPortals-*.jar | head -1 | xargs -I{} ln -sf {} Multiverse-SignPortals.jar

# spark
curl -LO https://ci.lucko.me/job/spark/lastSuccessfulBuild/artifact/spark-bukkit/build/libs/spark.jar

# TerraformGenerator
curl -LO "$(curl -s https://api.modrinth.com/v2/project/terraformgenerator/version | jq -r '[.[] | select(.version_type=="release")][0].files[] | select(.filename | test("TerraformGenerator.*\\.jar$")).url')" \
  && ls -t TerraformGenerator-*.jar | head -1 | xargs -I{} ln -sf {} TerraformGenerator.jar

# ViaBackwards
curl -LO https://ci.viaversion.com/job/ViaBackwards/lastSuccessfulBuild/artifact/build/libs/ViaBackwards.jar

# ViaVersion
curl -LO https://ci.viaversion.com/job/ViaVersion/lastSuccessfulBuild/artifact/build/libs/ViaVersion.jar

# voicechat
curl -LO "$(curl -s https://api.modrinth.com/v2/project/simple-voice-chat/version | jq -r '[.[] | select(.version_type=="release")][0].files[] | select(.filename | test("bukkit.*\\.jar$")).url')" \
  && ls -t voicechat-bukkit-*.jar | head -1 | xargs -I{} ln -sf {} VoiceChat.jar

# WorldEdit
curl -LOJ https://dev.bukkit.org/projects/worldedit/files/latest
ls -t WorldEdit-*.jar | head -1 | xargs -I{} ln -sf {} WorldEdit.jar

echo
echo "[セットアップ完了]"
java -version
echo
echo "■ PaperMCディレクトリ: $INSTALL_DIR"
echo "■ plugins ディレクトリ: $PLUGINS_DIR"
echo "■ 起動例:"
echo "  cd $INSTALL_DIR"
echo "  java -Xmx4G -jar $JAR_LINK nogui"
