# 🚀 DevOps Yolculuğu: 0'dan Cloud & Kubernetes'e

Bu repo, kişisel Devops çalışmalarıma ait tüm teorik notları, cheatsheet'leri ve hands-on uygulamaları içerir.

> 💡 **Not:** Dokümantasyon, her gün yapılan pratikler ve otomasyon script'leri ile düzenli olarak güncellenmektedir.

---

## 🗺️ Çalışma Yol Haritası

- [x] **Aşama 1: Linux Temelleri & Containerization**
  - [x] Day 1: Linux Sistem Yönetimi, Yetkilendirme & Monitoring Scripti
  - [x] Day 2: Docker Engine Kurulumu & Container Yaşam Döngüsü
  - [x] Day 3: Dockerfile Yazımı, Multi-Stage Build Mantığı
  - [x] Day 4: Port Mapping & Container Networking
  - [x] Day 5: Docker Volume & Persistence Structure
  - [x] Day 6: Docker Compose & Compose Yaml Oluşturma
- [x] **Aşama 2: CI/CD Pipeline Otomasyonu (Jenkins & SonarQube)**
  - [x] Day 7: Docker Container'a Jenkins & SonarQube Kurulumu
  - [ ] Day 8: Jenkins & SonarQube İletişimini Kurma ve Pipeline Oluşturma
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

   ---

## 📅 Day 3: Custom Dockerfile Yazımı & Python App Paketleme

> 🎯 **Günün Amacı:** `Dockerfile` talimatlarını öğrenmek, katman (layer) önbellekleme (cache) mantığını kavrayarak hafif ve optimize edilmiş bir Python/Flask container imajı inşa etmek.

### 📚 Özet Ders Notu

* **Dockerfile Mantığı:** Uygulama kodunun, çalışma zamanı (runtime) bağımlılıklarının ve başlatma komutlarının bildirildiği bildirimsel (declarative) bir yapılandırma dosyasıdır.
* **Build Önbelleği (Cache Optimization):** Docker, değişmeyen komutları önbellekten okur. Sık değişen kod satırları (`COPY . .`) en altlara, bağımlılık kurulumları (`RUN pip install`) üstlere konularak build süreçleri hızlandırılır.

---

### 🛠️ Quick Cheatsheet: Dockerfile Talimatları

| Talimat | İşlevi |
| :--- | :--- |
| `FROM` | Taban işletim sistemi veya runtime imajını seçer. |
| `WORKDIR` | İzleyen komutların çalışacağı dizini belirler. |
| `COPY` | Yerel sistemden dosya/klasör kopyalar. |
| `RUN` | Build anında komut çalıştırır (paket kurulumları vs.). |
| `ENV` | Ortam değişkeni (Environment Variable) tanımlar. |
| `CMD` | Container başladığında çalışacak ana süreci (process) belirler. |

---

### 🧪 Hands-On Lab: Python/Flask Web App Containerization

1. **Dockerfile:**
   ```dockerfile
   FROM python:3.9-slim
   WORKDIR /app
   COPY requirements.txt .
   RUN pip install --no-cache-dir -r requirements.txt
   COPY . .
   ENV APP_VERSION=v1.0
   EXPOSE 5000
   CMD ["python", "app.py"]
   ```

2. **Build & Run Komutları:**
   ```bash
   # İmajı build et
   docker build -t my-python-app:v1.0 .

   # Container'ı çalıştır
   docker run -d --name flask-app -p 5001:5000 my-python-app:v1.0

   # Test et
   curl http://localhost:5001
   ```

---

## 📅 Day 4: Port Mapping & Container Networking

> 🎯 **Günün Amacı:** Container port yönlendirmesini anlamak, Docker ağ tiplerini incelemek ve özel bir bridge ağı (User-Defined Bridge) üzerinde App-Database container iletişimini sağlamak.

### 📚 Özet Ders Notu

* **Port Mapping (`-p HOST:CONTAINER`):** Container'ın dış dünyaya kapatılmış portunu, Host işletim sisteminin belirli bir portuna bağlayarak dış erişime açar.
* **Varsayılan Bridge vs Özel Bridge:** Varsayılan `bridge` ağında container'lar birbirini sadece IP adresi üzerinden bulabilir. `docker network create` ile oluşturulan **Özel Bridge** ağlarında ise gömülü Docker DNS sunucusu sayesinde container'lar **birbirlerine isimleriyle (Container Name)** ulaşabilir.

---

### 🛠️ Quick Cheatsheet: Docker Network Komutları

| Komut | Açıklama |
| :--- | :--- |
| `docker network ls` | Mevcut ağları gösterir. |
| `docker network create <net-name>` | Özel bir izolasyon ağı oluşturur. |
| `docker run --net <net-name>` | Container'ı belirtilen ağda başlatır. |
| `docker network inspect <net-name>` | Ağdaki bağlı cihazları ve IP dağılımlarını listeler. |

