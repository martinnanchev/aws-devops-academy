# Create a Security Group -----------------------------------------------------
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["94.156.24.20/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

# Create a Security Group -----------------------------------------------------
resource "aws_security_group" "allow_sec1" {
  name        = "allow_sec1"
  description = "Allow HTTP inbound traffic to load"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description      = "Traffic from http_sec_group"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    security_groups = [aws_security_group.allow_http.id] 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

}