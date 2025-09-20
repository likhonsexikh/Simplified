import uuid
import time
from threading import Lock

class AgUiService:
    """
    Manages AG-UI sessions, events, and context for real-time communication
    between the AI agent and the user interface.
    """
    _instance = None
    _lock = Lock()

    def __new__(cls):
        with cls._lock:
            if cls._instance is None:
                cls._instance = super(AgUiService, cls).__new__(cls)
                cls._instance.sessions = {}
        return cls._instance

    def create_session(self):
        """
        Creates a new session and returns the session ID.
        """
        session_id = str(uuid.uuid4())
        self.sessions[session_id] = {
            'id': session_id,
            'events': [],
            'context': {},
            'created_at': time.time()
        }
        self.emit_event(session_id, 'session_created', {'session_id': session_id})
        return session_id

    def get_session(self, session_id):
        """
        Retrieves a session by its ID.
        """
        return self.sessions.get(session_id)

    def emit_event(self, session_id, event_type, data):
        """
        Emits a new event to a session.
        """
        session = self.get_session(session_id)
        if not session:
            return

        event = {
            'id': len(session['events']),
            'type': event_type,
            'data': data,
            'timestamp': time.time()
        }
        session['events'].append(event)
        return event

    def get_events(self, session_id, last_event_id=None):
        """
        Retrieves events from a session, optionally after a given event ID.
        """
        session = self.get_session(session_id)
        if not session:
            return []

        if last_event_id is None:
            return session['events']

        last_event_id = int(last_event_id)
        return session['events'][last_event_id + 1:]

    def update_context(self, session_id, context_data):
        """
        Updates the context for a session.
        """
        session = self.get_session(session_id)
        if not session:
            return None

        session['context'].update(context_data)
        self.emit_event(session_id, 'context_updated', session['context'])
        return session['context']

    def add_user_input(self, session_id, input_data):
        """
        Adds user input to the session as a special event.
        """
        return self.emit_event(session_id, 'user_input', {'input': input_data})

# Singleton instance
ag_ui_service = AgUiService()
