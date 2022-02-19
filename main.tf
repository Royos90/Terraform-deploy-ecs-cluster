terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# configure the aws provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "my_first_ecr_repo" {
  name = "matts-first-ecr-repo" # Naming my repository
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "matts-cluster" # Naming the cluster
}

resource "aws_ecs_task_definition" "my_first_task" {
  family                   = "my-first-task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "my-first-task",
      "image": "${aws_ecr_repository.my_first_ecr_repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000, 
          "hostPort": 3000
        }
     ],
     "memory": 512, 
     "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # stating that we are using ECS Fargate
  network_mode             = "awsvpc" # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}"
}


resource "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "1",
            "Effect": "Allow",
            "Principal": {
              "Service": "ecs-tasks.amazonaws.com"
              },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_ecs_service" "my_first_service" {
  name            = "my-first-service" #Naming our first service
  cluster         = "${aws_ecs_cluster.my_cluster.id}" # Referencing our created Cluster
  task_definition = "${aws_ecs_task_definition.my_first_task.arn}" # Referencing the task our service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # setting the number of containers we want deployed to 3

 network_configuration {
    subnets         = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}", "${aws_default_subnet.default_subnet_c.id}"]
    assign_public_ip = true # Providing our containers with public IPs
  }

}

# Reference to our default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Reference to our default subnets 
resource "aws_default_subnet" "default_subnet_a" {
 availability_zone = "us-east-1a"
} 

resource "aws_default_subnet" "default_subnet_b" {
 availability_zone = "us-east-1b" 
}

resource "aws_default_subnet" "default_subnet_c" {
 availability_zone = "us-east-1c"
}
