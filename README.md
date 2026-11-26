# Pre-entrega 1: Infraestructura base (VPC, IAM y backend remoto)

Infraestructura como código con Terraform, desplegada en LocalStack. No requiere cuenta de AWS.

## Requisitos

- Docker Desktop con al menos 8 GB de RAM
- Terraform 1.5 o superior
- AWS CLI v2
- Python 3.10 o superior y `pip install terraform-local`
- Cuenta gratuita de LocalStack (plan Hobby)

Los comandos son para PowerShell.

## Estructura

```
environments/dev/    Llama a los módulos y configura el backend
modules/network/     VPC, subredes privadas, rutas y S3 Gateway Endpoint
modules/identity/    Roles y políticas IAM
docker-compose.yml   LocalStack, PostgreSQL y Flink
PLAN_OUTPUT.md       Evidencia del despliegue
```

## 1. Levantar el entorno

Guarda tu token (nunca lo subas al repositorio) y abre una terminal nueva:

```powershell
setx LOCALSTACK_AUTH_TOKEN "tu-token"
```

```powershell
docker compose up -d
curl.exe http://localhost:4566/_localstack/health
```

El puerto 4566 debe estar libre.

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

Resultado esperado: 11 recursos creados.

## Recursos que se crean

| Módulo | Recursos |
|---|---|
| network | 1 VPC, 2 subredes privadas (us-east-1a y us-east-1b), 1 tabla de rutas, 2 asociaciones, 1 S3 Gateway Endpoint |
| identity | Rol de procesamiento y su política, rol de auditoría y su política |

Outputs: `vpc_id`, `private_subnet_ids`, `private_route_table_id`, `s3_endpoint_id`, `processing_role_arn`, `audit_role_arn`.

## Verificar

```powershell
aws --endpoint-url=http://localhost:4566 ec2 describe-vpc-endpoints --filters "Name=vpc-endpoint-state,Values=available"
```

## Decisiones de seguridad

- Las subredes no tienen Internet Gateway, NAT ni IP pública.
- El rol de procesamiento solo permite `s3:ListBucket`, `s3:GetObject` y `s3:PutObject` sobre el prefijo `streaming/`.
- El S3 Endpoint solo permite esas acciones sobre el bucket de datos. Usa `Principal: "*"` porque AWS lo exige; el acceso lo limitan los roles IAM.
- El rol de auditoría es de solo lectura. Las acciones `ec2:Describe*` listadas usan `Resource: "*"` porque no admiten un recurso específico.
- El bucket del state tiene cifrado, versionado y bloqueo de acceso público.
- El bucket `pulso-lakehouse-dev` se referencia en las políticas, pero se creará en una próxima entrega.

## Reutilizar para otro entorno

Copiar `environments/dev` a `environments/prod` y cambiar los valores de `terraform.tfvars` y `backend.tf`. Los módulos no cambian.

## Limpieza

```powershell
cd environments\dev
tflocal destroy
cd ..\..
docker compose down
```

## Notas

- LocalStack Hobby no persiste datos: al reiniciarlo, repetir el paso 2 y usar `tflocal init -reconfigure`.
- `dynamodb_table` está marcado como obsoleto en Terraform; se usa porque la actividad pide locking con DynamoDB.
- `tflocal` muestra un aviso de obsolescencia; sigue funcionando.