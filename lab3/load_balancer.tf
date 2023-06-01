
# Create a Load Balancer ------------------------------------------------------
resource "aws_lb" "load_balancer" {
  name               = "load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = [aws_subnet.terraform_sub1.id, aws_subnet.terraform_sub2.id]

  enable_deletion_protection = false
  tags = {
    name = "load-balancer"
  }
}

# Create a Load Balancer Target Group -----------------------------------------

resource "aws_lb_target_group" "alb-target" {
  name        = "alb-targets"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.terraform_vpc.id
}

# Create a Load Balancer Listener ---------------------------------------------
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  tags = {
    name = "listener"
  }
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-target.arn
  }
}

# # Create a Load Balancer Target -----------------------------------------------
# resource "aws_lb_target_group_attachment" "test" {
#   target_group_arn = aws_lb_target_group.alb-target.arn
#   target_id        = aws_autoscaling_group.asg-to.id
#   port             = 80
# }
