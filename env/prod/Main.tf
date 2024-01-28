
# Criando um modulo que utiliza os dados do infra para criação do ambiente
module "prod" {
  source                  = "../../infra"
  containerDbName         = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["dbname"]
  containerDbUser         = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["username"]
  containerDbPassword     = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["password"]
  containerDbRootPassword = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["password"]
  containerDbServer       = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["host"]
  containerDbPort         = jsondecode(data.aws_secretsmanager_secret_version.mysql_credentials.secret_string)["port"]  
}


#obteando dados do secret manager
data "aws_secretsmanager_secret" "mysql" {
  name = "prod/soat1grupo56/MySQLPagamento"
}

data "aws_secretsmanager_secret_version" "mysql_credentials" {
  secret_id = data.aws_secretsmanager_secret.mysql.id
}

output "IP_alb" {
  value = module.prod.IP
}
