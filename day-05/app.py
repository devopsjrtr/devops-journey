from flask import Flask
from datetime import datetime
import os

app = Flask(__name__)
LOG_FILE = "/app/logs/access.log"

# Log klasörü yoksa oluştur
os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)

@app.route('/')
def index():
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(LOG_FILE, "a") as f:
        f.write(f"Ziyaret Tarihi: {now}\n")
    
    # Log dosyasını oku ve ekrana bas
    with open(LOG_FILE, "r") as f:
        logs = f.readlines()
        
    return f"<h1>DevOps Journey - Day 5 💾</h1><p>Toplanan Toplam Log Sayisi: {len(logs)}</p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
