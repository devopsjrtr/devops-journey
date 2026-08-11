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
  - [X] Day 8: Jenkins & SonarQube İletişimini Kurma ve Pipeline Oluşturma
  - [X] Day 8-2: Dosyaların Github'dan alındığı Pipeline Senaryosu
  - [X] Day-9: Derleme Dosyalarının(Artifact) Nexus'a Deploy Edilmesi
  - [X] Day-10: Nexus'tan Canlıya Güncel Sürüm Etiketli Ürünün Yayımlanması
  - [X] Day-10-2: Github Webhook Eklenmesi, Ayarları ve Otomatik Derleme Tetiklenmesi
  - [X] Day 10-3: ChatOps (Slack Entegrasyonu) ve Sunucu Performans İyileştirmeleri
- [X] **Aşama 3: Infrastructure as Code (Terraform & Ansible)**
  - [X] Day 11: Infrastructure as Code (IaC) Dünyasına Giriş - Terraform Temelleri
  - [ ] Day 12: 
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

# 🚀 Day 8: Jenkins & SonarQube Entegrasyonu ve Dinamik Docker Deployment

Bu laboratuvar çalışmasında, **Jenkins Pipeline** üzerinden uygulama dosyalarını dinamik olarak oluşturan, **SonarQube Statik Kod Analizi** gerçekleştiren ve analiz başarıyla tamamlandıktan sonra uygulamanın **Docker İmajını** derleyip doğrulayan tam kapsamlı bir CI/CD Pipeline(Dağıtım/Entegrasyon Hattı) inşa edilmiştir.

---

## 📁 Proje Dosya Yapısı

- `app.py`: Pipeline tarafından dinamik oluşturulan Python (Flask) web uygulaması
- `requirements.txt`: Projenin Python bağımlılıkları (`flask==3.0.0`)
- `Dockerfile`: Uygulamanın container imaj konfigürasyonu
- `Jenkinsfile`: Tüm CI/CD aşamalarını ve dosya üretimini tanımlayan Groovy pipeline
- `README.md`: Dokümantasyon ve hata çözüm rehberi

---

## 🔄 Pipeline Aşamaları (Stages)

1. **Checkout (Dinamik Dosya Üretimi):** Bir SCM/Git entegrasyonu kullanılmadığı için, pipeline ilk aşamada Jenkins çalışma alanı (`${WORKSPACE}`) içerisinde `app.py`, `requirements.txt` ve `Dockerfile` dosyalarını `cat << 'EOF'` bash komutlarıyla yerel olarak oluşturur.
2. **SonarQube Analysis:** `sonarsource/sonar-scanner-cli` Docker imajı kullanılarak statik kod analizi yapılır. Dinamik oluşturulan yerel workspace dizini container içine haritalandırılır; SCM taraması devre dışı bırakılarak kod analizi tamamlanır.
3. **Build Docker Image:** Analizden başarıyla geçen projenin `my-python-app:latest` adıyla Docker imajı oluşturulur.
4. **Test & Verify:** İmajın sistemde başarıyla derlendiği doğrulanır (`docker images | grep my-python-app`).
5. **Post Actions:** Pipeline başarı/başarısızlık durumlarına göre bilgilendirme logları üretir.

---

## 🛠️ Karşılaşılan Kritik Hatalar ve Çözüm Rehberi (Troubleshooting)

Bu günü tamamlarken gerçek dünya CI/CD pipeline süreçlerinde çok sık karşılaşılan hataları deneyimledik ve çözdük. İlerideki projeler için referans notlar:

### 1. `No such property: SONAR_TOKEN for class: groovy.lang.Binding` Hatası
- **Hatanın Nedeni:** Jenkins Pipeline ortamında bash çift tırnak (`"""`) içinde `${SONAR_TOKEN}` kullanıldığında, Groovy bunu kendi değişkeni sanıp çözümlemeye çalışır; bulamayınca pipeline patlar.
- **Çözüm:** Groovy'nin bu değişkeni bash ortamına bırakması için ters bölü (`\`) ile escape edildi: `\${SONAR_TOKEN}` (veya direkt `withCredentials` ile bash değişkenine aktarıldı).

### 2. `failed to read dockerfile: open Dockerfile: no such file or directory` Hatası
- **Hatanın Nedeni:** Jenkins, bir Docker container'ı içinde yalıtılmış (isolated) bir ortamda çalıştığı için host makinedeki (örneğin WSL2 terminalinde elle oluşturduğumuz) yerel dosyaları göremez; sadece kendi volume alanı olan `${WORKSPACE}` dizinine bakar.
- **Çözüm:** `Jenkinsfile` içerisindeki ilk aşamada (`Checkout`), projenin ihtiyaç duyduğu `app.py`, `requirements.txt` ve `Dockerfile` dosyaları dinamik olarak doğrudan Jenkins'in workspace dizini içerisine yazdırıldı.

### 3. `script.sh.copy: docker: not found` Hatası
- **Hatanın Nedeni:** `jenkins/jenkins:lts` resmi imajının içinde varsayılan olarak Docker CLI aracı bulunmaz.
- **Çözüm:** Container içinden host makinenin Docker socket'ine (`/var/run/docker.sock`) bağlanabilmesi için imaj içine `docker.io` paketi kuruldu (veya özel `Dockerfile.jenkins` ile imaj derlendi).

### 4. SonarQube `WARN: Unable to locate 'report-task.txt'` veya Stage'de X Çıkması
- **Hatanın Nedeni:** Docker ile koşan `sonar-scanner-cli` aracı raporu üretip workspace içine yazmaya çalışırken Jenkins dizin izinlerine takılabilir veya çalışma alanı haritalandırma eksikliğinden dolayı tarama hataları oluşabilir.
- **Çözüm:** 
  1. Pipeline'da tarama öncesi `sh 'chmod -R 777 .'` verilerek yazma/okuma izinleri garantiye alındı.
  2. Scanner'a projenin doğru haritalanması için `-Dsonar.projectBaseDir=/usr/src` ve `-Dsonar.sources=.` parametreleri eklendi.
  3. Proje bir Git reposundan çekilmeyip workspace içinde dinamik oluşturulduğu için SCM (Git) tarayıcısının hata vermesini engellemek adına `-Dsonar.scm.disabled=true` parametresi kullanıldı.

