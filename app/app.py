from flask import Flask, render_template_string

app = Flask(__name__)

@app.route('/')
def home():
    # Modern, clean HTML with a responsive dark-gradient UI layout
    html_template = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>iVolve Production Application</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            }
            body {
                background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #311042 100%);
                color: #f8fafc;
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
                padding: 20px;
            }
            .card {
                background: rgba(255, 255, 255, 0.03);
                backdrop-filter: blur(12px);
                border: 1px solid rgba(255, 255, 255, 0.08);
                border-radius: 24px;
                padding: 40px;
                max-width: 600px;
                width: 100%;
                text-align: center;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
            }
            .badge {
                display: inline-block;
                background: linear-gradient(90deg, #3b82f6, #8b5cf6);
                color: white;
                font-size: 0.75rem;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                padding: 6px 16px;
                border-radius: 100px;
                margin-bottom: 20px;
            }
            h1 {
                font-size: 2.25rem;
                font-weight: 800;
                line-height: 1.2;
                margin-bottom: 16px;
                background: linear-gradient(to right, #ffffff, #cbd5e1);
                -webkit-background-clip: text;
                -webkit-text-fill-color: transparent;
            }
            p {
                color: #94a3b8;
                font-size: 1.1rem;
                line-height: 1.6;
                margin-bottom: 30px;
            }
            .divider {
                height: 1px;
                background: rgba(255, 255, 255, 0.1);
                margin: 24px 0;
            }
            .links {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }
            .btn {
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 14px;
                border-radius: 12px;
                text-decoration: none;
                font-weight: 600;
                transition: all 0.2s ease;
            }
            .btn-email {
                background: #ffffff;
                color: #0f172a;
            }
            .btn-email:hover {
                background: #f1f5f9;
                transform: translateY(-2px);
            }
            .btn-linkedin {
                background: rgba(255, 255, 255, 0.08);
                color: #ffffff;
                border: 1px solid rgba(255, 255, 255, 0.1);
            }
            .btn-linkedin:hover {
                background: rgba(255, 255, 255, 0.15);
                transform: translateY(-2px);
            }
        </style>
    </head>
    <body>
        <div class="card">
            <span class="badge">Live on Amazon EKS</span>
            <h1>iVolve Production App</h1>
            <p>Welcome! I hope you loved exploring this automated GitOps architecture.</p>
            
            <div class="divider"></div>
            
            <div class="links">
                <a href="mailto:ilyesnakhlii188@gmail.com" class="btn btn-email">📧 Connect via Email</a>
                <a href="https://www.linkedin.com/in/ilyes-nakhli/" target="_blank" class="btn btn-linkedin">💼 Visit my LinkedIn</a>
            </div>
        </div>
    </body>
    </html>
    """
    return render_template_string(html_template)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)