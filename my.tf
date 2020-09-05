provider "aws" {
 region = "ap-south-1"
 profile = "DevProfile"
}

resource "aws_security_group" "mysg" {
  vpc_id      = "vpc-8c7761e4"
      ingress {
    description = "Creating SSH security group"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "Creating HTTP security group"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "Creating EFS enable security group"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
 Name = "mysg"
    }
}

resource "aws_db_instance" "MySQL_Database" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.30"
  identifier           = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "MySQL_Database"
  username             = "Dev"
  password             = "Dev898989"
  parameter_group_name = "default.mysql5.7"
 // deletion_protection =  true
  auto_minor_version_upgrade = true
  publicly_accessible = true
  port = "3306"
   vpc_security_group_ids = ["${aws_security_group.mysg.id}"]
  final_snapshot_identifier = false
  skip_final_snapshot = true
 
}


resource "kubernetes_deployment" "Wordpress" {
  metadata {
    name = "wordpress"
    labels = {
      app = "webapp"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "webapp"
      }
    }

    template {
      metadata {
        labels = {
          app = "webapp"
        }
      }

      spec {
        container {
          image = "wordpress"
          name  = "wordpress-container"
            port {
               container_port = 80
                     }
                }
           }
      }
  } 
}


resource "kubernetes_service" "service" {
  metadata {
    name = "wp-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.Wordpress.metadata.0.labels.app
    }
    port {
      node_port = 30000
      port        = 8080
      target_port = 80
    }
    type = "NodePort"
  }
}



 