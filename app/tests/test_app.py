import json
import pytest
from app.main import app  


@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_health_endpoint(client):
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'healthy'
    assert 'version' in data


def test_ready_endpoint(client):
    response = client.get('/ready')
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == 'ready'


def test_get_tasks(client):
    response = client.get('/api/tasks')
    assert response.status_code == 200
    data = response.get_json()
    assert isinstance(data, list)
    assert len(data) >= 1


def test_add_task(client):
    payload = {"title": "Write tests"}
    response = client.post(
        '/api/tasks',
        data=json.dumps(payload),
        content_type='application/json'
    )
    assert response.status_code == 201
    data = response.get_json()
    assert data['title'] == "Write tests"
    assert data['status'] == "pending"


def test_update_task(client):
    payload = {"status": "completed"}
    response = client.put(
        '/api/tasks/1',
        data=json.dumps(payload),
        content_type='application/json'
    )
    assert response.status_code == 200
    data = response.get_json()
    assert data['status'] == "completed"


def test_delete_task(client):
    response = client.delete('/api/tasks/2')
    assert response.status_code == 200
    data = response.get_json()
    assert data['message'] == "Task deleted"