variable "aws_region" {
  description = "The AWS region where resources will be created."
  default     = "us-east-1"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ALB."
  type        = list(string)
  default     = ["subnet-0075721660ac2696c", "subnet-0c80dd4290f3fb240", "subnet-0db88cbb66ffc699d"]
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created."
  type        = string
  default     = "vpc-0f9d633b23bcdc6a8"
}

variable "key_pair_name" {
  description = "The name of the key pair for EC2 instances."
  type        = string
  default     = "myaws123"
}

variable "instance_count" {
  description = "Number of EC2 instances to create."
  type        = number
  default     = 2
}

variable "ami_id" {
  description = "The ID of the AMI to use for EC2 instances."
  type        = string
  default     = "ami-03a6eaae9938c858c" # Ubuntu 22.04 LTS
}

variable "instance_type" {
  description = "The EC2 instance type for the instances."
  type        = string
  default     = "t3.micro"
}

variable "stickiness_duration" {
  description = "The duration of stickiness in seconds."
  type        = number
  default     = 86400 # 1 day
}

# Add a new variable for the internet gateway ID
variable "igw_id" {
  description = "The ID of the internet gateway."
  type        = string
  default     = "igw-06b83f0f947b6e04c"
}