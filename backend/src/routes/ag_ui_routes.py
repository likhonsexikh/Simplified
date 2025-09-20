from flask import Blueprint, request, jsonify
from ..services.ag_ui_service import ag_ui_service

ag_ui_bp = Blueprint('ag_ui_bp', __name__, url_prefix='/api/ag-ui')

@ag_ui_bp.route('/sessions', methods=['POST'])
def create_session():
    """
    Creates a new AG-UI session.
    """
    session_id = ag_ui_service.create_session()
    session = ag_ui_service.get_session(session_id)
    return jsonify(session), 201

@ag_ui_bp.route('/sessions/<session_id>', methods=['GET'])
def get_session(session_id):
    """
    Gets information about a specific session.
    """
    session = ag_ui_service.get_session(session_id)
    if not session:
        return jsonify({'error': 'Session not found'}), 404
    return jsonify(session)

@ag_ui_bp.route('/sessions/<session_id>/events', methods=['GET'])
def get_events(session_id):
    """
    Gets events for a session. Supports polling via last_event_id.
    """
    last_event_id = request.args.get('last_event_id')
    events = ag_ui_service.get_events(session_id, last_event_id)
    return jsonify(events)

@ag_ui_bp.route('/sessions/<session_id>/input', methods=['POST'])
def add_user_input(session_id):
    """
    Adds user input to a session.
    """
    data = request.json
    if not data or 'input' not in data:
        return jsonify({'error': 'Input data is required'}), 400

    event = ag_ui_service.add_user_input(session_id, data['input'])
    if not event:
        return jsonify({'error': 'Session not found'}), 404

    return jsonify(event), 201

@ag_ui_bp.route('/sessions/<session_id>/context', methods=['POST'])
def update_context(session_id):
    """
    Updates the context for a session.
    """
    data = request.json
    if not data:
        return jsonify({'error': 'Context data is required'}), 400

    context = ag_ui_service.update_context(session_id, data)
    if not context:
        return jsonify({'error': 'Session not found'}), 404

    return jsonify(context)
