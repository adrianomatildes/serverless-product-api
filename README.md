# 📦 Serverless Product API

API para cadastro de produtos utilizando AWS Lambda, API Gateway, DynamoDB e S3. Automação via Makefile + CI/CD com GitHub Actions.

---

## ⚙️ Makefile (DevMate Style)

| Comando             | Ação executada                                         |
|---------------------|--------------------------------------------------------|
| `make package`      | Empacota o código da função Lambda (.zip)              |
| `make upload`       | Cria bucket e envia o pacote para o S3                 |
| `make deploy`       | Realiza deploy da stack via CloudFormation             |
| `make test`         | Testa a API com chamada automática via `curl`          |
| `make destroy`      | Remove a stack, buckets e objetos                      |
| `make`              | Executa package, upload, deploy e test (pipeline local)|

---

## 🚀 CI/CD via GitHub Actions

### 🔧 Variáveis e Secrets usados

- **Secrets**
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_REGION`
- **Variables**
  - `STACK_NAME`, `BUCKET_NAME`, `ZIP_NAME`, `PROJECT_NAME`, `FUNCTION_DIR`, `TEMPLATE_PATH`

### 🔘 Execução manual (workflow_dispatch)

Você pode rodar a pipeline manualmente no GitHub (Aba **Actions → Deploy stack via Makefile → Run workflow**):

**Inputs:**
- `make_target`: comando do Makefile a ser executado (`all`, `package`, `deploy`, `test`, `destroy`)
- `DESTROY_AFTER`: `true` para destruir o ambiente ao final (usado para testes temporários)

---

## 🧪 Exemplo de uso interativo

Para fazer um deploy temporário e destruir ao final:

```bash
make DESTROY_AFTER=true