---

### 🧪 Hands-On Lab: Python Web App + Redis DB İletişimi

1. **Özel Ağ Oluşturma & Redis Ayağa Kaldırma:**
   ```bash
   docker network create devops-net
   docker run -d --name redis-db --net devops-net redis:alpine
   ```

2. **Web Uygulamasını Bağlama & Test:**
   ```bash
   docker build -t counter-app:v1 .
   docker run -d --name web-app --net devops-net -p 8081:5000 counter-app:v1
   
   # Test (Sayaç her cURL isteğinde artar)
   curl http://localhost:8081
   ```

3. **DNS İletişim Doğrulaması:**
   ```bash
   docker exec -it web-app ping -c 2 redis-db
   ```

---

## 📅 Day 5: Docker Volume & State Persistence

> 🎯 **Günün Amacı:** Container'ların durumsuz (stateless) yapısını kavrayarak, uygulama verilerini veya loglarını Named Volume mekanizması ile container yaşam döngüsünden bağımsız hale getirmek.

### 📚 Özet Ders Notu

* **Ephemeral Nature:** Container'lar geçicidir. `docker rm` komutu çalıştırıldığında container içindeki katmanlarda oluşan tüm veriler kaybolur.
* **Named Volumes:** Docker daemon tarafından yönetilen, silinmeyen ve container'lar arası veri paylaşımını sağlayan en güvenli kalıcı depolama yöntemidir.

#### 💡 Arka Planda Ne Oluyor?

`-v app-log-data:/app/logs` komutunu çalıştırdığında Docker aslında şunu yapar:

1. Linux işletim sisteminde (WSL2 / Ubuntu içerisinde) varsayılan olarak `/var/lib/docker/volumes/app-log-data/_data` şeklinde fiziksel bir klasör oluşturur.
2. Container başlatılırken, container içindeki `/app/logs` dizinini Linux makinandaki bu `_data` dizinine **bağlar (mount eder)**.

**Dolayısıyla;**
* Container içerisinde uygulama `/app/logs/access.log` dosyasına yeni bir satır yazdığında, o dosya anında ve eş zamanlı olarak senin Linux sunucundaki bu fiziksel klasörün içine yazılır.
* Sen `docker rm -f container_adi` diyerek container'ı tamamen silsen dahi, dosya senin Linux makinenin diskinde (`/var/lib/docker/volumes/...`) kalmaya devam eder.
* Yeni bir container açıp aynı volume'u bağladığında, yeni container da doğası gereği bu fiziksel klasörü okumaya başladığı için tüm eski logları hazırda bulur.

---

### 🛠️ Quick Cheatsheet: Volume Komutları

| Komut | Açıklama |
| :--- | :--- |
| `docker volume ls` | Sistemdeki tüm volume'ları listeler. |
| `docker volume create <vol-name>` | Yeni kalıcı alan oluşturur. |
| `docker run -v <vol-name>:<container-path>` | Volume'u container içindeki dizine bağlar. |
| `docker volume inspect <vol-name>` | Volume fiziki konumunu ve bağlamalarını gösterir. |

---

### 🧪 Hands-On Lab: Log Persistence Testi

1. **Named Volume Oluşturma & Container Başlatma:**
   ```bash
   docker volume create app-log-data
   docker run -d --name my-logger -p 8082:5000 -v app-log-data:/app/logs logger-app:v1
   curl http://localhost:8082
   ```

2. **Container Silme & Veri Kalıcılığı Doğrulaması:**
   ```bash
   # Container siliniyor
   docker rm -f my-logger
   
   # Yeni container aynı volume ile ayağa kaldırılıyor
   docker run -d --name my-logger-new -p 8082:5000 -v app-log-data:/app/logs logger-app:v1
   
   # Eski verilerin korunduğu doğrulanıyor
   curl http://localhost:8082
   ```

3. **Diskteki Fiziksel Konum Doğrulaması:**
   ```bash
   docker volume inspect app-log-data --format '{{ .Mountpoint }}'
   sudo ls -l /var/lib/docker/volumes/app-log-data/_data
   ```

---

## 📅 Day 6: Docker Compose Temelleri & Multi-Container Mimari

> 🎯 **Günün Amacı:** `docker-compose.yml` bildirimsel (declarative) dosya formatını öğrenmek; web uygulaması, veritabanı ve kalıcı volume yapısını tek bir komutla orkestre etmeyi pratik etmek.

### 📚 Özet Ders Notu

