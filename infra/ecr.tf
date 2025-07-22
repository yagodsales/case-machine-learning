resource "aws_ecr_repository" "repo-lambda" {
  name = "repo-lambda-machine-learning"

}

resource "null_resource" "ecr_image" {
  triggers = {
    python_file  = filesha1("${path.module}/../lambda/titanic_lambda.py")
    docker_file  = filesha1("${path.module}/../lambda/Dockerfile")
    model_pickle = filesha1("${path.module}/../lambda/model.pkl")
  }

  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.repo-lambda.repository_url}
      docker build -t ${aws_ecr_repository.repo-lambda.repository_url}:latest ../lambda
      docker push ${aws_ecr_repository.repo-lambda.repository_url}:latest
    EOT
  }
}



output "lambda_image_uri" {
  value = "${aws_ecr_repository.repo-lambda.repository_url}:latest"
}
