import json
import boto3
import uuid
import base64
import os
import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

DYNAMO_TABLE = os.environ.get('DYNAMO_TABLE')
S3_BUCKET = os.environ.get('S3_BUCKET')

def handler(event, context):
    method = event.get("httpMethod", "GET")

    try:
        if method == "POST":
            body = json.loads(event['body'])

            nome = body['nome']
            preco = Decimal(str(body['preco']))
            imagem_base64 = body['imagem']

            product_id = str(uuid.uuid4())
            filename = f'products/{product_id}.png'

            imagem_bytes = base64.b64decode(imagem_base64.split(",")[-1])

            s3.put_object(
                Bucket=S3_BUCKET,
                Key=filename,
                Body=imagem_bytes,
                ContentType='image/png'
            )

            table = dynamodb.Table(DYNAMO_TABLE)
            table.put_item(Item={
                'product_id': product_id,
                'nome': nome,
                'preco': preco,
                's3_key': filename,
                'created_at': datetime.datetime.utcnow().isoformat()
            })

            return {
                'statusCode': 201,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                    'Access-Control-Allow-Headers': 'Content-Type'
                },
                'body': json.dumps({'message': 'Produto criado com sucesso', 'product_id': product_id})
            }

        elif method == "GET":
            table = dynamodb.Table(DYNAMO_TABLE)
            response = table.scan()
            items = response.get('Items', [])

            produtos = []
            for item in items:
                produtos.append({
                    'nome': item['nome'],
                    'preco': float(item['preco']),
                    'imagem': f"https://{S3_BUCKET}.s3.amazonaws.com/{item['s3_key']}"
                })

            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                    'Access-Control-Allow-Headers': 'Content-Type'
                },
                'body': json.dumps(produtos)
            }

        else:
            return {
                'statusCode': 405,
                'body': json.dumps({'error': 'Método não suportado'})
            }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({'error': str(e)})
        }
