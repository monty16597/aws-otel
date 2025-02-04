
locals {
  ecs_service_name           = "sample-dotnet-app"
  ecs_service_log_group_name = "/aws/${var.project_name}/${var.environment_name}/ecs-services/${local.ecs_service_name}"
}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "5.12.0"

  name        = local.ecs_service_name
  cluster_arn = module.ecs_cluster.cluster_arn

  cpu              = 256
  memory           = 1024
  assign_public_ip = true

  # Container definition(s)
  container_definitions = {
    app = {
      cpu       = 256
      memory    = 1024
      essential = true
      image     = "skyli997/dotnet-app:v1"
      port_mappings = [
        {
          name          = "app"
          containerPort = 8080
          protocol      = "tcp"
          hostPort      = 8080
        }
      ]
      readonly_root_filesystem = false

      enable_cloudwatch_logging              = true
      create_cloudwatch_log_group            = true
      cloudwatch_log_group_name              = local.ecs_service_log_group_name
      cloudwatch_log_group_retention_in_days = 7
      memory_reservation                     = 100
      environment = [
        {
          "name" : "CORECLR_ENABLE_PROFILING",
          "value" : "1"
        },
        {
          "name" : "CORECLR_PROFILER",
          "value" : "{918728DD-259F-4A6A-AC2B-B85E1B658318}"
        },
        {
          "name" : "CORECLR_PROFILER_PATH",
          "value" : "/otel-auto-instrumentation/linux-x64/OpenTelemetry.AutoInstrumentation.Native.so"
        },
        {
          "name" : "DOTNET_ADDITIONAL_DEPS",
          "value" : "/otel-auto-instrumentation/AdditionalDeps"
        },
        {
          "name" : "DOTNET_SHARED_STORE",
          "value" : "/otel-auto-instrumentation/store"
        },
        {
          "name" : "DOTNET_STARTUP_HOOKS",
          "value" : "/otel-auto-instrumentation/net/OpenTelemetry.AutoInstrumentation.StartupHook.dll"
        },
        {
          "name" : "OTEL_DOTNET_AUTO_HOME",
          "value" : "/otel-auto-instrumentation"
        },
        {
          "name" : "OTEL_DOTNET_AUTO_PLUGINS",
          "value" : "AWS.Distro.OpenTelemetry.AutoInstrumentation.Plugin, AWS.Distro.OpenTelemetry.AutoInstrumentation"
        },
        {
          "name" : "OTEL_RESOURCE_ATTRIBUTES",
          "value" : "aws.log.group.names=${local.ecs_service_log_group_name},service.name=${local.ecs_service_name}"
        },
        {
          "name" : "OTEL_LOGS_EXPORTER",
          "value" : "none"
        },
        {
          "name" : "OTEL_METRICS_EXPORTER",
          "value" : "none"
        },
        {
          "name" : "OTEL_EXPORTER_OTLP_PROTOCOL",
          "value" : "http/protobuf"
        },
        {
          "name" : "OTEL_AWS_APPLICATION_SIGNALS_ENABLED",
          "value" : "true"
        },
        {
          "name" : "OTEL_AWS_APPLICATION_SIGNALS_EXPORTER_ENDPOINT",
          "value" : "http://localhost:4316/v1/metrics"
        },
        {
          "name" : "OTEL_EXPORTER_OTLP_TRACES_ENDPOINT",
          "value" : "http://localhost:4316/v1/traces"
        },
        {
          "name" : "OTEL_EXPORTER_OTLP_ENDPOINT",
          "value" : "http://localhost:4316"
        },
        {
          "name" : "OTEL_TRACES_SAMPLER",
          "value" : "xray"
        },
        {
          "name" : "OTEL_TRACES_SAMPLER_ARG",
          "value" : "endpoint=http://localhost:2000"
        },
        {
          "name" : "OTEL_PROPAGATORS",
          "value" : "tracecontext,baggage,b3,xray"
        }
      ],
      dependencies = [
        {
          "containerName" : "init",
          "condition" : "SUCCESS"
        }
      ],
      mount_points = [
        {
          "sourceVolume" : "opentelemetry-auto-instrumentation",
          "containerPath" : "/otel-auto-instrumentation",
          "readOnly" : false
        }
      ]
    },

    ecs-cwagent = {
      image                    = "public.ecr.aws/cloudwatch-agent/cloudwatch-agent:latest"
      essential                = true,
      readonly_root_filesystem = false,
      secrets = [
        {
          name      = "CW_CONFIG_CONTENT"
          valueFrom = aws_ssm_parameter.cwagent.name
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = true
          awslogs-group         = "/ecs/ecs-cwagent"
          awslogs-region        = var.region_name
          awslogs-stream-prefix = "ecs"
        }
      },

    },

    init = {
      image                    = "public.ecr.aws/aws-observability/adot-autoinstrumentation-dotnet:v1.6.0"
      essential                = false,
      readonly_root_filesystem = false,
      command = [
        "cp",
        "-a",
        "autoinstrumentation/.",
        "/otel-auto-instrumentation"
      ]
      mount_points = [
        {
          "sourceVolume" : "opentelemetry-auto-instrumentation",
          "containerPath" : "/otel-auto-instrumentation",
          "readOnly" : false
        }
      ]
    },


  }

  volume = [
    {
      "name" : "opentelemetry-auto-instrumentation"
    }
  ]



  tasks_iam_role_statements = [
    {
      effect    = "Allow"
      actions   = ["*"]
      resources = ["*"]
    }
  ]


  subnet_ids = data.aws_subnets.main.ids
  security_group_rules = {
    internal_ingress_8080 = {
      type        = "ingress"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "Expose service"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
