# ---------------------------
# Stage 1: Build dependencies
# ---------------------------
FROM python:3.11-slim AS build

WORKDIR /app

# Install minimal tools for building Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc wget \
    && rm -rf /var/lib/apt/lists/*

# Copy application files
COPY flask_app/ /app/flask_app/
COPY models/vectorizer.pkl /app/models/vectorizer.pkl

# Install all Python dependencies
RUN pip install --no-cache-dir -r flask_app/requirements.txt
RUN python -m nltk.downloader -d /usr/local/share/nltk_data stopwords wordnet


# ---------------------------
# Stage 2: Runtime container
# ---------------------------
FROM python:3.11-slim AS runtime

WORKDIR /app

# Copy only installed dependencies from build stage
COPY --from=build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=build /usr/local/bin /usr/local/bin
COPY --from=build /usr/local/share/nltk_data /usr/local/share/nltk_data

# Copy only the necessary app files
COPY flask_app/ /app/flask_app/
COPY models/vectorizer.pkl /app/models/vectorizer.pkl

# Expose the Flask port
EXPOSE 5000

# Command to start the app
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "flask_app.app:app"]
