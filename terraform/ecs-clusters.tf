module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.12.0"

  cluster_name = local.name_prefix

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/${local.project_name}/${local.environment_name}/ecs/cluster/"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    },
  }
}
