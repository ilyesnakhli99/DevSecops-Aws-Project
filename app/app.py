from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({
        "status": "success",
        "message": "Welcome to the second edition of the this time iam the owner of iVolve Production Application!",
        "environment": "Amazon EKS (Kubernetes)"
    })

@app.route('/health')
def health():
    # A health check endpoint is mandatory for Kubernetes and Load Balancers
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    # Run on port 5000 and listen on all network interfaces
    app.run(host='0.0.0.0', port=5000)