from flask import Blueprint, request, jsonify
from ..services.agent_service import agent_service

agent_bp = Blueprint('agent_bp', __name__, url_prefix='/api/agent')

@agent_bp.route('/tasks', methods=['POST'])
def execute_task():
    """
    Receives a task and executes it using the AgentService.
    """
    data = request.json
    session_id = data.get('session_id')
    task_description = data.get('task')

    if not session_id or not task_description:
        return jsonify({'error': 'session_id and task are required'}), 400

    # This is a fire-and-forget call. The client will get updates via polling.
    # In a more advanced setup, you might use WebSockets or a task queue.
    # For now, we run this synchronously for simplicity, but it could block.
    result = agent_service.execute_task(session_id, task_description)

    return jsonify(result), 202 # Accepted
