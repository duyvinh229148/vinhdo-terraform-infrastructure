data "aws_iam_policy_document" "codebuild_base_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:/aws/codebuild/${local.codebuild_project_name}",
      "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:log-group:/aws/codebuild/${local.codebuild_project_name}:*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::codepipeline-${local.aws_region}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
    resources = [
      "arn:aws:codebuild:${local.aws_region}:${local.aws_account_id}:report-group/${local.codebuild_project_name}-*"
    ]
  }
}

data "aws_iam_policy_document" "ecr_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:PutLifecyclePolicy",
      "ecr:DescribeImageScanFindings",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:CreateRepository",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListTagsForResource",
      "ecr:UploadLayerPart",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetRepositoryPolicy",
      "ecr:GetLifecyclePolicy"
    ]
    resources = [
      "arn:aws:ecr:${local.aws_region}:${local.aws_account_id}:repository/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3_buckets_access_policy" {
  statement {
    effect = "Allow"
    resources = concat(
      formatlist("arn:aws:s3:::%s", var.s3_buckets),
      formatlist("arn:aws:s3:::%s/*", var.s3_buckets)
    )
    actions = [
      "s3:List*",
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:AbortMultipartUpload"
    ]
  }
}

data "aws_iam_policy_document" "kubernetes-access-policy" {
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:eks:*:${var.aws_account_id}:cluster/*"
    ]
    actions = [
      "eks:AccessKubernetesApi",
      "eks:DescribeCluster"
    ]
  }

  statement {
    effect = "Allow"
    resources = [
      "*"
    ]
    actions = [
      "eks:ListClusters"
    ]
  }

  statement {
    effect = "Allow"
    resources = data.aws_iam_roles.kubernetes_deployer.arns
  }
}

