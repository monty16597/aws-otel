resource "aws_ssm_parameter" "cwagent" {
  name  = "ecs-cwagent"
  type  = "String"
  value = <<EOF
{
  "traces": {
    "traces_collected": {
      "application_signals": {}
    }
  },
  "logs": {
    "metrics_collected": {
      "application_signals": {}
    }
  }
}
EOF
}

output "ssm" {
    value = aws_ssm_parameter.cwagent.name
}