### 5. Bash Script İçinde Yorum Satırından Sonra Command Not Found (Exit code 127)
- **Hatanın Nedeni:** `sh """ docker run ... \ # açıklama \ -Dsonar... """` şeklinde ters slash (`\`) ile alt satıra bağlanan komutların arasına `#` ile yorum yazmak Bash komut zincirini kırar.
- **Çözüm:** Tüm açıklamalar ve yorum satırları bash komut bloğunun içine değil, hemen **üstüne** taşınarak sözdizimi temizlendi.

---

## 🎯 Günün Sonucu & Kazanımlar

- Docker içinde çalışan Jenkins'ten host makine üzerindeki Docker daemon'ın yönetimi öğrenildi (Docker-in-Docker / Socket Binding).
- Kodların dinamik olarak CI/CD ortamında üretilebilmesi ve bağımlılıkların hatasız yönetilmesi sağlandı.
- SonarQube CLI konteynerinin geçici olarak tetiklenip kodları analiz ettikten sonra kendini imha etmesi (`--rm`) başarıyla uygulandı.
- Statik Kod Analizi ve Docker Build adımları uçtan uca otomatikleştirildi.

# 🚀 Day 8-2: Dosyaların Github'dan alındığı Pipeline Senaryosu

## 📄 Alternatif Senaryo: GitHub SCM Tabanlı Jenkinsfile

Dosyaları pipeline içinde dinamik olarak üretmek yerine doğrudan bir **GitHub deposundan (SCM)** çektiğimiz ve **Docker-in-Docker (DinD)** ortamında SonarQube analizi yaptığımız alternatif ve üretime hazır `Jenkinsfile` yapılandırması aşağıdadır:

```groovy
pipeline {
    agent any

    environment {
        APP_NAME = 'python-flask-app'
        DOCKER_IMAGE = 'my-python-app:latest'
        // GitHub reposu içindeki projenin bulunduğu alt klasör yolu
        WORK_DIR = 'day-08/git-stored-version' 
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Kod GitHub deposundan çekildi."
                sh 'ls -la'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    dir("${WORK_DIR}") {
                        withCredentials([string(credentialsId: 'sonar-token', variable: 'MY_SONAR_TOKEN')]) {
                            echo 'SonarQube Statik Kod Analizi Başlatılıyor...'
                            
                            sh 'chmod -R 777 .'
                            
                            // DİKKAT: Docker-in-Docker ortamında volume çakışmasını önlemek için
                            // -v yerine "--volumes-from jenkins" kullanılmıştır.
                            sh """
                                docker run --rm \
                                  --net cicd-net \
                                  -e SONAR_TOKEN="\${MY_SONAR_TOKEN}" \
                                  --volumes-from jenkins \
                                  -w \${WORKSPACE}/${WORK_DIR} \
                                  sonarsource/sonar-scanner-cli \
                                  -Dsonar.host.url=http://sonarqube:9000 \
                                  -Dsonar.projectKey=${APP_NAME} \
                                  -Dsonar.sources=.
                            """
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("${WORK_DIR}") {
                    echo 'Docker İmajı Build Ediliyor...'
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Test & Verify') {
            steps {
                echo 'Uygulama İmajı Doğrulanıyor...'
                sh 'docker images | grep my-python-app'
            }
        }
    }

    post {
        always {
            echo 'Pipeline tamamlandı.'
        }
        success {
            echo 'Tebrikler! Kod GitHub depodan alındı, analiz edildi ve build başarılı.'
        }
        failure {
            echo 'Hata! Pipeline bir adımda başarısız oldu.'
        }
    }
}
```

## 🛠️ Karşılaşılan Kritik Hatalar ve Çözüm Rehberi (Troubleshooting)

Bu günü tamamlarken gerçek dünya CI/CD pipeline süreçlerinde çok sık karşılaşılan hataları deneyimledik ve çözdük. İlerideki projeler için referans notlar:

### 1. `No such property: SONAR_TOKEN for class: groovy.lang.Binding` Hatası
- **Hatanın Nedeni:** Jenkins Pipeline ortamında bash çift tırnak (`"""`) içinde `${SONAR_TOKEN}` kullanıldığında, Groovy bunu kendi değişkeni sanıp çözümlemeye çalışır; bulamayınca pipeline patlar.
- **Çözüm:** Groovy'nin bu değişkeni bash ortamına bırakması için ters bölü (`\`) ile escape edildi: `\${SONAR_TOKEN}` (veya direkt `withCredentials` ile bash değişkenine aktarıldı).

### 2. `failed to read dockerfile: open Dockerfile: no such file or directory` Hatası
- **Hatanın Nedeni:** Jenkins, bir Docker container'ı içinde yalıtılmış (isolated) bir ortamda çalıştığı için host makinedeki (örneğin WSL2 terminalinde elle oluşturduğumuz) yerel dosyaları göremez; sadece kendi volume alanı olan `${WORKSPACE}` dizinine bakar.
- **Çözüm:** `Jenkinsfile` içerisindeki ilk aşamada projenin ihtiyaç duyduğu dosyalar doğrudan Jenkins'in workspace dizinine yazdırıldı veya GitHub üzerinden `dir("${WORK_DIR}")` bloğu ile doğru klasör konumu hedeflendi.

### 3. `script.sh.copy: docker: not found` Hatası
- **Hatanın Nedeni:** `jenkins/jenkins:lts` resmi imajının içinde varsayılan olarak Docker CLI aracı bulunmaz.
- **Çözüm:** Container içinden host makinenin Docker socket'ine (`/var/run/docker.sock`) bağlanabilmesi için imaj içine `docker.io` paketi kuruldu.

### 4. SonarQube `WARN: Unable to locate 'report-task.txt'` veya Stage'de X Çıkması
- **Hatanın Nedeni:** Docker ile koşan `sonar-scanner-cli` aracı raporu üretip workspace içine yazmaya çalışırken Jenkins dizin izinlerine takılabilir.
- **Çözüm:** Pipeline'da tarama öncesi `sh 'chmod -R 777 .'` verilerek yazma/okuma izinleri garantiye alındı.

### 5. Bash Script İçinde Yorum Satırından Sonra Command Not Found (Exit code 127)
- **Hatanın Nedeni:** `sh """ docker run ... \ # açıklama \ -Dsonar... """` şeklinde ters slash (`\`) ile alt satıra bağlanan komutların arasına `#` ile yorum yazmak Bash komut zincirini kırar.
- **Çözüm:** Tüm açıklamalar ve yorum satırları bash komut bloğunun içine değil, hemen **üstüne** taşınarak sözdizimi temizlendi.

### 6. Docker-in-Docker (DinD) ve Named Volume Tuzağı (`0 files indexed` Sorunu)
- **Hatanın Nedeni:** Jenkins bir container olarak çalışırken (`jenkins-home` adında bir Named Volume kullanırken), pipeline içinde `docker run -v ${WORKSPACE}:/usr/src` komutu çalıştırıldığında bu emri Jenkins container'ı değil, `/var/run/docker.sock` üzerinden Host makinedeki Docker Daemon işletir. Host makine kendi Linux dosya sisteminde `/var/jenkins_home/...` yolunu arayıp bulamadığı için oraya **bomboş, sıfır baytlık yeni bir klasör açıp** SonarQube container'ına bağlar. Bu nedenle SonarScanner bomboş klasörü tarar ve sürekli `0 files indexed` (0 dosya indekslendi) hatası verir.
- **Çözüm:** Host dosya yollarını eşlemek yerine Docker'ın **`--volumes-from jenkins`** parametresi kullanılarak, Jenkins container'ına bağlı olan `jenkins-home` named volume'ü doğrudan SonarScanner container'ına aktarıldı. Çalışma dizini ise **`-w ${WORKSPACE}/${WORK_DIR}`** parametresi ile belirtilerek dosya okuma sorunu kökten çözüldü.

---

## 🎯 Günün Sonucu & Kazanımlar

- Docker içinde çalışan Jenkins'ten host makine üzerindeki Docker daemon'ın yönetimi öğrenildi (Docker-in-Docker / Socket Binding).
- Docker-in-Docker mimarilerinde Named Volume paylaşımı (`--volumes-from`) ve çalışma dizini hedeflemesi (`-w`) uygulamalı olarak tecrübe edildi.
- SonarQube CLI konteynerinin geçici olarak tetiklenip kodları analiz ettikten sonra kendini imha etmesi (`--rm`) başarıyla uygulandı.
- Statik Kod Analizi ve Docker Build adımları hem dinamik hem de GitHub SCM tabanlı senaryolarda uçtan uca otomatikleştirildi.

# 🚀 Day 09: Jenkins Pipeline ile Nexus Deployment (Artifact Management)

Bugün, DevOps mimarimizin en kritik parçalarından biri olan **Artifact Management (Paket Yönetimi)** adımını CI/CD altyapımıza entegre ettik. Endüstri standardı **Sonatype Nexus Repository Manager 3** servisini `docker-compose` altyapımıza dahil ettik, özel bir **Docker Hosted Repository (Özel Docker Deposu)** kurduk ve Jenkins Pipeline'ımızı derlenen Docker imajlarını otomatik olarak etiketleyip (`docker tag`) Nexus depomuza gönderecek (`docker push`) şekilde geliştirdik.

---

## 🎯 Günün Öğrenim Hedefleri ve Kazanımları

1. **Artifact Repository Kavramı:** Derlenen uygulamaların (JAR, WAR, Docker İmajları vb.) sunuculara rastgele taşınmak yerine merkezi bir depoda versiyonlanarak saklanmasının önemi.
2. **Nexus Repository Tipi Seçimi:** 
   - `hosted`: Kendi derlediğimiz iç paketleri ve Docker imajlarını barındıran depo tipi.
   - `proxy`: Dış kaynaklardan (Docker Hub vb.) çekilen paketleri önbelleğe alan ayna (mirror) depo tipi.
   - `group`: Hosted ve Proxy depolarını tek URL altında birleştiren depo tipi.
3. **Docker V2 Registry Entegrasyonu:** Nexus üzerinde HTTP portu (`8083`) açarak özel bir Docker Registry tanımlamak ve kimlik doğrulama ayarlarını yapılandırmak.
4. **Pipeline Otomasyonu:** Jenkins üzerinden `withCredentials` bloğu ile Nexus kimlik doğrulaması yapmak, `docker tag` komutu ile imajı uzak depo formatına getirmek ve `docker push` ile yüklemek.

---

## 🏗️ Altyapı Mimarimizin Son Hali

```text
[ GitHub ] --(Checkout)--> [ Jenkins ] --(Statik Analiz)--> [ SonarQube ]
                               |
                        (Docker Build)
                               |
                        [ Local Image ]
                               |
                     (Docker Tag & Push)
                               v
               [ Nexus 3 (Docker Hosted Repo) ]
                         (port: 8083)
```

## Güncellenmiş Altyapı Dosyaları

1. docker-compose.yml
Nexus servisi (8081 arayüz ve 8083 Docker Registry portları) ve veri sürekliliği için nexus-data volume tanımı eklendi:

```yaml
services:
  jenkins:
    image: jenkins/jenkins:lts-jdk17
    container_name: jenkins
    user: root
    entrypoint: >
      /bin/bash -c "
      apt-get update && apt-get install -y docker.io &&
      chmod 666 /var/run/docker.sock &&
      /usr/bin/tini -- /usr/local/bin/jenkins.sh
      "
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins-home:/var/jenkins_home
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
      - SONAR_SEARCH_JAVAADDITIONALOPTS=-Xmx512m -Xms512m
    volumes:
      - sonarqube-data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
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

  nexus:
    image: sonatype/nexus3:latest
    container_name: nexus
    ports:
      - "8081:8081"
      - "8083:8083" # Docker Hosted Repository (HTTP Port Connector)
    volumes:
      - nexus-data:/nexus-data
    networks:
      - cicd-net

volumes:
  jenkins-home:
  sonarqube-data:
  sonarqube_extensions:
  sonarqube_logs:
  postgres-data:
  nexus-data:

networks:
  cicd-net:
    name: cicd-net
```

2. Jenkinsfile
Jenkins'in Nexus deposuna push yapabilmesi için Push Docker Image to Nexus aşaması, docker tag mantığı ve nexus-docker-creds kimlik bilgisi entegre edildi:

```groovy
pipeline {
    agent any

    environment {
        APP_NAME = 'python-flask-app'
        DOCKER_IMAGE = 'my-python-app:latest'
        NEXUS_REGISTRY = 'localhost:8083'
        WORK_DIR = 'day-08/git-stored-version' 
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Kod GitHub deposundan çekildi."
                sh 'ls -la'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    dir("${WORK_DIR}") {
                        withCredentials([string(credentialsId: 'sonar-token', variable: 'MY_SONAR_TOKEN')]) {
                            echo 'SonarQube Statik Kod Analizi Başlatılıyor...'
                            
                            sh 'chmod -R 777 .'
                            
                            sh """
                                docker run --rm \
                                  --net cicd-net \
                                  -e SONAR_TOKEN="\${MY_SONAR_TOKEN}" \
                                  --volumes-from jenkins \
                                  -w \${WORKSPACE}/${WORK_DIR} \
                                  sonarsource/sonar-scanner-cli \
                                  -Dsonar.host.url=http://sonarqube:9000 \
                                  -Dsonar.projectKey=${APP_NAME} \
                                  -Dsonar.sources=.
                            """
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("${WORK_DIR}") {
                    echo 'Docker İmajı Build Ediliyor...'
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                }
            }
        }

        stage('Push Docker Image to Nexus') {
            steps {
                echo 'Docker İmajı Nexus Repository Manager adresine yükleniyor...'
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexus-docker-creds', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                        sh """
                            echo "Nexus'a login olunuyor..."
                            docker login -u \${NEXUS_USER} -p \${NEXUS_PASS} ${NEXUS_REGISTRY}
                            
                            echo "İmaj Nexus formatında etiketleniyor..."
                            docker tag ${DOCKER_IMAGE} ${NEXUS_REGISTRY}/${DOCKER_IMAGE}
                            
                            echo "İmaj Nexus'a pushlanıyor..."
                            docker push ${NEXUS_REGISTRY}/${DOCKER_IMAGE}
                        """
                    }
                }
            }
        }

        stage('Test & Verify') {
            steps {
                echo 'Uygulama İmajı Doğrulanıyor...'
                sh 'docker images | grep my-python-app'
            }
        }
    }

    post {
        always {
            echo 'Pipeline tamamlandı.'
        }
        success {
            echo 'Tebrikler! Kod analiz edildi, Docker imajı build edildi ve Nexus deposuna başarıyla yüklendi.'
        }
        failure {
            echo 'Hata! Pipeline bir adımda başarısız oldu.'
        }
    }
}
```

## ⚙️ Nexus Repository Manager Kurulum ve Yapılandırma Adımları
1. İlk Şifrenin Alınması:

```bash
docker exec -it nexus cat /nexus-data/admin.password
```
2. EULA (Lisans Sözleşmesi) Onayı: Nexus 3 arayüzünde ilk girişte çıkan End User License Agreement (EULA) onaylanmalıdır. Onaylanmazsa API erişimleri bloke olur.

3. Docker Hosted Repository Oluşturma:

  Recipe: docker (hosted) (Kesinlikle proxy seçilmemelidir)
  
  Name: docker-hosted
  
  HTTP Port: 8083 (✓ Create an HTTP connector at specified port)
  
  Docker Registry API Support: Enable Docker V1 API support (✓ İşaretli)
  
  Force basic authentication: ✓ İşaretli (Sürümde varsa işaretlenmeli)
  
  Deployment Policy: Allow redeploy

4. Security -> Realms Yapılandırması:

  Sol menüden Security -> Realms alanına gidilmeli ve Docker Bearer Token Realm aktifleştirilip sağdaki Active sütununa taşınmalıdır.

5. Security -> Anonymous Yapılandırması:

  Docker CLI'ın /v2/ API ping isteklerinde 403 Forbidden yerine 401 Unauthorized (Kimlik sor) yanıtı döndürmesi için Enable anonymous access (Anonim erişim) kapatılmalıdır    (Disable).

## 🐞 Kritik Çözüm Rehberi (Troubleshooting Ledger)
1. tag does not exist: localhost:8083/my-python-app:latest Hatası
Belirti: Pipeline imajı build etmesine rağmen push adımında imajı bulamadığını söyler.

Kök Neden: Docker CLI, uzak bir registry'e push yaparken imaj adının ön ekinin depoyla eşleşmesini bekler (localhost:8083/<repo-name>:<tag>). Lokalde imaj sadece my-python-app:latest olarak build edildiği için bulunamaz.

Çözüm: Pipeline içerisine docker push öncesine docker tag my-python-app:latest localhost:8083/my-python-app:latest komutu eklendi.

2. docker login Sırasında Sessiz 403 Forbidden Hatası (EULA Tuzağı)
   
  Belirti: Şifre, port ve depolama ayarları doğru olduğu halde docker login -u admin ... komutu sürekli 403 Forbidden döner.

  Kök Neden: Docker CLI gerçek hatayı gizleyip sadece status: 403 olarak raporlar. Arka planda ise Nexus 3.94+ sürümleri, EULA (End User License Agreement) sözleşmesi         arayüzden onaylanmadığı için tüm API ve V2 ping isteklerini engellemektedir.

  Çözüm (Hata Tespiti & Çözüm):
  Gerçek hatayı görmek için Docker CLI aradan çıkarılıp curl komutu kullanıldı:

  ```bash
  curl -i http://localhost:8083/v2/
  ```

  Çıktıda You must accept the End User License Agreement (EULA)... uyarısı görüldü.

  Tarayıcıdan http://localhost:8081/#admin/system/license adresine gidilerek sözleşme kabul edildi ve API engeli kaldırıldı.

3. Nexus Web Arayüzü Oturum (CSRF / Cookie) Çakışması
	
	Belirti: Kurulum sihirbazında şifre değiştirdikten hemen sonra arayüz sürekli login ekranına atar.

	Kök Neden: Eski oturum çerezleri ile yeni şifre sonrasında üretilen CSRF token'larının çakışması.

	Çözüm: Tarayıcının çerezleri temizlendi veya Gizli Sekme (Incognito) kullanılarak giriş yapıldı.

🏆 Günün Özeti
Günün sonunda yazdığımız kod Github'dan otomatik olarak alınıyor, SonarQube'de statik kod analizinden geçiyor, Docker tabanlı derleme ortamında konteyner imajı haline getiriliyor ve endüstri standardı Nexus Repository Manager üzerinde versiyonlanarak barındırılıyor!

# 🚀 Day 10: Nexus'tan Canlıya Güncel Sürüm Etiketli Ürünün Yayımlanması (CD Automation)

Bugün, CI/CD Pipeline(Dağıtım/Entegrasyon Hattı)'ımızın **Continuous Deployment (Sürekli Dağıtım)** halkasını tamamladık. Nexus Repository Manager üzerinde versiyonlanarak barındırılan Docker imajını, dinamik etiketleme (`build-${BUILD_NUMBER}`) ile canlı ortama otomatik olarak dağıtan (deploy eden) süreci inşa ettik.

---

## 🎯 Günün Öğrenim Hedefleri ve Kazanımları

* **Continuous Deployment (CD) Mantığı:** Derlenen ve testten geçen ürünün manuel müdahale olmadan hedef ortama (Production) çekilerek (`docker pull`) yayına alınması.
* **Dinamik Sürüm Etiketleme (Dynamic Tagging):** Her derlemede `latest` etiketinin yanı sıra `build-${BUILD_NUMBER}` kullanarak imajların versiyon takibini ve geri izlenebilirliğini sağlama.
* **Zero-Downtime / Container Replacement:** Canlı ortamda çalışan eski sürüm container'ın durdurulup silinmesi (`docker rm -f production-python-app || true`) ve yeni sürüm imaj ile ayağa kaldırılması.
* **Otomatik Sağlık Kontrolü (Health Check):** Dağıtım sonrası container içi ağ (`cicd-net`) üzerinden `curl` isteği atılarak uygulamanın ayakta olup olmadığının terminalden doğrulanması.

---

## 🔄 Day 10 Pipeline Yapılandırması (Jenkinsfile)

Aşağıdaki `Jenkinsfile`, kodun GitHub'dan çekilmesinden, `day-10` dizininde SonarQube analizinin yapılmasına[cite: 2], Nexus'a imaj yüklenmesinden[cite: 2] canlı ortamda (`production-python-app`) 5000 portunda yayınlanıp test edilmesine kadar olan uçtan uca süreci tanımlar[cite: 2]:

```groovy
pipeline {
    agent any

    environment {
        NEXUS_REGISTRY = 'localhost:8083'
        IMAGE_NAME     = 'my-python-app'
        APP_CONTAINER  = 'production-python-app'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Kod GitHub deposundan çekildi.'
                sh 'ls -la'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    dir('day-10') {
                        withCredentials([string(credentialsId: 'sonar-token', variable: 'MY_SONAR_TOKEN')]) {
                            echo 'SonarQube Statik Kod Analizi Başlatılıyor...'
                            sh 'chmod -R 777 .'
                            sh 'docker run --rm --net cicd-net -e SONAR_TOKEN=' + MY_SONAR_TOKEN + ' --volumes-from jenkins -w "' + WORKSPACE + '/day-10" sonarsource/sonar-scanner-cli -Dsonar.host.url=http://sonarqube:9000 -Dsonar.projectKey=my-python-app -Dsonar.sources=.'
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dir('day-10') {
                        echo "Docker imajı derleniyor: ${NEXUS_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}"
                        sh "docker build -t ${NEXUS_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER} ."
                        sh "docker tag ${NEXUS_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER} ${NEXUS_REGISTRY}/${IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Push Docker Image to Nexus') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexus-docker-creds', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USER')]) {
                        echo 'Nexus Docker Registry oturumu açılıyor...'
                        sh "docker login -u ${NEXUS_USER} -p ${NEXUS_PASSWORD}${NEXUS_REGISTRY}"
                        
                        echo 'İmajlar Nexus deponuza yükleniyor...'
                        sh "docker push ${NEXUS_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}"
                        sh "docker push ${NEXUS_REGISTRY}/${IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'nexus-docker-creds', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USER')]) {
                        echo 'Canlı ortam için Nexus login yapılıyor...'
                        sh "docker login -u ${NEXUS_USER} -p ${NEXUS_PASSWORD}${NEXUS_REGISTRY}"

                        echo 'Eski çalışan canlı container varsa durduruluyor ve siliniyor...'
                        sh "docker rm -f ${APP_CONTAINER} || true"

                        echo 'En güncel imaj Nexus depomuzdan çekiliyor...'
                        sh "docker pull ${NEXUS_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}"

                        echo 'Yeni canlı uygulama konteyneri ayağa kaldırılıyor...'
                        sh "docker run -d --name ${APP_CONTAINER} --net cicd-net -p 5000:5000${NEXUS_REGISTRY}/${IMAGE_NAME}:build-${BUILD_NUMBER}"
                    }
                }
            }
        }

        stage('Test & Verify Deployment') {
            steps {
                script {
                    echo 'Canlıya alınan uygulamanın Sağlık Kontrolü (Health Check) yapılıyor...'
                    sleep 5
                    // Konteyner içine girmek yerine doğrudan cicd-net ağındaki konteynere istek atıyoruz:
                    sh "curl -s -f http://production-python-app:5000/ || (echo 'Uygulama yanıt vermiyor!' && exit 1)"
                    echo 'Tebrikler! Uygulama canlı ortamda sorunsuz yanıt veriyor.'
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution completed.'
        }
        success {
            echo 'BAŞARILI: Kod analiz edildi, imaj derlendi, Nexus depoya yüklendi ve canlı ortamda yayına alındı! 🎉'
        }
        failure {
            echo 'HATA: Pipeline süreçlerinden birinde bir aksaklık yaşandı.'
        }
    }
}
```
## 🛠️ Karşılaşılan Kritik Hatalar ve Çözüm Rehberi (Troubleshooting)

### 1. `Conflict. The container name "/production-app" is already in use` Hatası
* **Hatanın Nedeni:** Pipeline tekrar tetiklendiğinde aynı isimdeki container (`production-python-app`) sistemde aktif veya durmuş şekilde bulunduğu için Docker yeni container'ı başlatamaz[cite: 2].
* **Çözüm:** `Deploy to Production` adımında yeni container çalıştırılmadan hemen önce `docker rm -f ${APP_CONTAINER} || true` komutu eklenerek eski container'ın hata vermeden silinmesi sağlandı[cite: 2].

### 2. Canlı Ortam Sağlık Kontrolü (Health Check) İletişimi
* **Hatanın Nedeni:** Host portu üzerinden test yaparken ağ izolasyonu veya port yönlendirme gecikmeleri sebebiyle sahte hatalar alınması.
* **Çözüm:** Konteyner içine girmeden veya Host IP'sine gitmeden doğrudan `cicd-net` ağındaki servis adıyla (`http://production-python-app:5000/`) HTTP kontrolü gerçekleştirilerek pipeline içinde hızlı doğrulama sağlandı.

---

🏆 **Günün Özeti:** Kod değişikliğinin statik analize girdiği, `build-${BUILD_NUMBER}` ve `latest` olarak etiketlenip Nexus depomuzda versiyonlandığı ve `production-python-app` adıyla canlı ortama alınıp, otomatik sağlık kontrolünden geçtiği, uçtan uca bir Sürekli Dağıtım (CD) süreci başarıyla tamamlandı!

# 🚀 Gün 10-2: GitHub Webhook Eklenmesi ve Otomatik Tetikleme (CI Trigger)

Bugün, CI/CD Pipeline(Dağıtım/Entegrasyon Hattı)'ımızın otomasyonunu tamamlayarak **Sürekli Entegrasyon (CI)** sürecini gerçek anlamda başlattık. Kod depolarındaki (GitHub) değişiklikleri anlık olarak dinleyen ve Jenkins'teki pipeline'ı otomatik olarak başlatan Webhook entegrasyonunu kurduk.

---

## 🎯 Günün Öğrenim Hedefleri ve Kazanımları

1. **Webhook Mantığı:** Versiyon kontrol sistemlerindeki (GitHub) olayların (push, merge), hedef sistemlere (Jenkins) HTTP istekleriyle anlık olarak bildirilmesi.
2. **Event-Driven CI/CD:** Manuel tetiklemeler (`Build Now`) yerine, kodun GitHub'a gönderildiği (push) anda pipeline'ın kendi kendini otomatik olarak başlatması.
3. **Troubleshooting (Hata Giderme):** Jenkins-GitHub iletişimindeki sessiz hataların log analiziyle çözülmesi, SonarQube ve Nexus'taki bellek (OOM) ve yetki kilitlenme (lock) sorunlarının kalıcı olarak giderilmesi.

---

## ⚙️ Webhook Yapılandırma Adımları

### 1. Jenkins Tarafı (Alıcı Ayarları)
Jenkins'in gelen Webhook isteklerini kabul etmesi ve doğru projeyi tetiklemesi için şu ayarlar yapıldı:
* İlgili Pipeline projesine (Örn: `cicd-pipeline`) girilip **Configure (Yapılandır)** menüsü açıldı.
* **Build Triggers (Tetikleyiciler)** sekmesi altında **"GitHub hook trigger for GITScm polling"** seçeneği işaretlendi.
* ⚠️ **Kritik Kural:** Jenkins'in branch ve repo ayarlarını önbelleğe alabilmesi için, webhook kurulduktan sonra pipeline en az **bir kez manuel olarak (`Build Now`) çalıştırıldı.**

### 2. GitHub Tarafı (Gönderici Ayarları)
GitHub'daki deponun, değişiklikleri anında Jenkins'e haber vermesi için şu ayarlar yapıldı:
* GitHub Reposu -> **Settings** -> **Webhooks** -> **Add webhook** yoluna gidildi.
* **Payload URL:** `http://<JENKINS_SUNUCU_IP>:8080/github-webhook/` *(Sonundaki `/` işareti önemlidir)*
* **Content type:** `application/json` olarak seçildi.
* **Which events would you like to trigger this webhook?:** `Just the push event` (Sadece push anında tetikle) seçilerek sınırlandırıldı.
* **Active** kutucuğu işaretlenip kaydedildi.

---

## 🐞 Karşılaşılan Kritik Hatalar ve Çözüm Rehberi (Troubleshooting)

Bu entegrasyon ve devamındaki tam otomatik pipeline koşusu sırasında karşılaşılan ve başarıyla çözülen kritik sorunlar:

### 1. GitHub Yeşil Tik Veriyor Ama Jenkins Tetiklenmiyor
* **Belirti:** GitHub'da Webhook teslimatı `HTTP 200 OK` (Poked) dönüyor ancak Jenkins arayüzünde yeni bir build başlamıyor.
* **Hatanın Nedeni:** Jenkins isteği başarıyla alıyor ancak hiçbir pipeline ile eşleştiremiyor. Bunun temel sebebi; Jenkins job ayarlarında "GitHub hook trigger" seçeneğinin işaretli olmaması, Git branch isminin uyuşmaması veya job'ın daha önce hiç manuel çalıştırılıp SCM bilgilerini indekslememiş olmasıdır.
* **Çözüm:** Job içindeki "GitHub hook trigger" aktifleştirildi ve pipeline bir kez manuel tetiklenerek webhook'un hedefi tanıması sağlandı.

### 2. SonarQube `Connection refused` ve `vm.max_map_count` Çökmesi
* **Belirti:** Pipeline'ın statik kod analizi adımında SonarQube aniden `Failed to query ES status` veya `Connection refused` hatası vererek kapanıyor.
* **Hatanın Nedeni:** SonarQube içindeki Elasticsearch motoru, host sistemin (Linux/WSL2) bellek haritalama limiti (`vm.max_map_count`) varsayılan veya düşük değerde olduğu için bellek hatası verip kendi kendini öldürüyor (`Hard stopping process`). 
* **Çözüm:** Host makinede `sudo sysctl -w vm.max_map_count=262144` komutu ile limit artırıldı ve SonarQube container'ı yeniden başlatıldı.

### 3. Nexus `Unix error code 2` ve Kilitlenme (Lock) Sorunu
* **Belirti:** Jenkins, Nexus imaj push adımında `500 Server Error` veya `connection refused` hatası veriyor. Container loglarında ise sürekli `Could not lock User prefs. Unix error code 2` ve `Couldn't get file lock` hataları akıyor.
* **Hatanın Nedeni:** Java 21 kullanan yeni Nexus sürümlerinin aradığı `.java/.userPrefs` tercih (preferences) dizinleri, volume bağlanırken otomatik oluşturulamadığı için Nexus EULA onayını kontrol edemiyor ve Docker Registry portunu dinlemeye geçemiyor.
* **Çözüm:** Container içerisine root yetkisiyle girilerek eksik dizinler manuel oluşturuldu ve sahiplik Nexus kullanıcısına (`200:200`) devredildi:
  ```bash
  docker exec -it -u 0 nexus mkdir -p /nexus-data/.java/.userPrefs
  docker exec -it -u 0 nexus chown -R 200:200 /nexus-data/.java
  docker exec -it -u 0 nexus chmod -R 755 /nexus-data/.java
  docker compose restart nexus
  ```
---
## 🏆 Günün Özeti
GitHub, Jenkins, SonarQube, Nexus ve canlı ortam arasındaki tüm teknik engeller, izin sorunları ve kilitlenmeler çözüldü. Artık geliştirici kodunu GitHub'a push ettiği an; analiz, derleme, versiyon etiketleme ve yayına alma işlemleri insan müdahalesi olmadan, tam otomatik ve hatasız olarak gerçekleşiyor!

# 🚀 Gün 10-3: ChatOps (Slack Entegrasyonu) ve Sunucu Performans İyileştirmeleri

Bugün, CI/CD süreçlerimize ChatOps kültürünü entegre ederek, pipeline'ın her adımından anında haberdar olmamızı sağlayan Slack bildirim otomasyonunu kurduk. Ayrıca, ağır Java servislerimizin (Jenkins, SonarQube, Nexus) bulut ortamında (AWS t2.medium) stabil çalışabilmesi için kritik sistem ve bellek (Swap) iyileştirmeleri gerçekleştirdik.

---

## 🎯 Günün Öğrenim Hedefleri ve Kazanımları

1. **ChatOps Kültürü:** Geliştirme ve operasyon süreçlerinin (CI/CD) bir sohbet uygulaması (Slack) üzerinden anlık olarak takip edilmesi.
2. **Slack API & Jenkins Entegrasyonu:** Slack üzerinde özel bir bot (Custom App) oluşturarak güvenli kimlik doğrulama (Bot Token) ile Jenkins'in dış dünyaya mesaj atmasının sağlanması.
3. **Sistem Mühendisliği (AWS & Linux):** Fiziksel sınırları zorlayan sunucularda (OOM - Out of Memory riskine karşı) AWS EBS disk genişletme ve Linux sanal bellek (Swap) yönetimi.

---

## ⚙️ Slack ve Jenkins Yapılandırma Adımları

### 1. Slack Tarafı: Bot ve Token Oluşturma
* **Slack API** üzerinden sıfırdan bir uygulama (Blank App) oluşturuldu.
* Bota `chat:write` (mesaj gönderme) yetkisi verilerek çalışma alanına (Workspace) kuruldu ve `xoxb-` ile başlayan **Bot User OAuth Token** alındı.
* Slack kanalına (Örn: `#ci-cd-alerts`) gidilerek `/invite @BotAdi` komutu ile bot kanala davet edildi.

### 2. Jenkins Tarafı: Kimlik Doğrulama ve Sistem Ayarları
* **Slack Notification Plugin** kuruldu.
* Alınan bot token, Jenkins Credentials kasasına **"Secret text"** olarak (ID: `slack-token`) güvenli bir şekilde eklendi.
* **Manage Jenkins -> System** altındaki Slack ayarlarında; "Workspace" alanı boş bırakıldı ve modern bot entegrasyonu için **"Custom slack app bot user"** seçeneği işaretlendi.

### 3. Jenkinsfile Güncellemesi (Bildirim Kodları)
Pipeline'ın sonuna eklenen `post` bloğu ile süreç sonuçlarının Slack'e otomatik iletilmesi sağlandı:

```groovy
post {
    always {
        echo 'Pipeline execution completed.'
    }
    success {
        slackSend(channel: '#ci-cd-alerts', tokenCredentialId: 'slack-token', color: 'good', message: "✅ *BAŞARILI:* ${env.JOB_NAME} [Build #${env.BUILD_NUMBER}] canlı ortama başarıyla dağıtıldı!\nDetaylar: ${env.BUILD_URL}")
    }
    failure {
        slackSend(channel: '#ci-cd-alerts', tokenCredentialId: 'slack-token', color: 'danger', message: "🚨 *HATA:* ${env.JOB_NAME} [Build #${env.BUILD_NUMBER}] süreçlerinden birinde bir aksaklık yaşandı!\nDetaylar: ${env.BUILD_URL}")
    }
}
```
## 🐞 Karşılaşılan Kritik Hatalar ve Çözüm Rehberi (Troubleshooting)

### 1. Slack Entegrasyonunda `Illegal character in authority at index 8` Hatası
* **Belirti:** Jenkins'ten Slack'e test mesajı atarken boşluk karakteri hatası alındı.
* **Hatanın Nedeni:** Jenkins Slack eklentisinde "Workspace" alanına kısa URL yerine çalışma alanının görünen adının (boşluklu) yazılması.
* **Çözüm:** Adres çubuğundaki kısa URL (subdomain) kullanıldı (Örn: `devopstrainin-...`). (Daha sonra modern bot yapısına geçildiği için bu alan tamamen boş bırakılarak çözüldü).

### 2. Slack 404 Not Found ve "Failure" Hatası
* **Belirti:** Jenkins loglarında `Slack post may have failed. Response Code: 404` hatası belirdi ve kanala bildirim düşmedi.
* **Hatanın Nedeni:** Jenkins'in eski (Legacy) Webhook yöntemini kullanmaya çalışması ve `Jenkinsfile` içerisinde kanal adı / token bilgisinin eksik gönderilmesi.
* **Çözüm:** Jenkins sistem ayarlarından "Custom slack app bot user" aktifleştirildi. `Jenkinsfile` içerisindeki `slackSend` komutuna `channel` (başında `#` ile) ve `tokenCredentialId` parametreleri manuel olarak tanımlanarak hata giderildi.

### 3. AWS Sunucusunda "Operation not permitted" ve RAM (OOM) Çökmeleri
* **Belirti:** Nexus ve SonarQube gibi ağır Java servisleri çalışırken sistem kilitleniyor, eski swap alanı silinmek istendiğinde izin hatası veriyordu.
* **Hatanın Nedeni:** `t2.medium` sunucusunun fiziksel RAM'inin (4 GB) ve eski Swap alanının (2 GB) yetersiz kalması. İşletim sistemi swap dosyasını aktif kullandığı için silinmesine izin vermiyordu.
* **Çözüm (AWS EBS Resize & Swap Upgrade):**
  1. AWS konsolundan EC2 disk (EBS) kapasitesi ücretsiz katman sınırları dahilinde 20 GB'tan 30 GB'a yükseltildi.
  2. Linux tarafında `growpart` ve `resize2fs` komutlarıyla yeni disk alanı işletim sistemine tanıtıldı.
  3. Ağır Docker servisleri durdurularak (`docker compose stop`) RAM'de yer açıldı, `swapoff` ile eski sanal bellek güvenle kapatılıp silindi.
  4. `fallocate`, `chmod 600`, `mkswap` ve `swapon` komutları sırasıyla kullanılarak sisteme 4 GB'lık ferah bir Swap alanı tanımlandı.

# 🚀 Gün 11: Infrastructure as Code (IaC) Dünyasına Giriş - Terraform Temelleri

Bugün, DevOps kültürünün en önemli yapıtaşlarından biri olan "Infrastructure as Code" (Altyapı Kodlama) konseptine giriş yaptık. AWS konsolu üzerinden manuel olarak gerçekleştirdiğimiz sunucu oluşturma ve güvenlik ayarları yapılandırma işlemlerini, HashiCorp Terraform kullanarak tamamen otomatize ettik. 

Kurumsal ağ kısıtlamaları nedeniyle yerel (local) ortam yerine, halihazırda AWS üzerinde koşan mevcut Jenkins (Ubuntu) sunucumuzu bir "Yönetim Sunucusu (Management/Bastion Node)" olarak konumlandırdık.

---

## 🎯 Günün Öğrenim Hedefleri ve Kazanımları

1. **AWS IAM (Identity and Access Management):** Root hesap yerine otomasyon süreçleri için özel, yetkileri sınırlandırılmış (AdministratorAccess) bir IAM kullanıcısı ve Access/Secret Key oluşturulması.
2. **AWS CLI & Terraform Entegrasyonu:** Yönetim sunucusuna AWS CLI ve Terraform kurularak kimlik doğrulama (`aws configure`) işlemlerinin tamamlanması.
3. **HCL (HashiCorp Configuration Language) Sözdizimi:** `main.tf` dosyası oluşturularak AWS sağlayıcısı (Provider) ve kaynak (Resource) tanımlamalarının yapılması.
4. **Terraform Yaşam Döngüsü (Lifecycle):** Altyapının başlatılması (`init`), simüle edilmesi (`plan`), inşa edilmesi (`apply`) ve iş bitiminde temizlenmesi (`destroy`).
5. **Durum (State) Yönetimi:** Mevcut çalışan bir sunucu silinmeden, üzerine yeni bir Güvenlik Grubu (Security Group) eklenerek altyapının güncellenmesi.

---

## ⚙️ Uygulama Adımları

### 1. Kurulum ve AWS Kimlik Doğrulaması
Mevcut EC2 sunucusu üzerinde Terraform ve AWS CLI araçları kurularak IAM üzerinden alınan erişim anahtarları sisteme tanımlandı:
```bash
# AWS CLI Kurulumu ve Konfigürasyonu
sudo apt update && sudo apt install awscli -y
aws configure

# Terraform Kurulumu
wget -O- [https://apt.releases.hashicorp.com/gpg](https://apt.releases.hashicorp.com/gpg) | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] [https://apt.releases.hashicorp.com](https://apt.releases.hashicorp.com) $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
```
### 🔑 Ek Adım: AWS IAM Kullanıcısı ve Erişim Anahtarlarının (Access/Secret Key) Oluşturulması

Terraform'un (veya herhangi bir otomasyon aracının) AWS üzerinde işlem yapabilmesi için Root (kök) hesap yerine, sınırları belirlenmiş bir IAM kullanıcısına ihtiyacı vardır. Güvenlik en iyi uygulamaları (best practices) gereği bu işlem şu adımlarla gerçekleştirilmiştir:

**1. IAM Kullanıcısının Oluşturulması:**
* AWS Management Console üzerinden **IAM** modülüne girildi ve sol menüden **Users (Kullanıcılar)** sekmesine geçilerek **Create user** butonuna tıklandı.
* Kullanıcı adı (Örn: `terraform-admin`) belirlendi. *(Not: Otomasyon aracının AWS web arayüzüne girmesine gerek olmadığı için "Provide user access to the AWS Management Console" seçeneği bilerek boş bırakıldı).*
* Yetkilendirme adımında **Attach policies directly (İlkeleri doğrudan ekle)** seçeneği işaretlendi. Terraform'un sunucu, ağ ve güvenlik grupları gibi kaynakları özgürce yaratıp silebilmesi için **`AdministratorAccess`** ilkesi (policy) eklendi ve kullanıcı oluşturuldu.

**2. Access Key ve Secret Key Üretilmesi:**
* Oluşturulan kullanıcının detay sayfasında **Security credentials (Güvenlik kimlik bilgileri)** sekmesine gidildi.
* Sayfanın alt kısımlarındaki **Access keys** bölümünden **Create access key** butonuna tıklandı.
* Kullanım senaryosu (Use case) olarak **Command Line Interface (CLI)** seçildi ve onay kutucuğu işaretlenerek ilerlendi.
* Ekranda güvenlik gereği yalnızca bir kez gösterilen **Access key ID** ve **Secret access key** değerleri kopyalanarak güvenli bir yere not edildi. Bu anahtarlar daha sonra sunucu üzerinde `aws configure` komutu ile sisteme tanıtıldı.

### 2. İlk Terraform Kodunun (main.tf) Yazılması
Proje dizininde oluşturulan `main.tf` dosyası ile AWS üzerinde `t3.small` tipinde bir Ubuntu sunucusu ve sadece 22. porttan (SSH) erişime izin veren bir Güvenlik Grubu tanımlandı:

```hcl
provider "aws" {
  region = "us-east-1" 
}

# Güvenlik Grubu Tanımlaması
resource "aws_security_group" "ssh_izni" {
  name        = "terraform-ssh-sg"
  description = "SSH baglantisina izin ver"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Sunucu Tanımlaması (AWS üzerindeki instance bilgilerimize göre doldurulmuştur)
resource "aws_instance" "ilk_sunucum" {
  ami           = "ami-0b6d9d3d33ba97d99" 
  instance_type = "t3.small"
  
  vpc_security_group_ids = [aws_security_group.ssh_izni.id]

  tags = {
    Name = "Terraform-Ile-Gelen-Sunucu"
  }
}
```
### 3. Terraform Komutlarının Çalıştırılması
Yazılan kod, sırasıyla, aşağıdaki temel Terraform komutları kullanılarak AWS üzerinde canlıya alındı ve test edildikten sonra temizlendi:

* `terraform init`: Çalışma dizinini başlattı ve AWS eklentilerini (provider plugins) indirdi.

* `terraform plan`: Yazılan kodun AWS üzerinde yaratacağı değişikliklerin (1 adet EC2, 1 adet SG) simülasyonunu ve özetini sundu.

* `terraform apply`: Planlanan altyapıyı saniyeler içinde hatasız bir şekilde AWS üzerinde inşa etti.

* `terraform destroy`: Eğitim/test amacıyla ayağa kaldırılan tüm kaynakları, bağımlılık sırasına uygun şekilde (önce EC2, sonra Security Group) tamamen silerek gereksiz maliyet oluşmasını engelledi.
