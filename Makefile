# Makefile - DevMate Style

STACK_NAME=serverless-product-api
BUCKET_NAME=serverless-product-api-deploy
ZIP_NAME=lambda_package.zip
TEMPLATE_PATH=templates/cloudformation.yml
PROJECT_NAME=serverless-product-api
FUNCTION_DIR=functions
API_URL_CMD=aws cloudformation describe-stacks --stack-name $(STACK_NAME) --query "Stacks[0].Outputs[?OutputKey=='ApiUrl'].OutputValue" --output text

.PHONY: all package upload deploy test destroy 

all: package upload deploy test prompt_destroy

package:
	@echo "📦 Empacotando função Lambda..."
	rm -f $(ZIP_NAME)
	cd $(FUNCTION_DIR) && zip -r ../$(ZIP_NAME) . > /dev/null
	@echo "✅ Pacote criado: $(ZIP_NAME)"

upload:
	@echo "🪣 Criando bucket $(BUCKET_NAME)..."
	@aws s3 mb s3://$(BUCKET_NAME) 2>/dev/null || echo "ℹ️ Bucket $(BUCKET_NAME) já existe."
	@echo "🚀 Upload para bucket S3..."
	aws s3 cp $(ZIP_NAME) s3://$(BUCKET_NAME)/$(ZIP_NAME)
	@echo "✅ Upload concluído."

deploy:
	@echo "🚀 Fazendo deploy da stack..."
	aws cloudformation deploy \
		--template-file $(TEMPLATE_PATH) \
		--stack-name $(STACK_NAME) \
		--capabilities CAPABILITY_NAMED_IAM \
		--parameter-overrides ProjectName=$(PROJECT_NAME)
	@echo "✅ Deploy finalizado."

test:
	@echo "🔎 Obtendo URL da API..."
	$(eval API_URL := $(shell $(API_URL_CMD)))
	@echo "🔗 URL: $(API_URL)"
	@echo "⏳ Aguardando propagação..."
	sleep 10
	@echo "🧪 Realizando teste com curl..."
	curl -s -X POST $(API_URL) \
		-H "Content-Type: application/json" \
		-d '{"nome": "Cerveja DevMate", "preco": 8.90, "imagem": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO9WDRcAAAAASUVORK5CYII="}'
	@echo "\n✅ Teste concluído."

destroy:
	@echo "🗑️ Deletando recursos..."
	@MAIN_BUCKET="$(PROJECT_NAME)-bucket"; \
	echo "🧹 Limpando arquivos do bucket da aplicação: $$MAIN_BUCKET"; \
	aws s3 rm s3://$$MAIN_BUCKET --recursive 2>/dev/null || echo "⚠️ Bucket da aplicação já limpo ou não existe."; \
	echo "🗑️ Deletando bucket da aplicação: $$MAIN_BUCKET"; \
	aws s3 rb s3://$$MAIN_BUCKET 2>/dev/null || echo "⚠️ Falha ao remover bucket da aplicação."; \
	echo "🧹 Limpando arquivos do bucket de deploy: $(BUCKET_NAME)"; \
	aws s3 rm s3://$(BUCKET_NAME) --recursive 2>/dev/null || echo "⚠️ Bucket de deploy já limpo ou não existe."; \
	echo "🗑️ Deletando bucket de deploy: $(BUCKET_NAME)"; \
	aws s3 rb s3://$(BUCKET_NAME) 2>/dev/null || echo "⚠️ Falha ao remover bucket de deploy."; \
	echo "🗑️ Deletando stack CloudFormation..."; \
	aws cloudformation delete-stack --stack-name $(STACK_NAME); \
	echo "⏳ Aguardando deleção da stack..."; \
	bash -c 'aws cloudformation wait stack-delete-complete --stack-name $(STACK_NAME) && echo "✅ Stack deletada com sucesso." || echo "⚠️ Falha ao deletar stack. Verifique no console."'

prompt_destroy:
	@read -p "❓ Deseja deletar a stack '$(STACK_NAME)' e os buckets S3? (s/N): " CONFIRM; \
	if [ "$$CONFIRM" = "s" ] || [ "$$CONFIRM" = "S" ]; then \
		$(MAKE) destroy; \
	else \
		echo "ℹ️ Recursos mantidos conforme solicitado."; \
	fi
