# 🚀 DevOps Yolculuğu: 0'dan Cloud & Kubernetes'e

Welcome! Bu repo, Konfigürasyon Yönetim Uzmanlığı'ndan **Modern DevOps & Cloud Engineering** rolüne geçiş sürecimdeki tüm teorik notları, cheatsheet'leri ve hands-on uygulamaları içerir.

> 💡 **Not:** Dokümantasyon, her gün yapılan pratikler ve otomasyon script'leri ile düzenli olarak güncellenmektedir.

---

## 🗺️ Çalışma Yol Haritası

- [x] **Aşama 1: Linux Temelleri & Containerization**
  - [x] Day 1: Linux Sistem Yönetimi, Yetkilendirme & Monitoring Scripti
  - [ ] Day 2: Docker Engine Kurulumu & Container Yaşam Döngüsü
  - [ ] Day 3: Dockerfile Yazımı, Multi-Stage Build Mantığı
  - [ ] Day 4: Port Mapping & Container Networking
  - [ ] Day 5: Docker Volume & Persistence Structure
- [ ] **Aşama 2: CI/CD Pipeline Otomasyonu (Jenkins & SonarQube)**
- [ ] **Aşama 3: Infrastructure as Code (Terraform & Ansible)**
- [ ] **Aşama 4: Orchestration (Kubernetes & Helm)**

---

## 📅 Day 1: Linux Temelleri & Sistem Yönetimi

> 🎯 **Günün Amacı:** Linux ortamında terminal hakimiyeti kazanmak, dosya/yetki mantığını kavramak ve sistem kaynaklarını izleyen otomasyon script'ini yazmak.

### 📚 Özet Ders Notu

DevOps ekosisteminde sunucuların %90'ından fazlası Linux tabanlıdır. Konfigürasyon yönetiminden DevOps'a geçerken temel zihniyet değişimi şudur: **Sistemler arayüzden değil, kodla (Bash/Python) ve CLI komutlarıyla yönetilir.**

#### 1. Dosya Sistemi ve İzinler (`chmod` / `chown`)
Linux'ta her şey bir dosyadır. Yetkiler 3 ana grupta incelenir:
* **U**ser (Kullanıcı)
* **G**roup (Grup)
* **O**ther (Diğerleri)

Okuma ($4$), Yazma ($2$), Çalıştırma ($1$) değerleriyle ifade edilir.

* `chmod 755 script.sh` $\rightarrow$ Sahibi her şeyi yapar ($7$), diğerleri okur ve çalıştırır ($5$).
* `chmod 600 id_rsa` $\rightarrow$ Sadece sahibi okur/yazar ($6$). SSH anahtarları için güvenlik standardıdır.

#### 2. Network ve Port Dinleme
Bir servisin (Docker, Nginx, Jenkins vb.) ayakta olup olmadığını anlamak için portlarını kontrol ederiz:
* `ss -tulpn` veya `netstat -tulpn` komutu hangi portun hangi işlem (PID) tarafından dinlendiğini söyler.

---

### 🛠️ Quick Cheatsheet: En Çok Kullanılan Linux Komutları

| Komut | Açıklama | DevOps Kullanım Senaryosu |
| :--- | :--- | :--- |
| `mkdir -p devops/app` | İç içe klasör yapısı oluşturur | Proje dizinlerini tek hamlede kurmak için. |
| `chmod +x script.sh` | Dosyaya çalıştırılma yetkisi verir | Bash script'lerini koşturmadan önce şarttır. |
| `chown -R user:group dir` | Klasörün sahibini ve grubunu değiştirir | Docker veya Nginx izin sorunlarını çözmek için. |
| `find . -name "*.log"` | Belirtilen uzantılı dosyaları arar | Log temizliği veya analizlerinde kullanılır. |
| `grep -i "error" app.log` | Metin içinde harf duyarsız arama yapar | Container loglarında hızlı hata ayıklamak için. |
| `df -h` | Disk kullanımını insan formatında ($GB/MB$) gösterir | Disk dolup container'lar patlamasın diye. |
| `free -m` | RAM kullanımını $MB$ cinsinden gösterir | Bellek sızıntılarını tespit etmek için. |
| `curl -Iv localhost:8080` | Belirtilen adrese HTTP isteği atar | Servis canlılığını terminalden doğrulamak için. |

---

### 🧪 Hands-On Lab: Sistem Kontrol Script'i (`sys_check.sh`)

Sistem kaynaklarını ve aktif ağ durumunu kontrol eden Bash script'i:

```bash
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
```

#### Script'i Çalıştırma:
```bash
chmod +x day-01/sys_check.sh
./day-01/sys_check.sh
```
