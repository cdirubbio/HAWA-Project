data "aws_instance" "instance" {
  instance_id = var.instance_id
}
data "aws_key_pair" "kp" {
  key_name           = "HAWA-PROJECT"
  include_public_key = true
}

resource "aws_ami_from_instance" "golden_ami" {
  name               = "${terraform.workspace}-golden-ami"
  source_instance_id = data.aws_instance.instance.id
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
  key_name      = data.aws_key_pair.kp.key_name
  instance_type = "t2.micro"

  vpc_security_group_ids = var.instance_security_groups_id

  user_data = base64encode(file(var.user_data_path))

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
  health_check_grace_period = 300
  target_group_arns         = [aws_lb_target_group.target_group.arn]


  launch_template {
    id = aws_launch_template.lt.id
  }
  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }
}

resource "aws_autoscaling_attachment" "application_asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  lb_target_group_arn    = aws_lb_target_group.target_group.arn
}
