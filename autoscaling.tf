resource "aws_launch_template" "first_template" {
  name_prefix            = "terraform"
  image_id               = data.aws_ami.latest_amazon_linux.image_id
  instance_type          = "t2.micro"
  update_default_version = true
  vpc_security_group_ids = [aws_security_group.allow_http.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.iam_instance_profile.name
  }
  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    amazon-linux-extras install -y nginx1
    systemctl enable nginx --now
    EOF
  )
}

resource "aws_autoscaling_group" "bar" {
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = data.aws_subnets.default_vpc_subnets.ids

  launch_template {
    id      = aws_launch_template.first_template.id
    version = "$Latest"
  }
}