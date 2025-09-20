import { useState, useEffect, useRef } from 'react';
import { createSession, getEvents, executeTask } from './api';
import './App.css';

function App() {
  const [sessionId, setSessionId] = useState(null);
  const [inputValue, setInputValue] = useState('');
  const [events, setEvents] = useState([]);
  const [isExecuting, setIsExecuting] = useState(false);
  const eventDisplayRef = useRef(null);

  // Create a new session on component mount
  useEffect(() => {
    const startSession = async () => {
      try {
        const session = await createSession();
        setSessionId(session.id);
        setEvents(session.events);
      } catch (error) {
        console.error("Failed to start session:", error);
      }
    };
    startSession();
  }, []);

  // Poll for new events
  useEffect(() => {
    if (!sessionId) return;

    const intervalId = setInterval(async () => {
      try {
        const lastEventId = events.length > 0 ? events[events.length - 1].id : -1;
        const newEvents = await getEvents(sessionId, lastEventId);
        if (newEvents.length > 0) {
          setEvents((prevEvents) => [...prevEvents, ...newEvents]);
        }
      } catch (error) {
        console.error("Failed to fetch events:", error);
      }
    }, 2000); // Poll every 2 seconds

    return () => clearInterval(intervalId);
  }, [sessionId, events]);

  // Auto-scroll to the bottom of the event display
  useEffect(() => {
    if (eventDisplayRef.current) {
      eventDisplayRef.current.scrollTop = eventDisplayRef.current.scrollHeight;
    }
  }, [events]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!inputValue.trim() || !sessionId || isExecuting) return;

    setIsExecuting(true);
    try {
      // Emit a user_input event locally for immediate feedback
      const userInputEvent = {
        id: events.length,
        type: 'user_input',
        data: { input: inputValue },
        timestamp: Date.now() / 1000
      };
      setEvents(prevEvents => [...prevEvents, userInputEvent]);

      await executeTask(sessionId, inputValue);
      setInputValue('');
    } catch (error) {
      console.error("Failed to send input:", error);
    } finally {
      setIsExecuting(false);
    }
  };

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>AI Agent System</h1>
        <p>Session ID: {sessionId || 'Initializing...'}</p>
      </header>
      <main className="event-display" ref={eventDisplayRef}>
        {events.map((event) => (
          <div key={event.id} className={`event event-${event.type}`}>
            <strong>{event.type}</strong>
            <pre>{JSON.stringify(event.data, null, 2)}</pre>
          </div>
        ))}
        {isExecuting && <div className="event event-thinking">Agent is thinking...</div>}
      </main>
      <footer className="input-area">
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            placeholder="Enter your task..."
            disabled={!sessionId || isExecuting}
          />
          <button type="submit" disabled={!sessionId || isExecuting}>
            {isExecuting ? 'Executing...' : 'Send'}
          </button>
        </form>
      </footer>
    </div>
  );
}

export default App;
