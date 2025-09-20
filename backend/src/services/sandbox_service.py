import asyncio
from browser_use.agent import Agent
from ..services.ag_ui_service import ag_ui_service

class SandboxService:
    """
    Provides services for executing code and browser automation in a sandboxed environment.
    """
    def __init__(self, llm):
        self.llm = llm

    async def perform_browser_task(self, session_id, task_description):
        """
        Uses browser-use to perform a browser automation task.
        """
        ag_ui_service.emit_event(session_id, 'agent_thinking', {'message': 'Starting browser task...'})

        try:
            # This is a simplified example of how to use browser-use.
            # In a real application, you would want to manage the agent's lifecycle
            # and stream its thoughts and actions back to the user.
            agent = Agent(llm=self.llm, task=task_description)
            result = await agent.run()

            ag_ui_service.emit_event(session_id, 'agent_action', {'result': result})
            return result
        except Exception as e:
            error_message = f"An error occurred during browser task: {e}"
            ag_ui_service.emit_event(session_id, 'error', {'message': error_message})
            return {"error": error_message}

    def execute_python_code(self, session_id, code):
        """
        Executes Python code in a restricted environment.

        NOTE: This is a basic implementation and not secure for production.
        In a real-world scenario, this should use a proper sandboxing technology
        like Docker containers or gVisor.
        """
        ag_ui_service.emit_event(session_id, 'agent_action', {'action': 'Executing Python code', 'code': code})

        try:
            # WARNING: exec is not secure!
            # For demonstration purposes only.
            local_scope = {}
            exec(code, {}, local_scope)
            result = local_scope.get('result', 'Code executed successfully, but no "result" variable was set.')

            ag_ui_service.emit_event(session_id, 'progress_update', {'output': str(result)})
            return {"result": str(result)}
        except Exception as e:
            error_message = f"An error occurred during code execution: {e}"
            ag_ui_service.emit_event(session_id, 'error', {'message': error_message})
            return {"error": error_message}
