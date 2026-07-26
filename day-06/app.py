from flask import Flask
from redis import Redis
import os

app = Flask(__name__)
# Compose dosyasındaki servis adı olan 'redis' ismini kullanıyoruz!
redis_host = os.getenv('REDIS_HOST', 'redis')
redis = Redis(host=redis_host, port=6379)

@app.route('/')
def hello():
    try:
        visits = redis.incr("counter")
    except Exception as e:
        visits = f"Redis baglantisi hatasi: {str(e)}"
    
    return f"<h1>DevOps Journey - Day 6 🎼</h1><p>Docker Compose ile Multi-Container Mimarisi!</p><p>Ziyaret Sayisi: <b>{visits}</b></p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
