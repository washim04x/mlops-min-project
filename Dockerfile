# Stage 1: Build the application
FROM python:3.11 AS Build

WORKDIR /app

# Copy Flask app
COPY flask_app/ /app/flask_app/

# Copy models into flask_app so the relative path works
COPY models/vectorizer.pkl /app/models/vectorizer.pkl

# Install requirements
RUN pip install --no-cache-dir -r flask_app/requirements.txt
RUN python -m nltk.downloader stopwords wordnet

# Stage 2: Run the application
FROM python:3.11-slim AS Run

WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=Build /app /app

# Copy installed Python packages and executables from the build stage
COPY --from=Build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=Build /usr/local/bin /usr/local/bin

# Expose the port
EXPOSE 5000

# Run the app with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "flask_app.app:app"]
