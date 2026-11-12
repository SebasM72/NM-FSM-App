import pytest
from app import db, Students

def test_student_instantiation(flask_app):
    """Model fields are set on instantiation."""
    s = Students(name="Jane Doe", city="Miami",
                 addr="123 Main St", pin="33101",
                 phone_number="305-555-1234")
    assert s.name == "Jane Doe"
    assert s.city == "Miami"
    assert s.phone_number == "305-555-1234"

def test_student_saved_to_db(flask_app):
    """Student is queryable after commit."""
    s = Students(name="Alice Test", city="Miami",
                 addr="1 Main St", pin="33101",
                 phone_number="305-555-0001")
    db.session.add(s)
    db.session.commit()
    result = Students.query.filter_by(name="Alice Test").first()
    assert result is not None
    assert result.city == "Miami"

def test_all_fields_persisted(flask_app):
    """Every field stored and retrieved correctly."""
    s = Students(name="Bob Test", city="Hialeah",
                 addr="2 Oak Ave", pin="33012",
                 phone_number="305-555-0002")
    db.session.add(s)
    db.session.commit()
    r = Students.query.filter_by(name="Bob Test").first()
    assert r.city == "Hialeah"
    assert r.pin == "33012"

def test_student_count_increases(flask_app):
    """Row count increases after insert."""
    before = Students.query.count()
    s = Students(name="Carol Test", city="Doral",
                 addr="3 Pine Rd", pin="33178",
                 phone_number="305-555-0003")
    db.session.add(s)
    db.session.commit()
    assert Students.query.count() == before + 1

def test_student_delete(flask_app):
    """Deleted student is absent from DB."""
    s = Students(name="Dave Test", city="Miami",
                 addr="4 Elm St", pin="33101",
                 phone_number="305-555-0004")
    db.session.add(s)
    db.session.commit()
    db.session.delete(s)
    db.session.commit()
    assert Students.query.filter_by(name="Dave Test").first() is None
