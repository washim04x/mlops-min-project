FROM python:3.11

WORKDIR /app

# Copy Flask app
COPY flask_app/ /app/flask_app/

# Copy models into flask_app so the relative path works
COPY models /app/flask_app/models

# Install requirements
COPY requirements.txt /app/
RUN pip install -r requirements.txt
RUN python -m nltk.downloader stopwords wordnet

EXPOSE 5000

WORKDIR /app/flask_app

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--timeout", "120", "app:app"]
