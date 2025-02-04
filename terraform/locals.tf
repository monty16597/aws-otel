locals {
  project_name               = "aws-xray-dotnet"
  environment_name           = "poc"
  name_prefix                = lower("${local.environment_name}-${local.project_name}")
  ecs_service_name           = "sample-dotnet-app"
  ecs_service_log_group_name = "/aws/${local.project_name}/${local.environment_name}/ecs-services/${local.ecs_service_name}"
}
