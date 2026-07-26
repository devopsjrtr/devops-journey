from flask import Flask
from redis import Redis
import os

app = Flask(__name__)
# Redis host adı olarak container ismini ('redis-db') veriyoruz!
redis_host = os.getenv('REDIS_HOST', 'redis-db')
redis = Redis(host=redis_host, port=6379)

@app.route('/')
def hello():
    try:
        visits = redis.incr("counter")
    except Exception as e:
        visits = f"Redis baglantisi kurulamadi: {str(e)}"
    
    return f"<h1>DevOps Journey - Day 4 🌐</h1><p>Bu sayfa <b>{visits}</b> kez ziyaret edildi.</p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
