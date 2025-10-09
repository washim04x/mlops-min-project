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

#stage 2: Run the application
FROM python:3.11-slim AS Run

WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=Build /app /app

#expose the port

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "flask_app.app:app"]

