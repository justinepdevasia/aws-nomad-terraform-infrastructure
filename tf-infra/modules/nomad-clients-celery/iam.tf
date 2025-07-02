data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_permissions" {

  # policy for auto-discovering cluster
   statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "autoscaling:DescribeAutoScalingGroups",
    ]
    resources = ["*"]
  }

  # policy for giving access to s3 from ec2
   statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::*"]
  }

  # policy for mounting ebs voumes
   statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeTags",
      "ec2:DescribeVolumes",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
    ]
    resources = ["*"]
  }

  # policy to access ecr and fetch images
   statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]

    resources = ["*"]
  }

  # policy to access opensearch cluster
   statement {
    effect = "Allow"
    actions = [
      "es:*"
    ]
    resources = ["*"]
  }

  
}

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = "nomad_client_celery_profile"
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = "nomad_client_celery_role"
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
}

resource "aws_iam_role_policy" "ec2_permissions" {
  name   = "auto-discover-cluster"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.ec2_permissions.json
}

data "aws_iam_policy_document" "efs_permissions" {
  
  # permissions required for efs plugin attachment
  statement {
    effect = "Allow"

    actions   = [
      "elasticfilesystem:DescribeAccessPoints",
      "elasticfilesystem:DescribeFileSystems",
      "elasticfilesystem:DescribeMountTargets",
      "ec2:DescribeAvailabilityZones",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:CreateAccessPoint",
    ]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:RequestTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:TagResource",
    ]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticfilesystem:DeleteAccessPoint",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/efs.csi.aws.com/cluster"
      values   = ["true"]
    }
  }
}

resource "aws_iam_role_policy" "efs_permissions" {
  name   = "efs-permissions"
  role   = aws_iam_role.instance_role.id
  policy = data.aws_iam_policy_document.efs_permissions.json
}
