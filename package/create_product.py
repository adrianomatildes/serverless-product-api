import json
import boto3
import uuid
import base64
import os
import datetime

dynamodb = boto3.resource('dynamodb')
s3 = boto3.client('s3')

DYNAMO_TABLE = os.environ.get('DYNAMO_TABLE')
S3_BUCKET = os.environ.get('S3_BUCKET')

def handler(event, context):
    try:
        body = json.loads(event['body'])

        nome = body['nome']
        preco = float(body['preco'])
        imagem_base64 = body['imagem']

        # Gerar UUID e nome do arquivo
        product_id = str(uuid.uuid4())
        filename = f'products/{product_id}.png'

        # Decodificar imagem
        imagem_bytes = base64.b64decode(imagem_base64.split(",")[-1])

        # Upload para o S3
        s3.put_object(
            Bucket=S3_BUCKET,
            Key=filename,
            Body=imagem_bytes,
            ContentType='image/png'
        )

        # Salvar no DynamoDB
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
            'body': json.dumps({'message': 'Produto criado com sucesso', 'product_id': product_id})
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }