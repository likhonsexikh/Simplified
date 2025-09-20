from flask import Flask
from flask_cors import CORS

def create_app():
    app = Flask(__name__)
    CORS(app)

    # Import and register blueprints
    from .routes.ag_ui_routes import ag_ui_bp
    from .routes.agent_routes import agent_bp

    app.register_blueprint(ag_ui_bp)
    app.register_blueprint(agent_bp)

    @app.route('/health')
    def health():
        return "OK"

    return app
