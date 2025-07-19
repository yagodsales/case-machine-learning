import json
import boto3
import pickle
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DDB_TABLE'])

# Carrega modelo
with open('model.pkl', 'rb') as f:
    model = pickle.load(f)

def lambda_handler(event, context):
    method = event['httpMethod']
    path = event['path']

    if method == 'POST' and path == '/sobreviventes':
        body = json.loads(event['body'])
        pid = body['id']
        features = body['features']
        prob = model.predict_proba([features])[0][1]
        item = {'id': pid, 'probability': Decimal(str(prob))}
        table.put_item(Item=item)
        return {
            'statusCode': 200,
            'body': json.dumps({'id': pid, 'probability': prob})
        }

    return {'statusCode': 400, 'body': 'Bad Request'}