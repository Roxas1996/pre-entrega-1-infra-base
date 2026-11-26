# Pre-entrega 1: Infraestructura base

Terraform desplegado en LocalStack (sin cuenta de AWS). Comandos para PowerShell.

**Requisitos:** Docker Desktop (8 GB de RAM), Terraform 1.5+, AWS CLI, Python 3.10+, `pip install terraform-local` y un token de LocalStack.

## Estructura

```
environments/dev/    Backend y llamada a los módulos
modules/network/     VPC, subredes privadas y S3 Gateway Endpoint
modules/identity/    Roles y políticas IAM
```

## 1. Levantar LocalStack

Guarda el token como variable de entorno y abre una terminal nueva:

```powershell
setx LOCALSTACK_AUTH_TOKEN "tu-token"
```

```powershell
docker compose up -d
```

## 2. Crear el backend

```powershell
$env:AWS_ACCESS_KEY_ID="test"; $env:AWS_SECRET_ACCESS_KEY="test"; $env:AWS_DEFAULT_REGION="us-east-1"
aws --endpoint-url=http://localhost:4566 s3 mb s3://tf-state-dev
aws --endpoint-url=http://localhost:4566 s3api put-bucket-encryption --bucket tf-state-dev --server-side-encryption-configuration "Rules=[{ApplyServerSideEncryptionByDefault={SSEAlgorithm=AES256}}]"
aws --endpoint-url=http://localhost:4566 s3api put-bucket-versioning --bucket tf-state-dev --versioning-configuration Status=Enabled
aws --endpoint-url=http://localhost:4566 s3api put-public-access-block --bucket tf-state-dev --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
aws --endpoint-url=http://localhost:4566 dynamodb create-table --table-name tf-lock-dev --attribute-definitions "AttributeName=LockID,AttributeType=S" --key-schema "AttributeName=LockID,KeyType=HASH" --billing-mode PAY_PER_REQUEST
```

## 3. Desplegar

```powershell
cd environments\dev
tflocal init
tflocal validate
tflocal plan "-out=dev.tfplan"
tflocal apply dev.tfplan
```

## Recursos que se crean (11)

| Módulo | Recursos |
|---|---|
| network | VPC, 2 subredes privadas en zonas distintas, tabla de rutas, 2 asociaciones, S3 Gateway Endpoint |
| identity | Rol de procesamiento y rol de auditoría, cada uno con su política |

## Seguridad

- Subredes sin Internet Gateway, NAT ni IP pública.
- Procesamiento: solo `s3:ListBucket`, `s3:GetObject` y `s3:PutObject` sobre `streaming/`.
- El `"*"` del endpoint (`Principal`) lo exige AWS; el de auditoría se debe a que `ec2:Describe*` no admite un recurso específico.

## Notas

- Otro entorno: copiar `environments/dev` y cambiar `terraform.tfvars` y `backend.tf`.
- LocalStack no persiste datos: tras reiniciarlo, repetir el paso 2 y usar `tflocal init -reconfigure`.
- Se usa `dynamodb_table` (obsoleto) porque la actividad pide locking con DynamoDB.