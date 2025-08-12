# Nginx na AWS ECS pomocí Terraform

Tento projekt obsahuje Terraform konfiguraci pro nasazení Nginx kontejneru na AWS ECS (Elastic Container Service) s použitím Fargate launch type.

## Prerekvizity

- AWS účet
- Nainstalovaný Terraform
- Nastavené AWS credentials
- GitHub účet (pro CI/CD pipeline)

## Struktura projektu

```
hw07/
├── terraform/
│   ├── main.tf          # Hlavní Terraform konfigurace
│   ├── variables.tf     # Definice proměnných
│   ├── outputs.tf       # Output hodnoty
│   └── backend.tf       # Konfigurace S3 backendu
└── .github/
    └── workflows/
        └── deploy.yml   # GitHub Actions workflow
```

## Komponenty infrastruktury

- VPC s public/private subnety (využívá existující VPC)
- ECS Cluster (Fargate)
- ECS Service s 1 běžící task
- Task Definition pro nginx:alpine
- Security Groups
- Application Load Balancer s target group a listener

## Deployment

### Manuální deployment

1. Nastavte AWS credentials:
```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
```

2. Inicializujte Terraform:
```bash
cd terraform
terraform init
```

3. Vytvořte plán:
```bash
terraform plan
```

4. Aplikujte změny:
```bash
terraform apply
```

### Automatický deployment

Projekt obsahuje GitHub Actions workflow, který automaticky deployuje infrastrukturu při push do main větve.

Pro nastavení automatického deploymentu:

1. Vytvořte S3 bucket pro Terraform state
2. Nastavte GitHub Secrets:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY

## Výstupy

Po úspěšném nasazení získáte DNS jméno Application Load Balanceru, přes které je Nginx dostupný.

## Požadavky

- Task Definition: 256 CPU units, 512 MB paměti
- Health check endpoint: /
- Nginx dostupný z internetu přes load balancer
