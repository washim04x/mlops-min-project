from flask import Flask,render_template,request
import mlflow
from .preprocessing_utility import normalize_text
import pickle
import os
vectorizer = pickle.load(open('models/vectorizer.pkl','rb'))

# Set up DagsHub credentials for MLflow tracking
dagshub_token = os.getenv("DAGSHUB_PAT")
if not dagshub_token:
    raise EnvironmentError("DAGSHUB_PAT environment variable is not set")

os.environ["MLFLOW_TRACKING_USERNAME"] = dagshub_token
os.environ["MLFLOW_TRACKING_PASSWORD"] = dagshub_token

import dagshub
dagshub_url = "https://dagshub.com"
repo_owner = "washim04x"
repo_name = "mlops-min-project"

# # Set up MLflow tracking URI
mlflow.set_tracking_uri(f'{dagshub_url}/{repo_owner}/{repo_name}.mlflow')
dagshub.init(repo_owner=repo_owner, repo_name=repo_name, mlflow=True)


app = Flask(__name__)


def get_latest_model_version(model_name):
    client = mlflow.tracking.MlflowClient()
    versions = client.get_latest_versions(name=model_name, stages=["Production"])
    if not versions:
        raise ValueError(f"No versions found for model '{model_name}' in Staging or Production stages.")
    latest_version = max(versions, key=lambda v: v.version)
    return latest_version.version


# load model
model_name = 'model'
model_version = get_latest_model_version(model_name)
model_uri = f"models:/{model_name}/{model_version}"
model = mlflow.pyfunc.load_model(model_uri)


@app.route('/')
def home():
    return  render_template('index.html',prediction=None)

@app.route('/predict',methods=['POST']) 
def predict():
    text = request.form['text']
    # clean
    text=normalize_text(text)
    # bow
    features=vectorizer.transform([text])
    # predict sentiment
    result=model.predict(features)
    return  render_template('index.html',prediction=result[0])

if __name__ == '__main__':
    app.run(debug=True)