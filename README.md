# Final Project

Це репозиторій для навчального проєкту в межах курсу "DevOps CI/CD".

## Структура проєкту `final-project`

```bash
final-project/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальне виведення ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   │
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf       # Виведення інформації про VPC
│   │
│   ├── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf           # Створення ECR репозиторію
│   │   ├── variables.tf     # Змінні для ECR
│   │   └── outputs.tf       # Виведення URL репозиторію ECR
│   │
│   ├── jenkins/             # Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf       # Helm release для Jenkins
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   ├── providers.tf     # Оголошення провайдерів
│   │   ├── values.yaml      # Конфігурація jenkins
│   │   └── outputs.tf       # Виводи (URL, пароль 
│   │
│   └── eks/                 # Модуль для EKS
│   │   ├── eks.tf           # Створення EKS-кластера та воркерів
│   │   ├── variables.tf     # Змінні для EKS
│   │   ├── outputs.tf       # Виведення інформації про EKS
│   │   └── node.tf          # IAM-ролі для EKS
│   │ 
│   ├── rds/                 # Модуль для RDS
│   │   ├── rds.tf           # Створення RDS бази даних  
│   │   ├── aurora.tf        # Створення aurora кластера бази даних  
│   │   ├── shared.tf        # Спільні ресурси  
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   └── outputs.tf  

│   └── argo_cd/             # Модуль для Helm-установки Argo CD
│       ├── argo_cd.tf       # Helm release для Argo CD
│       ├── variables.tf     # Змінні (версія чарта, namespace, repo URL тощо)
│       ├── providers.tf     # Kubernetes+Helm.  переносимо з модуля jenkins
│       ├── values.yaml      # Кастомна конфігурація Argo CD
│       ├── outputs.tf       # Виводи (hostname, initial admin password)
│		    └──charts/                  # Helm-чарт для створення app'ів
│ 	 	    ├── Chart.yaml
│	  	    ├── values.yaml          # Список applications, repositories
│			    └── templates/
│		        ├── application.yaml # Шаблон Kubernetes manifest для Argo CD Application: описує Git репозиторій
│		        └── repository.yaml # Шаблон Kubernetes manifest для Argo CD Application: описує, які додатки (charts/папки) і як синхронізувати
│
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml # Kubernetes Deployment
│       │   ├── service.yaml # Kubernetes Service
│       │   ├── configmap.yaml # ConfigMap для середовища
│       │   └── hpa.yaml # Horizontal Pod Autoscaler
│       │ Chart.yaml # Основний файл чарта
│       └── values.yaml # Значення за замовчуванням для чарта
└──docker/
│   └── django/
│   │   ├── Dockerfile
│   │   └── Jenkinsfile
│   └── docker-compose.yaml
│
└── README.md                # Документація проєкту
```

## Команди ініціалізації запуску

1. terraform init – Ініціалізація запуску
2. terraform plan – Планування змін
3. terraform apply – Застосування змін
4. Після успішного застосування, збережіть kubeconfig (якщо він генерується в модулі EKS) і встановіть контекст:
```bash 
aws eks update-kubeconfig --name eks-cluster-demo --region us-west-2
```
5. terraform destroy – Знищення інфраструктури

## Опис модулів

### `s3-backend/` — Модуль для зберігання стану Terraform

Цей модуль відповідає за створення інфраструктури для віддаленого зберігання стану Terraform:

- S3-бакет для збереження файлу `terraform.tfstate`, який відображає поточний стан інфраструктури.
- DynamoDB-таблиця для блокування стану (state locking), що запобігає одночасному внесенню змін кількома користувачами.

Цей модуль забезпечує безпечну та узгоджену роботу з Terraform у командних середовищах.

### `vpc/` — Модуль для створення VPC (Virtual Private Cloud)

Модуль відповідає за побудову базової мережевої інфраструктури:

- Створення VPC з заданим CIDR-блоком.
- Створення підмереж (public/private).
- Додавання Internet Gateway.
- Налаштування маршрутів для зв'язку з інтернетом та між підмережами.

Це основа для безпечного та ізольованого розміщення ресурсів у хмарі AWS.

### `ecr/` — Модуль для створення репозиторію в Amazon ECR

