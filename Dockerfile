FROM python:3.11

WORKDIR /app

# Copy Flask app
COPY flask_app/ /app/flask_app/

# Copy models into flask_app so the relative path works
COPY models/vectorizer.pkl /app/models/vectorizer.pkl

# Install requirements
RUN pip install -r flask_app/requirements.txt
RUN python -m nltk.downloader stopwords wordnet

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "flask_app.app:app"]

