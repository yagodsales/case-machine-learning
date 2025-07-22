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

# Load modelo
model = joblib.load('model.pkl')

def lambda_handler(event, context):
    path = event.get('path')
    method = event.get('httpMethod')

    if path == '/sobreviventes' and method == 'POST':
        return handle_post(event)
    elif path == '/sobreviventes' and method == 'GET':
        return handle_get_all()
    elif path.startswith('/sobreviventes/') and method == 'GET':
        passageiro_id = event.get('pathParameters', {}).get('id') or path.split('/')[-1]
        return handle_get(passageiro_id)
    elif path.startswith('/sobreviventes/') and method == 'DELETE':
        passageiro_id = event.get('pathParameters', {}).get('id') or path.split('/')[-1]
        return handle_delete(passageiro_id)
    else:
        return response(404, {'error': 'Rota não encontrada'})

def handle_post(event):
    try:
        body = json.loads(event.get('body') or '{}')

        caracteristicas = body.get('caracteristicas')
        if not isinstance(caracteristicas, list):
            return response(400, {'error': 'Campo "caracteristicas" deve ser um array'})

        passageiro_id = body.get('id') or str(uuid.uuid4())
        prob = float(model.predict_proba([caracteristicas])[0][1])

        item = {
            'id': passageiro_id,
            'probabilidade_sobrevivencia': Decimal(str(prob)),
            'caracteristicas': json.dumps(caracteristicas)
        }
        table.put_item(Item=item)

        return response(200, {
            'id': passageiro_id,
            'probabilidade_sobrevivencia': prob
        })

    except Exception as e:
        return response(500, {'error': str(e)})

def handle_get_all():
    try:
        items = table.scan().get('Items', [])
        return response(200, items)
    except Exception as e:
        return response(500, {'error': str(e)})

def handle_get(passageiro_id):
    try:
        item = table.get_item(Key={'id': passageiro_id}).get('Item')
        if item:
            return response(200, item)
        else:
            return response(404, {'error': 'Passageiro não encontrado'})
    except Exception as e:
        return response(500, {'error': str(e)})

def handle_delete(passageiro_id):
    try:
        item = table.get_item(Key={'id': passageiro_id}).get('Item')
        if not item:
            return response(404, {'error': 'Passageiro não encontrado'})

        table.delete_item(Key={'id': passageiro_id})
        return {
            'statusCode': 204,
            'headers': {'Content-Type': 'application/json'},
            'body': ''
        }
    except Exception as e:
        return response(500, {'error': str(e)})

def response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps(body, default=str)
    }
