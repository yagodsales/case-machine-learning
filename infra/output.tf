output "invoke_url" {
  value = format(
    "https://%s.execute-api.%s.amazonaws.com/%s",
    aws_api_gateway_rest_api.avaliacoes_gw_api.id,
    var.aws_region,
    var.stage_name
  )
}
