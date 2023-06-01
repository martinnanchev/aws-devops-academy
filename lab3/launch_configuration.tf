# Create a Launch Configuration -----------------------------------------------
resource "aws_launch_template" "first_template" {
  name_prefix            = "terraform"
  image_id               = "ami-0e23c576dacf2e3df"
  instance_type          = "t2.micro"
  update_default_version = true
  iam_instance_profile {
    name = aws_iam_instance_profile.iam_instance_profile.name
   }
  tags = {
      Name =  "first-template"
  }
   
  vpc_security_group_ids = [aws_security_group.allow_sec1.id]

  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    amazon-linux-extras install -y nginx1
    systemctl enable nginx --now
    EOF
  )
}

# Create a ASG ----------------------------------------------------------------
resource "aws_autoscaling_group" "asg-to" {
  desired_capacity   = 2
  max_size           = 4
  min_size           = 2
  vpc_zone_identifier = [aws_subnet.terraform_sub3.id, aws_subnet.terraform_sub4.id]
target_group_arns = [ aws_lb_target_group.alb-target.arn ]
  launch_template {
    id      = aws_launch_template.first_template.id
    version = "$Latest"
  }
}

# Create Auto Scale Policy ----------------------------------------------------

resource "aws_autoscaling_policy" "the_policy" {
  name                   = "the-auto-policy"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg-to.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment = 4
}

# Cloudwatch config -----------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "terraform-test-foobar5"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions = [aws_autoscaling_policy.the_policy.arn]
}

# Attach Policy ---------------------------------------------------------------
resource "aws_autoscaling_attachment" "asg_attachment_lb" {
  autoscaling_group_name = aws_autoscaling_group.asg-to.id
  lb_target_group_arn = aws_lb_target_group.alb-target.arn
}