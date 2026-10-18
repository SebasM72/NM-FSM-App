# Dockerfile
# ── Stage 1: Base image ──────────────────────────────────────
FROM public.ecr.aws/docker/library/python:3.12-slim

# Set working directory inside the container
WORKDIR /app

# ── Install dependencies first (layer caching optimisation) ──
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ── Copy application source code ─────────────────────────────
COPY . .

# ── Runtime environment variables ────────────────────────────
# DATABASE_URL is injected by Fargate task definition at runtime
# NEVER hardcode the connection string here
ENV FLASK_ENV=production
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# ── Document the port the app listens on ─────────────────────
EXPOSE 5000

# ── Start with Gunicorn (production WSGI server) ─────────────
# Flask's built-in dev server is NOT suitable for production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "120", "wsgi:app"]
