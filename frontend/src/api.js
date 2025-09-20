import axios from 'axios';

const apiClient = axios.create({
  baseURL: '/api', // Base URL for all API calls
});

// AG-UI Endpoints
export const createSession = async () => {
  try {
    const response = await apiClient.post('/ag-ui/sessions');
    return response.data;
  } catch (error) {
    console.error('Error creating session:', error);
    throw error;
  }
};

export const getEvents = async (sessionId, lastEventId = -1) => {
  try {
    const response = await apiClient.get(`/ag-ui/sessions/${sessionId}/events`, {
      params: { last_event_id: lastEventId },
    });
    return response.data;
  } catch (error) {
    console.error('Error fetching events:', error);
    throw error;
  }
};

// Agent Endpoints
export const executeTask = async (sessionId, task) => {
    try {
        const response = await apiClient.post('/agent/tasks', { session_id: sessionId, task: task });
        return response.data;
    } catch (error) {
        console.error('Error executing task:', error);
        throw error;
    }
};
