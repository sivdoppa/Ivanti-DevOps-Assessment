"""
Task Manager Web Application
A simple Flask app for the DevOps assessment
"""

from flask import Flask, render_template, request, jsonify
from datetime import datetime
import os
import psutil

app = Flask(__name__)

# In-memory storage (No database needed!)
tasks = [
    {"id": 1, "title": "Deploy to AKS", "status": "completed", "created": "2024-01-10"},
    {"id": 2, "title": "Setup CI/CD Pipeline", "status": "in-progress", "created": "2024-01-10"},
    {"id": 3, "title": "Configure Monitoring", "status": "pending", "created": "2024-01-10"}
]

APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
ENVIRONMENT = os.getenv('ENVIRONMENT', 'local')

@app.route('/')
def index():
    """Main dashboard"""
    return render_template('index.html', 
                         tasks=tasks, 
                         app_version=APP_VERSION,
                         environment=ENVIRONMENT)

@app.route('/tasks')
def list_tasks():
    """All tasks page"""
    return render_template('tasks.html', 
                         tasks=tasks,
                         app_version=APP_VERSION,
                         environment=ENVIRONMENT)

@app.route('/about')
def about():
    """System info page"""
    system_info = {
        "hostname": os.getenv('HOSTNAME', 'localhost'),
        "app_version": APP_VERSION,
        "environment": ENVIRONMENT,
        "python_version": os.sys.version,
        "cpu_percent": psutil.cpu_percent(interval=1),
        "memory_percent": psutil.virtual_memory().percent,
        "disk_percent": psutil.disk_usage('/').percent,
        "current_time": datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }
    return render_template('about.html', info=system_info)

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    """API: Get all tasks"""
    return jsonify(tasks)

@app.route('/api/tasks', methods=['POST'])
def add_task():
    """API: Add new task"""
    data = request.get_json()
    new_task = {
        "id": max([t['id'] for t in tasks], default=0) + 1,
        "title": data.get('title', 'Untitled'),
        "status": "pending",
        "created": datetime.now().strftime('%Y-%m-%d')
    }
    tasks.append(new_task)
    return jsonify(new_task), 201

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    """API: Update task"""
    data = request.get_json()
    for task in tasks:
        if task['id'] == task_id:
            task['status'] = data.get('status', task['status'])
            return jsonify(task)
    return jsonify({"error": "Task not found"}), 404

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    """API: Delete task"""
    global tasks
    tasks = [t for t in tasks if t['id'] != task_id]
    return jsonify({"message": "Task deleted"}), 200

@app.route('/health')
def health():
    """Health check for Kubernetes"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": APP_VERSION
    }), 200

@app.route('/ready')
def ready():
    """Readiness check for Kubernetes"""
    return jsonify({
        "status": "ready",
        "timestamp": datetime.utcnow().isoformat()
    }), 200

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    print(f"🚀 Starting Task Manager on http://localhost:{port}")
    print(f"📊 Environment: {ENVIRONMENT}")
    print(f"📦 Version: {APP_VERSION}")
    app.run(host='0.0.0.0', port=port, debug=True)