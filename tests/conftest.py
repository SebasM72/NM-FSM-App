import pytest
from app import app, db

@pytest.fixture(scope="function")
def flask_app():
    """Fresh in-memory SQLite for every test.
    No cross-test contamination possible; set in pytest.ini."""
    app.config.update({
        "TESTING": True,
        "SQLALCHEMY_DATABASE_URI": "sqlite:///:memory:"
    })
    with app.app_context():
        db.create_all()
        yield app
        db.drop_all()

@pytest.fixture(scope="function")
def client(flask_app):
    """Flask test client for HTTP tests."""
    return flask_app.test_client()
