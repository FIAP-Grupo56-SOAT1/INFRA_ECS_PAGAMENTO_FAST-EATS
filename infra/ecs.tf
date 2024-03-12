########## Creating an ECS Cluster ########
resource "aws_ecs_cluster" "ecs_fasteats" {
  name               = "cluster-${var.micro_servico}"
  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  tags = {
    Name = "cluster-${var.micro_servico}"
  }
}

data "aws_ecr_repository" "repositorio" {
  name = var.nome_repositorio
}

resource "random_string" "lower" {
  length  = 16
  upper   = false
  lower   = true
  special = false
}

######### Configuring AWS ECS Task Definitions ########
resource "aws_ecs_task_definition" "fasteats" {
  family = "task-${var.micro_servico}" # Name your task
  container_definitions = jsonencode(
    [
      {
        name   = "task-${var.micro_servico}"
        image  = data.aws_ecr_repository.repositorio.repository_url
        cpu    = var.cpu_task
        memory = var.memory_task
        environment = [
          { "NAME" : "APP_PORT", "value" : tostring(var.portaAplicacao) },
          { "NAME" : "DB_PORT", "value" : var.containerDbPort },
          { "NAME" : "DB_USERNAME", "value" : var.containerDbUser },
          { "NAME" : "DB_PASSWORD", "value" : var.containerDbPassword },
          { "NAME" : "DB_NAME", "value" : var.containerDbName },
          { "NAME" : "DB_SERVER", "value" : var.containerDbServer },
          { "NAME" : "URL_PEDIDO_SERVICE", "value" : var.url_pedido_service },
          { "NAME" : "URL_COZINHA_PEDIDO_SERVICE", "value" : var.url_cozinha_service },
          {
            "NAME" : "MERCADO_PAGO_EMAIL_EMPRESA",
            "value" : var.containerMercadoPagoEmailEmpresa
          },
          {
            "NAME" : "MERCADO_PAGO_CREDENCIAL",
            "value" : var.containerMercadoPagoCredential
          },
          { "NAME" : "MERCADO_PAGO_USERID", "value" : var.containerMercadoPagoUderId },
          { "NAME" : "MERCADO_PAGO_TIPO_PAGAMENTO", "value" : var.containerMercadoPagoTipoPagamento },
          { "NAME" : "AWS_SQS_ENDPOINT", "value" : "https://sqs.us-east-1.amazonaws.com/730335661438" },
          { "NAME" : "AWS_SQS_QUEUE_PEDIDO_CRIADO", "value" : "pedido-criado" },
          { "NAME" : "AWS_SQS_QUEUE_PEDIDO_AGUARDANDO_PAGAMENTO", "value" : "pedido-aguardando-pagamento" },
          { "NAME" : "AWS_SQS_QUEUE_PEDIDO_PAGO", "value" : "pedido-pago" },
          { "NAME" : "AWS_SQS_QUEUE_PEDIDO_CANCELADO", "value" : "pedido-cancelado" },
          { "NAME" : "AWS_SQS_QUEUE_COZINHA_RECEBER_PEDIDO", "value" : "cozinha-receber-pedido" },
          { "NAME" : "AWS_SQS_QUEUE_COZINHA_ERRO_RECEBER_PEDIDO", "value" : "cozinha-erro-receber-pedido" },
          { "NAME" : "AWS_SQS_QUEUE_PAGAMENTO_GERAR_PAGAMENTO", "value" : "pagamento-gerar-pagamento" },
          { "NAME" : "AWS_SQS_QUEUE_PAGAMENTO_RECEBER_PEDIDO_PAGO", "value" : "pagamento-receber-pedido-pago" },
          { "NAME" : "AWS_SQS_QUEUE_NOTIFICAR_CLIENTE", "value" : "notificar-cliente" },
          { "NAME" : "AWS_SQS_QUEUE_NOTIFICAR_CLIENTE_PEDIDO_PAGO", "value" : "notificar-cliente-pedido-pago" },
          { "NAME" : "AWS_SQS_QUEUE_PAGAMENTO_CANCELAR_PAGAMENTO", "value" : "pagamento-cancelar-pagamento" },
          { "NAME" : "AWS_SQS_QUEUE_PAGAMENTO_ERRO_PAGAMENTO_PEDIDO", "value" : "pagamento-erro-pagamento-pedido" },
          { "NAME" : "AWS_SQS_QUEUE_PAGAMENTO_ERRO_PEDIDO_CANCELAR", "value" : "pagamento-erro-pedido-cancelar" },
          { "NAME" : "FAST_EATS_CONTATO_EMAIL_PADRAO_PAGAMENTO_PEDIDO", "value" : var.fast_eats_contato_email_padrao_pagamento_pedido },
          { "NAME" : "AWS_ACCESS_KEY", "value" : var.access_key },
          { "NAME" : "AWS_SECRET_KEY", "value" : var.secret_key },
          { "NAME" : "AWS_SESSION_TOKEN", "value" : var.session_token },
          { "NAME" : "AWS_REGION", "value" : var.regiao }
        ]
        essential = true
        portMappings = [
          {
            "containerPort" = var.portaAplicacao
            "hostPort"      = var.portaAplicacao
          }
        ],
        logConfiguration : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-group" : aws_cloudwatch_log_group.fasteats.name,
            "awslogs-region" : var.regiao,
            "awslogs-stream-prefix" : "ecs-fast-eats-api-${var.micro_servico}"
          }
        }
      }
    ])
  requires_compatibilities = ["FARGATE"]                              # use Fargate as the launch type
  network_mode             = "awsvpc"                                 # add the AWS VPN network mode as this is required for Fargate
  memory                   = var.memory_container                     # Specify the memory the container requires
  cpu                      = var.cpu_container                        # Specify the CPU the container requires
  execution_role_arn       = var.execution_role_ecs                   #aws_iam_role.ecsTaskExecutionRole.arn

  tags = {
    Name = "microservico-${var.micro_servico}"
    type = "terraform"
  }
}


