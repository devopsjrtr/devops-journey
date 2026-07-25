# 🚀 DevOps Yolculuğu: 0'dan Cloud & Kubernetes'e

Bu repo, Konfigürasyon Yönetim Uzmanlığı'ndan **Modern DevOps & Cloud Engineering** rolüne geçiş sürecimdeki tüm teorik notları, cheatsheet'leri ve hands-on uygulamaları içerir.

> 💡 **Not:** Dokümantasyon, her gün yapılan pratikler ve otomasyon script'leri ile düzenli olarak güncellenmektedir.

---

## 🗺️ Çalışma Yol Haritası

- [x] **Aşama 1: Linux Temelleri & Containerization**
  - [x] Day 1: Linux Sistem Yönetimi, Yetkilendirme & Monitoring Scripti
  - [x] Day 2: Docker Engine Kurulumu & Container Yaşam Döngüsü
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
---

## 📅 Day 2: Docker Engine Kurulumu & Container Yaşam Döngüsü

> 🎯 **Günün Amacı:** Docker mimarisini anlamak, Ubuntu 24.04 (WSL2) üzerinde Docker Engine kurulumunu tamamlamak ve bir Nginx container'ının tüm yaşam döngüsünü CLI üzerinden yönetmek.

### 📚 Özet Ders Notu

* **Sanal Makine vs Container:** Sanal makineler ayrı işletim sistemleri (Guest OS) çalıştırarak donanım seviyesinde sanallaştırma yaparken, Container'lar Host işletim sisteminin çekirdeğini (Kernel) paylaşarak işletim sistemi seviyesinde izolasyon sağlar.
* **İmaj vs Container:** Image, uygulamanın çalışması için gereken tüm dosyaların salt-okunur (read-only) paket halidir. Container ise bu imajın bellekte çalışan (read-write katmanına sahip) canlı örneğidir.

---

### 🛠️ Quick Cheatsheet: Temel Docker Komutları

| Komut | Açıklama |
| :--- | :--- |
| `docker run -d -p 8080:80 --name web nginx` | Nginx imajından `web` adında, arka planda çalışan container oluşturur. |
| `docker ps` | Sadece aktif çalışan container'ları listeler. |
| `docker ps -a` | Durdurulmuş olanlar dahil tüm container'ları gösterir. |
| `docker logs -f web` | Container loglarını canlı olarak terminale basar. |
| `docker exec -it web bash` | Container içerisinde Shell oturumu açar. |
| `docker rm -f web` | Container'ı durdurur ve sistemden kaldırır. |

---

### 🧪 Hands-On Lab: Nginx Web Sunucusu Dağıtımı

1. **Docker Kurulum Sonu Testi:**
   ```bash
   docker run hello-world
   ```
2. **Nginx Container Çalıştırma & Doğrulama:**
   ```bash
   docker run -d --name my-web-server -p 8080:80 nginx
   curl -I http://localhost:8080
   ```
3. **Temizlik:**
   ```bash
   docker stop my-web-server && docker rm my-web-server
   ```