* **Neden Docker Compose?:** Üretim ortamlarında veya karmaşık sistemlerde onlarca container'ı tek tek `docker run` komutuyla yönetmek yerine, tüm servisleri tek bir `docker-compose.yml` dosyasında tanımlayarak yönetmeyi sağlar.
* **Otomatik Networking:** Compose, dosya içinde tanımlanan tüm servisleri otomatik olarak varsayılan bir izolasyon ağına alır. Servisler birbirlerine IP adresleri yerine servis adlarıyla (`web`, `redis` vb.) ulaşabilir.
* **Bağımlılık Yönetimi (`depends_on`):** Servislerin başlangıç sırasını belirleyerek veritabanı hazır olmadan web uygulamasının ayağa kalkmasını engeller.

---

### 🛠️ Quick Cheatsheet: Docker Compose Komutları

| Komut | Açıklama |
| :--- | :--- |
| `docker compose up -d` | `docker-compose.yml` içindeki tüm servisleri build edip arka planda çalıştırır. |
| `docker compose ps` | Compose ile yönetilen aktif servislerin durumunu listeler. |
| `docker compose logs -f <service_name>` | Belirtilen servisin canlı log akışını takip eder. |
| `docker compose down` | Tüm servisleri ve oluşturulan ağları durdurup temizler. |
| `docker compose down -v` | Servislerle birlikte tanımlı volume'ları da tamamen siler. |

---

### 🧪 Hands-On Lab: Python Web App + Redis DB + Volume Orchestration

1. **`docker-compose.yml` Yapılandırması:**
   ```yaml
   version: '3.8'

   services:
     web:
       build: .
       ports:
         - "8085:5000"
       environment:
         - REDIS_HOST=redis
       depends_on:
         - redis

     redis:
       image: redis:alpine
       ports:
         - "6379:6379"
       volumes:
         - redis-data:/data

   volumes:
     redis-data:
   ```

2. **Orkestrasyon & Doğrulama Komutları:**
   ```bash
   # Sistemleri ayağa kaldır
   docker compose up -d

   # Durum kontrolü
   docker compose ps

   # Test (Sayaç doğrulaması)
   curl http://localhost:8085

   # Temizlik
   docker compose down
   ```

   ---

## 📅 Day 7: Local CI/CD Lab Ortamı Kurulumu (Jenkins & SonarQube)

> 🎯 **Günün Amacı:** Docker Compose ile Jenkins, SonarQube ve PostgreSQL servislerini içeren izole bir yerel CI/CD lab ortamı kurmak.

### 📚 Özet Ders Notu

* **Docker Socket Mounting:** Jenkins container'ının içinde uygulama imajları build edebilmek için Host makinenin `/var/run/docker.sock` dosyası container içine mount edilir.
* **SonarQube & PostgreSQL:** SonarQube analiz sonuçlarını kalıcı olarak saklamak için arkada PostgreSQL veritabanına ihtiyaç duyar.

---

### 🛠️ Quick Cheatsheet: CI/CD Hazırlık Komutları

| Komut / İşlem | Açıklama |
| :--- | :--- |
| `sudo sysctl -w vm.max_map_count=262144` | SonarQube (Elasticsearch) için bellek limitini düzenler. |
| `docker exec -it jenkins cat ...` | Jenkins ilk kurulum şifresini (`initialAdminPassword`) getirir. |

---

### 🧪 Hands-On Lab: Docker Compose ile CI/CD Stack

1. **`docker-compose.yml` Konfigürasyonu:**
   ```yaml
   version: '3.8'

   services:
     jenkins:
       image: jenkins/jenkins:lts-jdk17
       container_name: jenkins
       user: root
       ports:
         - "8080:8080"
       volumes:
         - jenkins-data:/var/jenkins_home
         - /var/run/docker.sock:/var/run/docker.sock
       networks:
         - cicd-net

     sonarqube:
       image: sonarqube:community
       container_name: sonarqube
       ports:
         - "9000:9000"
       environment:
         - SONAR_JDBC_USERNAME=sonar
         - SONAR_JDBC_PASSWORD=sonar
         - SONAR_JDBC_URL=jdbc:postgresql://db:5432/sonar
       depends_on:
         - db
       networks:
         - cicd-net

     db:
       image: postgres:15
       container_name: postgres-sonar
       environment:
         - POSTGRES_USER=sonar
         - POSTGRES_PASSWORD=sonar
         - POSTGRES_DB=sonar
       volumes:
         - postgres-data:/var/lib/postgresql/data
       networks:
         - cicd-net

   volumes:
     jenkins-data:
     sonarqube-data:
     postgres-data:

   networks:
     cicd-net:
       name: cicd-net
   ```

2. **Ayağa Kaldırma & Şifre Alma:**
   ```bash
   docker compose up -d
   docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
