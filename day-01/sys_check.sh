#!/bin/bash

echo "=========================================="
echo "    DEV-OPS SİSTEM KONTROL RAPORU         "
echo "=========================================="
echo "Tarih: $(date)"
echo "Kullanıcı: $USER"
echo "------------------------------------------"

echo -e "\n1. DISK KULLANIMI:"
df -h / | awk 'NR==1 || NR==2'

echo -e "\n2. BELLEK (RAM) KULLANIMI (MB):"
free -m

echo -e "\n3. AKTİF NETWORK DİNLENEN PORTLAR:"
ss -tulpn | grep LISTEN || echo "Dinlenen port bulunamadı veya ss yetkisi eksik."

echo "=========================================="
