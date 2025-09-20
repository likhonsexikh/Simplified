# AI Agent System

This project is a comprehensive AI agent system with a frontend, backend, and sandbox environment. It allows users to interact with an AI agent using natural language to perform complex tasks like browser automation and code execution.

## 🏗️ Architecture

The system is built with a modular, microservices-oriented architecture:

```
┌─────────────────┐    ┌─────────────────┐
│    Frontend     │    │     Backend     │
│   (React App)   │◄──►│  (Flask API)    │
│                 │    │                 │
│ • AG-UI Client  │    │ • AG-UI Service │
│ • Real-time UI  │    │ • Agent Service │
│ • Task Interface│    │ • Sandbox Service│
└─────────────────┘    └─────────────────┘
```

-   **Frontend**: A React application providing the user interface. It uses the AG-UI protocol to communicate with the backend in real-time.
-   **Backend**: A Flask application that serves the core logic. It includes:
    -   **AG-UI Service**: Manages sessions and real-time event streaming.
    -   **Agent Service**: Orchestrates tasks using an LLM (Gemini).
    -   **Sandbox Service**: Executes tasks like browser automation (via `browser-use`) and code execution.

## ✨ Features

-   **Natural Language Processing**: Powered by Google's Gemini Pro.
-   **Browser Automation**: Utilizes the `browser-use` library for intelligent web navigation and interaction.
-   **Code Execution**: A sandboxed environment for running Python code (Note: current implementation is for demonstration and not production-secure).
-   **Real-time Communication**: Implements the AG-UI (Agent-User Interaction) protocol for live updates and a responsive user experience.
-   **Modular and Scalable**: Built with a clean, service-oriented architecture that is easy to extend.

## 🚀 Getting Started

### Prerequisites

-   Docker and Docker Compose
-   A Google API Key for the Gemini LLM

### Installation & Running

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd <repository-name>
    ```

2.  **Create an environment file:**
    Create a file named `.env` in the root of the project and add your Google API key:
    ```env
    GOOGLE_API_KEY=your_google_api_key_here
    ```

3.  **Build and run the services using Docker Compose:**
    ```bash
    docker-compose up --build
    ```

4.  **Access the application:**
    -   The **Frontend** will be available at `http://localhost:8080`.
    -   The **Backend API** will be available at `http://localhost:5000`.

### How to Use

1.  Open your web browser and navigate to `http://localhost:8080`.
2.  The application will automatically create a new session.
3.  Enter a task in the input box at the bottom of the page.
    -   **For browser tasks**, use natural language (e.g., "Navigate to github.com and search for 'AI agent'").
    -   **For code execution**, type the Python code you want to run.
4.  Click "Send" and watch the agent's progress in the event display.

## 🛠️ Development

The project is structured into two main components: `frontend` and `backend`.

-   **Backend**: A Flask application located in the `backend/` directory. The main application logic is in `backend/src/`.
-   **Frontend**: A React application located in the `frontend/` directory. It was bootstrapped with Vite.

The services are containerized and can be managed using the `docker-compose.yml` file.
