#configuração do load balance

resource "aws_lb" "alb" {
  name            = "ECS-FASTEATS-API-PAGAMENTO"
  security_groups = [aws_security_group.alb.id]
  subnets         = module.vpc.public_subnets
}

#entrada do load balance
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.portaAplicacao
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alvo.arn
  }
}

resource "aws_lb_target_group" "alvo" {
  name        = "ECS-FASTEATS-API-PAGAMENTO"
  port        = var.portaAplicacao
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id
}

output "IP" {
  value = aws_lb.alb.dns_name
}
