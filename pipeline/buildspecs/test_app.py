import requests

def test_health_check():
    response = requests.get("https://your-domain.com/health")
    assert response.status_code == 200
