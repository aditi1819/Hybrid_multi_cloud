provider "kubernetes" {
 config_context_cluster = "minikube"
}

provider "aws" {
  region     = "ap-south-1"
  profile    = "riya"
}
//Database instance
resource "aws_db_instance" "mysqldb" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  storage_type         = "gp2"
  name                 = "mydb"
  username             = "aditi"
  password             = "longpassword"
  port                 = "3306"
  publicly_accessible  = true
  skip_final_snapshot  = true
  parameter_group_name = "default.mysql5.7"
tags = {
    Name = "Wp-database"
  }
}

resource "kubernetes_deployment" "example" {
 metadata {
 name = "wordpressdeployment"
 labels = {
 test = "MyExampleApp"
 }
 }
spec {
 replicas = 3
selector {
 match_labels = {
 test = "MyExampleApp"
 }
 }
template {
 metadata {
 labels = {
 test = "MyExampleApp"
 }
 }
spec {
 container {
 image = "wordpress:4.8-apache"
 name = "wordpresscontainer"
}
 }
 }
 }
}

resource "kubernetes_service" "wp-expose" {
 metadata {
 name = "terraform-wp-service"
 }
 spec {
 selector = {
 test = "MyExampleApp"
 }
 
 port {
 node_port = 32765
 port = 80
 target_port = 80
 }
type = "NodePort"
 }
}

output "RDS-Instance"{
   value= aws_db_instance.mysqldb.address
}