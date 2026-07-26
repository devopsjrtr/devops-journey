# 1. Taban imaj olarak hafif Python imajı seçiyoruz
FROM python:3.9-slim

# 2. Çalışma alanını tanımlıyoruz
WORKDIR /app

# 3. Önce sadece bağımlılık dosyasını kopyalayarak Docker Cache mekanizmasından yararlanıyoruz
COPY requirements.txt .

# 4. Kütüphaneleri yüklüyoruz
RUN pip install --no-cache-dir -r requirements.txt

# 5. Uygulama kodlarını container içine aktarıyoruz
COPY . .

# 6. Uygulama versiyonunu ortam değişkeni olarak atıyoruz
ENV APP_VERSION=v1.0

# 7. Uygulama portunu belirtiyoruz
EXPOSE 5000

# 8. Container başladığında uygulamayı koşturuyoruz
CMD ["python", "app.py"]
