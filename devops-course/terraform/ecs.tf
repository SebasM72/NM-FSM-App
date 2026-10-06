# ecs.tf
# ECR repository created by staging only, shared across workspaces
# Production references the same repo via data source below
resource "aws_ecr_repository" "flask_app" {
  count                = terraform.workspace == "staging" ? 1 : 0
  name                 = "nm-fsm-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  tags                 = { Name = "nm-fsm-app" }
}

# ECR data source used by production to reference the shared repo
data "aws_ecr_repository" "flask_app" {
  count = terraform.workspace == "production" ? 1 : 0
  name  = "nm-fsm-app"
}

# Local to unify ECR URL regardless of workspace
locals {
  ecr_repository_url = (terraform.workspace == "staging" ?
    aws_ecr_repository.flask_app[0].repository_url :
    data.aws_ecr_repository.flask_app[0].repository_url
  )
}

# ECS cluster shared, one per account
resource "aws_ecs_cluster" "main" {
  name = "cis4641-cluster"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# ECS Fargate service workspace-specific
resource "aws_ecs_service" "app" {
  name            = "flask-${terraform.workspace}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [data.aws_subnet.public.id]
    security_groups  = [aws_security_group.fargate.id]
    assign_public_ip = true
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# ECS task definition workspace-specific
resource "aws_ecs_task_definition" "app" {
  family                   = "flask-${terraform.workspace}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = data.aws_iam_role.lab.arn
  container_definitions = jsonencode([{
    name         = "flask-app"
    image        = "${local.ecr_repository_url}:${var.flask_image_tag}"
    portMappings = [{ containerPort = 5000, protocol = "tcp" }]
    environment = [
      {
        name  = "DATABASE_URL"
        value = "mysql+pymysql://${var.db_user}:${var.db_password}@${var.db_ip[terraform.workspace]}/${var.db_name}"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/flask-${terraform.workspace}"
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
  }])
}

# CloudWatch log group workspace-specific
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/flask-${terraform.workspace}"
  retention_in_days = 7
}

# In production: staging and production usually live in separate AWS accounts, which forces separate ECR registries.
# Promotion then copies the image by digest between registries — never a rebuild. This course uses one account and one
# repository, so promotion is simply pointing production at the digest staging validated
# + Cost control: auto-scale Fargate to zero when
# MySQL stops (EventBridge + Lambda) -> NEXT SLIDE
