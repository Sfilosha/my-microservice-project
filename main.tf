provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type = "t2.micro"

  tags = {
    Name = "lesson5"
  }
}

# Підключаємо модуль для S3 та DynamoDB
resource "random_id" "suffix" {
  byte_length = 4
}

module "s3_backend" {
  source      = "./modules/s3-backend"           # Шлях до модуля
  bucket_name = "terraform-state-bucket-${random_id.suffix.hex}"  # Ім'я S3-бакета
  table_name  = "terraform-locks"                # Ім'я DynamoDB
}

# Підключаємо модуль для VPC
module "vpc" {
  source              = "./modules/vpc"           # Шлях до модуля VPC
  vpc_cidr_block      = "10.0.0.0/16"             # CIDR блок для VPC
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]        # Публічні підмережі
  private_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]         # Приватні підмережі
  availability_zones  = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
            # Зони доступності
  vpc_name            = "vpc"              # Ім'я VPC
}

module "ecr" {
  source          = "./modules/ecr"   # Шлях до модуля
  repository_name = "lesson-5"        # Назва репозиторію
}

module "eks" {
  source          = "./modules/eks"          
  cluster_name    = "funny-dubstep-party"   # Назва кластера
  subnet_ids      = module.vpc.public_subnets     # ID підмереж
  instance_type   = "t2.micro"                    # Тип інстансів
  desired_size    = 1                             # Бажана кількість нодів
  max_size        = 2                             # Максимальна кількість нодів
  min_size        = 1                             # Мінімальна кількість нодів
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.5.0"
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.eks_cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.eks_cluster_name
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "jenkins" {
  source             = "./modules/jenkins"
  cluster_name       = module.eks.eks_cluster_name
  oidc_provider_arn  = module.eks.oidc_provider_arn
  oidc_provider_url  = module.eks.oidc_provider_url

  providers = {
    helm = helm
  }
}

module "argo_cd" {
  source       = "./modules/argo-cd"
  namespace    = "argocd"
  chart_version = "5.46.4"
}

module "rds" {
  source = "./modules/rds"

  name                       = "myapp-db"
  use_aurora                 = true
  aurora_instance_count      = 2

  # --- Aurora-only ---
  engine_cluster             = "aurora-postgresql"
  engine_version_cluster     = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"
  

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class             = "db.t3.medium"
  allocated_storage          = 20
  db_name                    = "myapp"
  username                   = "postgres"
  password                   = "admin123AWS23"
  subnet_private_ids         = module.vpc.private_subnets
  subnet_public_ids          = module.vpc.public_subnets
  publicly_accessible        = true
  vpc_id                     = module.vpc.vpc_id
  multi_az                   = true
  backup_retention_period    = 7
  parameters = {
    max_connections              = "200"
    log_min_duration_statement   = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}





