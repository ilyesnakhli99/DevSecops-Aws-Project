from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "status": "success",
        "message": "Welcome to the iVolve Production Application! 🚀

I am thrilled to welcome you to this second edition—and this time, I am the proud owner of this fully automated, production-grade deployment!

I built this end-to-end framework to showcase how modern cloud-native infrastructures operate. It bridges the gap between raw cloud resources and zero-touch continuous delivery. I truly hope you enjoy exploring the architecture and the engineering that went into making it seamless.

If you have any feedback, insights, or simply want to collaborate, I would love to connect with you!
📥 Email: ilyesnakhlii188@gmail.com

💼 LinkedIn: ilyes-nakhli",
        "environment": "Amazon EKS (Kubernetes)"
    })

@app.route('/health')
def health():
    # A health check endpoint is mandatory for Kubernetes and Load Balancers
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    # Run on port 5000 and listen on all network interfaces
    app.run(host='0.0.0.0', port=5000)