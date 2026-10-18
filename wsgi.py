# wsgi.py
# Gunicorn entry point — keeps app.py clean
from app import app

if __name__ == "__main__":
    app.run()