Цей модуль створює приватний репозиторій у сервісі Amazon ECR:

- Дозволяє зберігати Docker-образи.
- Полегшує інтеграцію з ECS, Lambda, Fargate тощо.

Репозиторій є частиною безперервної інтеграції та доставки (CI/CD) для контейнеризованих застосунків.

### `eks/` — Модуль для створення EKS-кластера Kubernetes
Модуль відповідає за:

- Створення Amazon EKS-кластера.
- Налаштування воркерів (EC2 або Fargate).
- IAM-ролі для кластера та нодів.
- Виведення даних для підключення через kubectl.

Це ядро оркестрації контейнеризованих застосунків.

### `charts/django-app/` — Helm-чарт для Django-застосунку
У цьому Helm-чарті реалізовано:

- Deployment — деплой Docker-образу з ECR.
- Service — типу LoadBalancer для зовнішнього доступу.
- ConfigMap — із середовищними змінними.
- HPA — автоматичне масштабування при >70% CPU.
- values.yaml — параметри конфігурації чарту (образ, порти, autoscaling, тощо).

# Jenkins Service Account + RBAC

Перед запуском Jenkins застосовуються:

- `serviceaccount.yaml` — створює Jenkins SA
- `rbac.yaml` — дає повні права на ресурси в кластері

Ці файли розташовані в:  
`modules/jenkins/templates/`

Не потрібно застосовувати вручну — вони створюються Helm-чартом автоматично при `terraform apply`.

# Передумови

1. Наявність AWS облікового запису
2. Встановлений Terraform (>= 1.0.0)
3. AWS CLI з налаштованими обліковими даними
4. Bash (для запуску скриптів)

# Завантаження Docker-образу Django до ECR

Після створення репозиторію в ECR, виконайте наступні команди для завантаження Docker-образу:

```
# Змінні
AWS_REGION=<your-region>
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
REPO_NAME=<your-repo-name>
IMAGE_TAG=latest

# Login до ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Збірка та пуш Docker-образу
docker build -t $REPO_NAME .
docker tag $REPO_NAME:$IMAGE_TAG $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG
```

# Підключення до EKS-кластера
Після створення кластера за допомогою Terraform, виконайте:

```bash
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
kubectl get nodes
```

Це оновить kubeconfig і дозволить керувати кластером через kubectl.

# Деплой Django через Helm

Після оновлення values.yaml із правильним image.repository, виконайте:

```bash
cd charts/django-app

helm install django-app .      # або helm upgrade --install django-app .
kubectl get svc                # Перевірка IP-адреси
kubectl get hpa                # Перевірка автоскейлінгу
```

# GitHub Credentials для Jenkins (через JCasC)
Для підключення Jenkins до GitHub через Jenkins Configuration as Code, використовуються GitHub username та Personal Access Token (PAT), які підтягуються з Kubernetes secret у вигляді змінних середовища.

## Створити Kubernetes Secret
Перед розгортанням Jenkins створіть секрет github-credentials, що містить ваш GitHub username та token:

❗ Не додавайте `username/password` у values.yaml напряму.  
Використовуйте секрет `github-credentials`:

```bash
kubectl create secret generic github-credentials \
  --from-literal=username=<your-github-username> \
  --from-literal=token=<your-pat-token> \
  -n jenkins
```

## Деплой Jenkins через Terraform або Helm
Якщо Jenkins встановлюється через Terraform (з Helm), просто виконайте:
```bash
 terraform apply 
 ```

Або, якщо вручну через Helm:
```bash 
helm upgrade --install jenkins . -n jenkins -f values.yaml 
```

# Як перевірити Jenkins job

1. Зробіть порт-форвард:
```bash 
kubectl -n jenkins port-forward svc/jenkins 8080:8080
```

2. Відкрийте в браузері: http://localhost:8080
3. Отримайте пароль:
```bash 
kubectl -n jenkins get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
```
4. Запустіть pipeline та перегляньте логи.

# Як побачити результат в Argo CD

