resource "aws_security_group" "alb" {
  name   = "alb_ECS"
  vpc_id = module.vpc.vpc_id
}

#CONFIGURAÇÃO DA REDE PUBLICA PARA O ECS

resource "aws_security_group_rule" "tcp_alb" {
  type              = "ingress"
  from_port         = var.portaAplicacao
  to_port           = var.portaAplicacao
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "saida_alb" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

#CONFIGURAÇÃO DA REDE PRIVADA PARA O ECS

resource "aws_security_group" "privado" {
  name   = "privado_ECS"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "entrada_ECS" {
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  #cidr_blocks       = ["0.0.0.0/0"]
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.privado.id
}

resource "aws_security_group_rule" "saida_ECS" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.privado.id
}

#CONFIGURAÇÃO DO BANCO DE DADOS MYSQL

resource "aws_security_group" "rds_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.privado.id]
  }
}
