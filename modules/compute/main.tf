resource "aws_instance" "golden_image" {
  instance_type   = "t2.micro"
  ami = "ami-06c68f701d8090592"
  user_data       = file(var.user_data_path)
  key_name        = aws_key_pair.key_pair.key_name
  security_groups = var.instance_security_groups
  subnet_id       = var.priv_subnet_ids[0]

  tags = {
    Name = "Initial Instance"
  }
}


resource "aws_key_pair" "key_pair" {
  key_name   = terraform.workspace
  public_key = file("HAWA-key.pub")
}

resource "aws_ami_from_instance" "golden_ami" {
  name               = "${terraform.workspace}-golden-ami"
  source_instance_id = aws_instance.golden_image.id
}

resource "aws_lb" "alb" {
  name               = "${terraform.workspace}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.lb_security_groups
  subnets            = var.pub_subnet_ids

}

resource "aws_lb_target_group" "target_group" {
  name     = "${terraform.workspace}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "http_lb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_launch_template" "lt" {
  name          = "${terraform.workspace}-launch-template"
  image_id      = aws_ami_from_instance.golden_ami.id
  key_name      = aws_key_pair.key_pair.key_name
  instance_type = "t2.micro"

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${terraform.workspace}-server-from-LT"
    }
  }

}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = var.priv_subnet_ids

  desired_capacity          = var.priv_subnet_count * 2
  min_size                  = 3
  max_size                  = var.priv_subnet_count * 3
  health_check_type         = "ELB"
  health_check_grace_period = 250
  target_group_arns         = [aws_lb_target_group.target_group.arn]

  launch_template {
    id = aws_launch_template.lt.id
  }
    lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

resource "aws_autoscaling_attachment" "application_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.target_group.arn
}
