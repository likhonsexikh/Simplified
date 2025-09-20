import asyncio
import os
import google.generativeai as genai
from .sandbox_service import SandboxService
from ..services.ag_ui_service import ag_ui_service

class AgentService:
    """
    Orchestrates AI agent tasks, using other services to execute them.
    """
    def __init__(self):
        """
        Initializes the AgentService and the Gemini LLM.
        """
        self.llm = None
        try:
            api_key = os.environ.get("GOOGLE_API_KEY")
            if not api_key:
                raise ValueError("GOOGLE_API_KEY environment variable not set.")

            genai.configure(api_key=api_key)
            self.llm = genai.GenerativeModel('gemini-pro')
        except Exception as e:
            print(f"Error initializing Gemini LLM: {e}")
            # The service will run without LLM capabilities if initialization fails.

        self.sandbox_service = SandboxService(llm=self.llm)

    def execute_task(self, session_id, task_description):
        """
        Executes a task based on its description.
        """
        ag_ui_service.emit_event(session_id, 'task_started', {'task': task_description})

        if not self.llm:
            error_message = "LLM is not available. Please check the API key."
            ag_ui_service.emit_event(session_id, 'error', {'message': error_message})
            return {"error": error_message}

        # Simple routing based on keywords.
        # The real LLM magic happens inside browser-use.
        browser_keywords = ["http", "www", "navigate", "search", "browse", "go to"]
        if any(keyword in task_description.lower() for keyword in browser_keywords):
            try:
                result = asyncio.run(self.sandbox_service.perform_browser_task(session_id, task_description))
            except Exception as e:
                result = {"error": str(e)}
        else:
            # For now, assume other tasks are Python code. A more robust solution
            # would use the LLM to classify the task.
            result = self.sandbox_service.execute_python_code(session_id, task_description)

        ag_ui_service.emit_event(session_id, 'task_complete', {'result': result})
        return result

# Singleton instance
agent_service = AgentService()
