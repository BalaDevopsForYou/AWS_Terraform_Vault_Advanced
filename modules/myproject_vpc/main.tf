resource "aws_vpc" "myvpc" {
  cidr_block = var.myvpc_cidr
  tags = {
    name = var.projectname
  }
}

resource "aws_subnet" "mysubnet1" {

  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.mysubnet1_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  
}

resource "aws_subnet" "mysubnet2" {

  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.mysubnet2_cidr
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

}

resource "aws_route_table" "myrtb" {
  vpc_id = aws_vpc.myvpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myigw.id
    }
}

resource "aws_route_table_association" "myrtb-assctn1" {
    subnet_id = aws_subnet.mysubnet1.id
    route_table_id = aws_route_table.myrtb.id
}

resource "aws_route_table_association" "myrtb-assctn2" {
    subnet_id = aws_subnet.mysubnet2.id
    route_table_id = aws_route_table.myrtb.id
}

resource "aws_security_group" "mysg" {
  name_prefix = "my-web.sg"
  description = "allow tls inbound traffic"
  vpc_id = aws_vpc.myvpc.id

  ingress {

    description = "http traffic"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  ingress {
    description = "ssh traffic"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]    
  }

  tags = {
    "name" = "security-grp"
  }
}

resource "aws_instance" "myfirstinstance" {
  ami                    = "ami-0261755bbcb8c4a84"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.mysubnet1.id
  user_data              = base64encode(file("../modules/myproject_vpc/myuserdata_script1.sh"))
}
resource "aws_instance" "mysecondinstance" {
  ami                    = "ami-0261755bbcb8c4a84"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.mysubnet2.id
  user_data              = base64encode(file("../modules/myproject_vpc/myuserdata_script2.sh"))
}

#create application load balancer
resource "aws_lb" "my_lb" {
  name = "my-app-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.mysg.id]
  subnets = [aws_subnet.mysubnet1.id, aws_subnet.mysubnet2.id]
}

resource "aws_alb_target_group" "my-trgt-grp" {
  
  name = "my-tg-gp"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "myatch1" {
  target_group_arn = aws_alb_target_group.my-trgt-grp.arn
  target_id        = aws_instance.myfirstinstance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "myatch2" {
  target_group_arn = aws_alb_target_group.my-trgt-grp.arn
  target_id        = aws_instance.mysecondinstance.id
  port             = 80
}


resource "aws_lb_listener" "lstner" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.my-trgt-grp.arn
    type             = "forward"
  }
}

output "loadbalancerdns" {
  value = aws_lb.my_lb.dns_name
}