##### Creating a VPC #####
# Provide a reference to your default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Provide references to your default subnets
resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1b
  availability_zone = "us-east-1b"
}

#resource "aws_default_subnet" "default_subnet_c" {
#  # Use your own region here but reference to subnet 1b
#  availability_zone = "us-east-1c"
#}


##### Implement a Load Balancer #####
resource "aws_alb" "application_load_balancer_fasteats" {
  name               = "load-balancer-${var.micro_servico}" #load balancer name
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id,
    #aws_default_subnet.default_subnet_c.id
  ]
  # security group
  security_groups = [aws_security_group.load_balancer_security_group_fasteats.id]
}

##### Creating a Security Group for the Load Balancer #####
# Create a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group_fasteats" {
  vpc_id      = aws_default_vpc.default_vpc.id
  name = "load-balancer-security-group-${var.micro_servico}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "target_group_fasteats" {
  name        = "target-group-${var.micro_servico}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # default VPC
  health_check {
    path                = "/actuator/health"
    port                = var.portaAplicacao
    healthy_threshold   = 5 # O número de verificações de integridade bem-sucedidas consecutivas necessárias antes de considerar um destino não íntegro como íntegro.
    unhealthy_threshold = 3 # O número de verificações de integridade consecutivas com falha exigido antes considerar um destino como não íntegro.
    timeout             = 5 # O tempo, em segundos, durante o qual a ausência de resposta significa uma falha na verificação de integridade.
    interval            = 60
    matcher             = "200" # has to be HTTP 200 or fails
  }
}

resource "aws_lb_listener" "listener_fasteats" {

  load_balancer_arn = aws_alb.application_load_balancer_fasteats.arn #  load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_fasteats.arn # target group
  }
}

##### ECS Service #####


resource "aws_ecs_service" "app_service_fasteats" {
  name            = "service-${var.micro_servico}"                        # Name the service
  cluster         = aws_ecs_cluster.ecs_fasteats.id      # Reference the created Cluster
  task_definition = aws_ecs_task_definition.fasteats.arn # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 1 # Set up the number of containers to 3
  force_new_deployment = true
  triggers = {
    redeployment = random_string.lower.result
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.target_group_fasteats.arn # Reference the target group
    container_name   = aws_ecs_task_definition.fasteats.family
    container_port   = var.portaAplicacao # Specify the container port
  }

  network_configuration {
    subnets = [
      aws_default_subnet.default_subnet_a.id,
      aws_default_subnet.default_subnet_b.id,
      #aws_default_subnet.default_subnet_c.id
    ]
    assign_public_ip = true                                                  # Provide the containers with public IPs
    security_groups  = [
      aws_security_group.service_security_group_fasteats.id,
      aws_security_group.service_ecs_security_group_db_fasteats.id
    ] # Set up the security group
  }
}


resource "aws_security_group" "service_security_group_fasteats" {
  name = "service-security-group-${var.micro_servico}"
  vpc_id = aws_default_vpc.default_vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.load_balancer_security_group_fasteats.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#CONFIGURAÇÃO DO BANCO DE DADOS
resource "aws_security_group" "service_ecs_security_group_db_fasteats" {
  vpc_id = aws_default_vpc.default_vpc.id
  name = "security-group-db-${var.micro_servico}"
  ingress {
    protocol        = "tcp"
    from_port       = var.containerDbPort
    to_port         = var.containerDbPort
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.load_balancer_security_group_fasteats.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.service_security_group_fasteats.id]
  }
}

resource "aws_cloudwatch_log_group" "fasteats" {
  name              = "fasteats-api-${var.micro_servico}"
  retention_in_days = 1
  tags = {
    Application = "micro-servico-${var.micro_servico}"
  }
}

#Log the load balancer app URL
output "app_url" {
  value = aws_alb.application_load_balancer_fasteats.dns_name
}
