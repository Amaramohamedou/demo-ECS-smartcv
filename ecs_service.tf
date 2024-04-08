resource "aws_ecs_service" "svc_practice" {
  name            = "service_practice"
  cluster         = aws_ecs_cluster.cluster-test.id
  task_definition = aws_ecs_task_definition.task-test.arn
  desired_count   = 3
  network_configuration {
    subnets         = [aws_subnet.subnet_smartcv_private_1.id, aws_subnet.subnet_smartcv_private_2.id,]
    security_groups = [aws_security_group.security_group.id] 
    assign_public_ip = false
  }
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }

    deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.smartcv_target_group.arn
    container_name   = "task-practice-1"
    container_port   = 80
  }
}