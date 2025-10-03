import dagshub
import mlflow

dagshub.init(repo_owner='washim04x', repo_name='mlops-min-project', mlflow=True)
mlflow.set_tracking_uri('https://dagshub.com/washim04x/mlops-min-project.mlflow')

with mlflow.start_run():
  mlflow.log_param('parameter name', 'value')
  mlflow.log_metric('metric name', 1)
# https://dagshub.com/washim04x/mlops-min-project.mlflow