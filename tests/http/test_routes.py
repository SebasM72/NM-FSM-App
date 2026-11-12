import pytest
from app import db, Students

def test_index_returns_200(client):
    """GET / returns HTTP 200."""
    assert client.get("/").status_code == 200

def test_new_form_returns_200(client):
    """GET /new returns the student form."""
    assert client.get("/new").status_code == 200

def test_add_student_redirects(client):
    """POST /new with all fields gets 302."""
    r = client.post("/new", data={
        "name": "Alice Smith", "city": "Miami",
        "addr": "123 Main St", "pin": "33101",
        "phone_number": "305-555-1234"
    })
    assert r.status_code == 302

def test_student_appears_on_list(client):
    """Added student appears on home page."""
    client.post("/new", data={
        "name": "Bob Jones", "city": "Hialeah",
        "addr": "1 Oak Ave", "pin": "33012",
        "phone_number": "305-555-0001"
    })
    r = client.get("/", follow_redirects=True)
    assert b"Bob Jones" in r.data

@pytest.mark.parametrize("missing", ["name", "city", "addr"])
def test_required_fields(client, missing):
    """Each required field is rejected. pin and phone are optional."""
    data = {"name": "Alice", "city": "Miami", "addr": "1 St",
            "pin": "33101", "phone_number": "305-555-0000"}
    data[missing] = ""
    before = Students.query.count()
    r = client.post("/new", data=data)
    assert r.status_code == 200
    assert Students.query.count() == before
