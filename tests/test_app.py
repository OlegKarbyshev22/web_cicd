from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_home_page() -> None:
    response = client.get("/")

    assert response.status_code == 200
    assert "FastAPI CI/CD Lab" in response.text


def test_health() -> None:
    response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_message() -> None:
    response = client.get("/api/message")

    assert response.status_code == 200
    assert response.json()["message"] == "Hello from FastAPI CI/CD lab!"

