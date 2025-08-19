provider "aws" {
  region = var.aws_region
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "nginx" {
  name = "/ecs/lesson8"
  retention_in_days = 7
}

# ECR Repository
resource "aws_ecr_repository" "mynginx" {
  name                 = "mynginx"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Owner = "petrch"
  }
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_role" {
  name = "ecs_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Owner = "petrch"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_role_policy" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ecs_policy" {
  name        = "ecs_policy"
  description = "Policy for ECS tasks to access ECR and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["logs:Describe*", "logs:Get*",
                    "logs:List*",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"]
        Resource = "arn:aws:logs:eu-central-1:739133790707:log-group:/ecs/lesson8:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_policy_attachment" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs_policy.arn
}

# Use existing VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Groups
resource "aws_security_group" "ecs_sg" {
  name        = "nginx-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-ecs-sg"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "nginx-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-alb-sg"
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "nginx-cluster"
}

# Task Definition
resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = 256
  memory                  = 512
  execution_role_arn      = aws_iam_role.ecs_role.arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "${aws_ecr_repository.mynginx.repository_url}:latest"
      essential = true,
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group" = "/ecs/lesson8",
          "awslogs-region" = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      },
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# ALB Target Group
resource "aws_lb_target_group" "nginx" {
  name        = "nginx-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}

# Application Load Balancer
resource "aws_lb" "nginx" {
  name               = "nginx-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nginx.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

# ECS Service
resource "aws_ecs_service" "nginx" {
  name            = "nginx-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.public.ids
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.arn
    container_name   = "nginx"
    container_port   = 80
  }
}
