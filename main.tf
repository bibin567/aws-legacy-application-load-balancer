provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "webserver" {
  count         = var.instance_count
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "webserver-${count.index + 1}"
  }

  key_name = var.key_pair_name  # Use the key pair name here

  user_data = <<-EOF
           #!/bin/bash
           sudo yum update -y
           sudo yum install httpd -y
           sudo systemctl start httpd
           sudo systemctl enable httpd
           sudo touch /var/www/html/index.html
           sudo chown ec2-user:ec2-user /var/www/html/index.html
           sudo chmod 644 /var/www/html/index.html
           echo "Hostname: $(hostname)" > /var/www/html/index.html
           EOF

  security_groups = [aws_security_group.ec2_sg.name]
}

resource "aws_security_group" "ec2_sg" {
  name = "my-sg"
  vpc_id = var.vpc_id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "legacy_alb" {
  name               = "LegacyALB"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "target_group" {
  name        = "TargetGroup"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_target_group_attachment" "attachment" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.webserver[count.index].id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.legacy_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "stickiness_rule" {
  listener_arn = aws_lb_listener.listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  priority = 1
}