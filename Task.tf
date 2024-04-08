resource "aws_ecs_task_definition" "task-test" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = "task-practice-1"
      image     = "nginx:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu       = 256
  memory    = 512
}
