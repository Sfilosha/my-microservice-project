# Lesson 8

Це репозиторій для навчального проєкту в межах курсу "DevOps CI/CD".

## Структура проєкту `lesson-8`

```bash
lesson-8/
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
│   └── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf           # Створення ECR репозиторію
│   │   ├── variables.tf     # Змінні для ECR
│   │   └── outputs.tf       # Виведення URL репозиторію ECR
│   │
│   └── jenkins/             # Модуль для Helm-установки Jenkins
│       ├── jenkins.tf       # Helm release для Jenkins
│       ├── variables.tf     # Змінні (ресурси, креденшели, values)
│       ├── providers.tf     # Оголошення провайдерів
│       ├── values.yaml      # Конфігурація jenkins
│       └── outputs.tf       # Виводи (URL, пароль 
│   │
│   └── eks/                 # Модуль для EKS
│       ├── eks.tf           # Створення EKS-кластера та воркерів
│       ├── variables.tf     # Змінні для EKS
│       ├── outputs.tf       # Виведення інформації про EKS
│       └── node.tf          # IAM-ролі для EKS
│
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml     # ConfigMap зі змінними середовища
│
└── README.md                # Документація проєкту
```

## Команди ініціалізації запуску

1. terraform init – Ініціалізація запуску
2. terraform plan – Планування змін
3. terraform apply – Застосування змін
4. terraform destroy – Знищення інфраструктури

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

```
aws eks update-kubeconfig --region <your-region> --name <cluster-name>
kubectl get nodes
```

Це оновить kubeconfig і дозволить керувати кластером через kubectl.

# Деплой Django через Helm

Після оновлення values.yaml із правильним image.repository, виконайте:

```
cd charts/django-app

helm install django-app .      # або helm upgrade --install django-app .
kubectl get svc                # Перевірка IP-адреси
kubectl get hpa                # Перевірка автоскейлінгу
```
