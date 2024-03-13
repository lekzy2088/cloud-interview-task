# Create an ECS cluster
resource "aws_ecs_cluster" "flask_app_ecs_cluster" {
  name = "flask-app-ecs-cluster"
}

# Create a task definition for the ECS service
resource "aws_ecs_task_definition" "flask_app_task_definition" {
  family                   = "flask-app-task-family"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions    = <<DEFINITION
  [
    {
      "name": "my-container",
      "image": "${aws_ecr_repository.flask_ecr_repo.repository_url}", 
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000,
          "protocol": "tcp"
        }
      ]
    }
  ]
  DEFINITION
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

# Create an ECS service
resource "aws_ecs_service" "ecs_service" {
  name            = "flask-app-ecs-service"
  cluster         = aws_ecs_cluster.flask_app_ecs_cluster.id
  task_definition = aws_ecs_task_definition.flask_app_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.flask_app_vpc.public_subnets
    security_groups  = [aws_security_group.flask_app_ecs_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = module.flask_app_alb.target_group_arns[0]
    container_name   = "my-container"
    container_port   = 5000
  }
}
