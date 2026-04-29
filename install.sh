#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${TARGET_DIR:-/usr/local/bin}"
TARGET_MAIN="$TARGET_DIR/codex-switch"
TARGET_ALIAS="$TARGET_DIR/sw"
DEFAULT_BASE_URL="https://raw.githubusercontent.com/liut-coder/codex-switch/main"
DOWNLOAD_BASE_URL="${CODEX_INSTALL_BASE_URL:-$DEFAULT_BASE_URL}"
TMP_SOURCE=""

log() {
    printf "%s\n" "$1"
}

require_file() {
    [[ -f "$1" ]] || {
        printf "缺少文件: %s\n" "$1" >&2
        exit 1
    }
}

install_file() {
    local src="$1"
    local dst="$2"

    if install -m 755 "$src" "$dst" 2>/dev/null; then
        return 0
    fi

    sudo install -m 755 "$src" "$dst"
}

cleanup() {
    if [[ -n "$TMP_SOURCE" && -f "$TMP_SOURCE" ]]; then
        rm -f "$TMP_SOURCE"
    fi
}

resolve_source_script() {
    local local_source="$SCRIPT_DIR/codex-switch.sh"

    if [[ -f "$local_source" ]]; then
        printf "%s\n" "$local_source"
        return 0
    fi

    TMP_SOURCE="$(mktemp /tmp/codex-switch.XXXXXX)"
    curl -fsSL "$DOWNLOAD_BASE_URL/codex-switch.sh" -o "$TMP_SOURCE"
    chmod +x "$TMP_SOURCE"
    printf "%s\n" "$TMP_SOURCE"
}

main() {
    trap cleanup EXIT
    local source_script
    source_script="$(resolve_source_script)"
    require_file "$source_script"
    mkdir -p "$TARGET_DIR"

    log "安装 Codex 配置管理脚本..."
    install_file "$source_script" "$TARGET_MAIN"
    install_file "$source_script" "$TARGET_ALIAS"

    log "安装完成:"
    log "  $TARGET_MAIN"
    log "  $TARGET_ALIAS"
    log ""
    log "可用命令:"
    log "  codex-switch"
    log "  sw"
}

main "$@"
