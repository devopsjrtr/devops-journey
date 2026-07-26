from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    version = os.getenv('APP_VERSION', 'v1.0')
    return f"<h1>DevOps Yolculuğu - Day 3 🚀</h1><p>Python/Flask Uygulaması Container İçinde Çalışıyor! Versiyon: {version}</p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
