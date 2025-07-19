import json
import boto3
import joblib
import os
import uuid
from decimal import Decimal

# DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMO_TABLE')
table = dynamodb.Table(table_name)

# Load model
model = joblib.load('model.pkl')

def lambda_handler(event, context):
    path = event.get('path')
    method = event.get('httpMethod')

    if path == '/sobreviventes' and method == 'POST':
        return handle_post(event)
    elif path == '/sobreviventes' and method == 'GET':
        return handle_get_all()
    elif path.startswith('/sobreviventes/') and method == 'GET':
        passageiro_id = path.split('/')[-1]
        return handle_get(passageiro_id)
    elif path.startswith('/sobreviventes/') and method == 'DELETE':
        passageiro_id = path.split('/')[-1]
        return handle_delete(passageiro_id)
    else:
        return response(404, {'error': 'Rota não encontrada'})

def handle_post(event):
    try:
        body = json.loads(event['body'])
        features = body['features']  # array de características
        passageiro_id = str(uuid.uuid4())

        probability = float(model.predict_proba([features])[0][1])

        item = {
            'id': passageiro_id,
            'probabilidade': Decimal(str(probability)),
            'features': json.dumps(features)
        }
        table.put_item(Item=item)

        return response(200, {'id': passageiro_id, 'probabilidade': probability})
    except Exception as e:
        return response(500, {'error': str(e)})

def handle_get_all():
    items = table.scan().get('Items', [])
    return response(200, items)

def handle_get(passageiro_id):
    item = table.get_item(Key={'id': passageiro_id}).get('Item')
    if item:
        return response(200, item)
    else:
        return response(404, {'error': 'Passageiro não encontrado'})

def handle_delete(passageiro_id):
    table.delete_item(Key={'id': passageiro_id})
    return response(200, {'message': 'Passageiro deletado'})

def response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps(body)
    }
