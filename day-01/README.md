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

# 🚀 Day 8: Jenkins & SonarQube Entegrasyonu ve Dinamik Docker Deployment

Bu laboratuvar çalışmasında, **Jenkins Pipeline** üzerinden uygulama dosyalarını dinamik olarak oluşturan, **SonarQube Statik Kod Analizi** gerçekleştiren ve analiz başarıyla tamamlandıktan sonra uygulamanın **Docker İmajını** derleyip doğrulayan tam kapsamlı bir CI/CD boru hattı (pipeline) inşa edilmiştir.

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
