variable "micro_servico" {
  description = "Nome do microserviço"
  type    = string
  default = "pagamento"
}

##### variaveis de ambiente repositorio de imagens docker#######
variable "nome_repositorio" {
  description = "Nome do repositório de imagens Docker"
  type    = string
  default = "microservico-pagamento"
}

variable "repositorio_url" {
  description = "URL do repositório de imagens Docker do microserviço"
  type = string
  default = "730335661438.dkr.ecr.us-east-1.amazonaws.com/microservico-pagamento"
}

variable "imagemDocker" {
  type    = string
  default = "730335661438.dkr.ecr.us-east-1.amazonaws.com/microserviceo-pagamento:latest"
}

##### fim variaveis de ambiente repositorio de imagens docker#######

variable "regiao" {
  type    = string
  default = "us-east-1"
}


variable "portaAplicacao" {
  type    = number
  default = 8080
}

variable "containerDbPort" {
  description = "Porta do banco de dados do microserviço"
  type    = string
  default = "3306"
}

variable "containerDbServer" {
  description = "Endereço do banco de dados do microserviço"
  type    = string
}

variable "containerDbName" {
  description = "Nome do banco de dados do microserviço"
  type    = string
}

variable "containerDbUser" {
  description = "Usuário do banco de dados do microserviço"
  type    = string
}

variable "containerDbPassword" {
  description = "Senha do banco de dados do microserviço"
  type    = string
}

variable "containerDbRootPassword" {
  description = "Senha do user root do banco de dados do microserviço"
  type    = string
}

variable "url_pedido_service" {
  type    = string
  default = "http://ecs-fasteats-api-pagamento-399390289.us-west-2.elb.amazonaws.com"
}

variable "url_cozinha_service" {
  type    = string
  default = "http://54.163.63.60"
}

######### MERCADO PAGO #########
variable "containerMercadoPagoEmailEmpresa" {
  type    = string
  default = "pagamento@lanchonete-fiap.com.br"
}

variable "containerMercadoPagoCredential" {
  type    = string
  default = "TEST-2087963774082813-080820-ee2b9b80edbdecf3ea8453bb8c088bc7-64946408"
}
variable "containerMercadoPagoUderId" {
  type    = string
  default = "64946408"
}

variable "containerMercadoPagoTipoPagamento" {
  type    = string
  default = "pix"
}
######### FIM MERCADO PAGO #########

######### OBS: a execution role acima foi trocada por LabRole devido a restricoes de permissao na conta da AWS Academy ########
variable "execution_role_ecs" {
  type    = string
  default = "arn:aws:iam::730335661438:role/LabRole" #aws_iam_role.ecsTaskExecutionRole.arn
}


########## variaveis de ambiente CPU/MEM para cluster ECS ##########
variable "cpu_task" {
  type    = number
  default = 256
}

variable "memory_task" {
  type    = number
  default = 512
}

variable "cpu_container" {
  type    = number
  default = 256
}

variable "memory_container" {
  type    = number
  default = 512
}
########## fim variaveis de ambiente para o cluster ECS ##########


variable "container_insights" {
  type        = bool
  default     = false
  description = "Set to true to enable container insights on the cluster"
}
