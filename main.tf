############
#   VPC   #
############
resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

############
# SUBNETS #
############
resource "aws_subnet" "sub1" { # Subnet 1 (us-east-1a)
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" { # Subnet 2 (us-east-1b)
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

#########################
# INTERNET GATEWAY (IGW) #
#########################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

################
# ROUTE TABLE  #
################
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#################################
# ROUTE TABLE ASSOCIATIONS (RTA) #
#################################
resource "aws_route_table_association" "rta1" { # Subnet 1 -> RT
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
}

resource "aws_route_table_association" "rta2" { # Subnet 2 -> RT
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.RT.id
}

####################
# SECURITY GROUP   #
####################
resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP from Anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from Anywhere"
    from_port   = 22
    to_port     = 22
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
    Name = "Web-sg"
  }
}

#############
# S3 BUCKET #
#############
resource "aws_s3_bucket" "example" {
  bucket = "tyhgboooooooooooooooowsllkijjj"
}

###################
# EC2 INSTANCES   #
###################
resource "aws_instance" "webserver1" { # Webserver 1
  ami                    = "ami-0360c520857e3138f"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub1.id
  user_data              = base64encode(file("userdata1.sh"))
}

resource "aws_instance" "webserver2" { # Webserver 2
  ami                    = "ami-0360c520857e3138f"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.sub2.id
  user_data              = base64encode(file("userdata2.sh"))
}

####################################
# APPLICATION LOAD BALANCER (ALB)  #
####################################
resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.webSg.id]
  subnets         = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  tags = {
    Name = "web"
  }
}

###################
# TARGET GROUP    #
###################
resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

###################################
# TARGET GROUP ATTACHMENTS (TGA)  #
###################################
resource "aws_lb_target_group_attachment" "attach1" { # Webserver1 -> TG
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "attach2" { # Webserver2 -> TG
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

##################
# ALB LISTENER   #
##################
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

############
# OUTPUT   #
############
output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name
}
