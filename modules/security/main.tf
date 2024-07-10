resource "aws_security_group" "lb_sg" {
  name        = "${terraform.workspace}-ALB-SG"
  description = "Allow internet traffic from internet"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "${terraform.workspace}-Instance-SG"
  description = "Allow ALB Traffic into instances"
  // Allow HTTP traffic from LB Security Group
  ingress {
    from_port       = 80
    protocol        = "tcp"
    to_port         = 80
    security_groups = [aws_security_group.lb_sg.id]
  }
  // Allow HTTPs traffic from LB Security Group
  ingress {
    from_port       = 443
    protocol        = "tcp"
    to_port         = 443
    security_groups = [aws_security_group.lb_sg.id]
  }
}

resource "aws_vpc_security_group_egress_rule" "egress_instance" {
  security_group_id = aws_security_group.instance_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
resource "aws_vpc_security_group_egress_rule" "egress_lb" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}