1. Порт-форвард:
```bash
kubectl -n argocd port-forward svc/argo-cd-server 8080:443
```
2. Відкрийте в браузері: http://localhost:8080
3. Логін: admin
   Пароль: 
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
   ```
4. Перевірте статус Application в UI.

# Terraform RDS Module

## Опис

Універсальний модуль для створення AWS RDS бази даних або Aurora кластера на основі параметра `use_aurora`. Модуль автоматично створює DB Subnet Group, Security Group та Parameter Group.

---

## Приклад використання

```hcl
module "rds" {
  source              = "./modules/rds"
  name                = "mydb"
  use_aurora          = true
  engine              = "aurora-postgresql"
  engine_version      = "15.3"
  engine_version_cluster = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  parameter_group_family_rds = "postgres15"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = "appdb"
  username            = "admin"
  password            = "supersecret"
  vpc_id              = "vpc-123456"
  subnet_private_ids  = ["subnet-aaa", "subnet-bbb"]
  subnet_public_ids   = ["subnet-ccc", "subnet-ddd"]
  publicly_accessible = false
  multi_az            = false
  backup_retention_period = "7"
  parameters          = {
    max_connections = "100"
    work_mem        = "4MB"
    log_statement   = "all"
  }
  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

## Змінні модуля RDS

| Назва                         | Тип             | Опис                                                         | Значення за замовчуванням      |
|-------------------------------|-----------------|--------------------------------------------------------------|-------------------------------|
| `name`                        | string          | Назва інстансу або кластера                                   | —                             |
| `use_aurora`                  | bool            | Використовувати Aurora Cluster (`true`) чи стандартний RDS (`false`) | `false`                       |
| `engine`                      | string          | Тип двигуна для стандартної RDS                              | `postgres`                    |
| `engine_version`              | string          | Версія двигуна для стандартної RDS                           | `14.7`                        |
| `engine_version_cluster`      | string          | Версія двигуна для Aurora кластера                           | `15.3`                        |
| `parameter_group_family_aurora` | string        | Родина параметрів для Aurora                                 | `aurora-postgresql15`         |
| `parameter_group_family_rds`  | string          | Родина параметрів для стандартної RDS                        | `postgres15`                  |
| `instance_class`              | string          | Клас інстансу (тип машини)                                   | `db.t3.micro`                 |
| `allocated_storage`           | number          | Розмір диску (для стандартної RDS)                           | `20`                         |
| `db_name`                    | string          | Назва бази даних                                              | —                             |
| `username`                   | string          | Ім’я користувача БД                                          | —                             |
| `password`                   | string (sensitive) | Пароль користувача БД                                       | —                             |
| `vpc_id`                    | string          | ID VPC                                                       | —                             |
| `subnet_private_ids`         | list(string)    | Список приватних subnet ID                                   | —                             |
| `subnet_public_ids`          | list(string)    | Список публічних subnet ID                                   | —                             |
| `publicly_accessible`         | bool            | Чи доступний інстанс з публічної мережі                      | `false`                      |
| `multi_az`                   | bool            | Використовувати multi-AZ (для RDS)                          | `false`                      |
| `parameters`                 | map(string)     | Ключ-значення параметрів для DB Parameter Group             | `{}`                         |
| `backup_retention_period`    | string          | Період зберігання бекапів (дні)                             | `""` (без бекапів)            |
| `tags`                      | map(string)     | Теги для ресурсів                                           | `{}`                         |
| `aurora_replica_count`       | number          | Кількість реплік Aurora кластера                             | `1`                          |
| `aurora_instance_count`      | number          | Загальна кількість інстансів Aurora (primary + replica)      | `2`                          |


## Як змінити тип БД, engine, клас інстансу тощо

- Щоб створити **Aurora кластер**, встановіть `use_aurora = true` та вкажіть `engine` і `engine_version_cluster` відповідно, наприклад `"aurora-postgresql"`.

- Для звичайного **RDS інстансу** встановіть `use_aurora = false` і задайте `engine` (наприклад, `"postgres"`) та `engine_version`.

- Щоб змінити тип інстансу, змініть значення `instance_class` (наприклад, `db.t3.small`).

- Параметри підмереж (`subnet_private_ids`, `subnet_public_ids`), доступність (`publicly_accessible`), multi-AZ та інші налаштування можна регулювати через відповідні змінні.
