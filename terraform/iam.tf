#IAM to read SSM Parameters

# Create IAM Role
resource "aws_iam_role" "ec2_ssm_role" {
  name = "${var.tag_name}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.tag_name}-ec2-ssm-role"
  }
}

# Attach Policy to IAM Role
resource "aws_iam_role_policy" "ssm_read_policy" {
  name = "${var.tag_name}-ssm-read-policy"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "ssm:GetParameterHistory"
        ]
        Resource = "*"
      }
    ]
  })
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.tag_name}-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name

  tags = {
    Name = "${var.tag_name}-instance-profile"
  }
}

