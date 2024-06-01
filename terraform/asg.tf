resource "aws_launch_template" "lt_1" {
  name_prefix   = "${var.tag_name}-lt"
  image_id      = data.aws_ami.latest_ami.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    subnet_id       = aws_subnet.public_1.id
    security_groups = [aws_security_group.sg_1.id]
  }
  user_data = filebase64("user-data.sh")
}

# Define a target group for load balancing
resource "aws_lb_target_group" "tg_1" {
  name     = "${var.tag_name}-tg"
  port     = 80
  protocol = "HTTP" 
  vpc_id   = aws_vpc.vpc_1.id

  health_check {
    protocol            = "HTTP"
    port                = "80"
    path                = "/wp-admin/install.php"
    timeout             = 5
    interval            = 60
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Create a new Auto Scaling Group
resource "aws_autoscaling_group" "asg_1" {
  name                      = "${var.tag_name}-asg"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id = aws_launch_template.lt_1.id
  }

  vpc_zone_identifier = [
    aws_subnet.public_2.id,
    aws_subnet.public_1.id
  ]

  target_group_arns = ["${aws_lb_target_group.tg_1.arn}"]
}

# Create Load Balancer
resource "aws_lb" "lb_1" {
  name               = "${var.tag_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_1.id]
  subnets = [
    aws_subnet.public_2.id,
    aws_subnet.public_1.id
  ]

  enable_deletion_protection = false
}

# Create Listener Rule
resource "aws_lb_listener_rule" "lr_1" {
  listener_arn = aws_lb_listener.listener_1.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_1.arn
  }

  condition {
    path_pattern {
      values = ["/wp-admin/install.php"]
    }
  }
}

# Create Listener
resource "aws_lb_listener" "listener_1" {
  load_balancer_arn = aws_lb.lb_1.arn
  port              = "80"
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  #certificate_arn   = "arn:aws:acm:us-west-1:730335274738:certificate/682a2604-4e75-48de-b957-00ef8cfb427b" 

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_1.arn
  }
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale-out-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_1.name
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale-in-policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg_1.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cloudwatch_metric_alarm_cpu_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_1.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_out_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cloudwatch_metric_alarm_cpu_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_1.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.scale_in_policy.arn]
}

