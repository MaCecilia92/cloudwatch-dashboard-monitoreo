#!/usr/bin/env bash
# Crea (o actualiza) el dashboard con el JSON del repositorio, para una instancia que ya existe.
# Uso: ./scripts/crear_dashboard.sh i-0abc1234567890def [region]
# (El widget de alarma espera que exista la alarma "servidor-web-cpu-alta": la crea la plantilla.)
set -euo pipefail
INSTANCIA="${1:?Indicá el ID de la instancia, por ejemplo i-0abc1234567890def}"
REGION="${2:-us-east-1}"

# Evita la "confusión de instancias": confirma que el ID existe y muestra su VPC y estado.
aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCIA" \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,VpcId,Tags[?Key==`Name`]|[0].Value]' --output text

CUENTA=$(aws sts get-caller-identity --query Account --output text)
sed -e "s/i-REEMPLAZAR_POR_TU_INSTANCIA/$INSTANCIA/g" -e "s/REEMPLAZAR_ID_CUENTA/$CUENTA/g" \
    -e "s/\"us-east-1\"/\"$REGION\"/g" -e "s/:us-east-1:/:$REGION:/g" \
  dashboard/Servidor-Web-Monitoreo-Dashboard.json > /tmp/dashboard-body.json

aws cloudwatch put-dashboard --region "$REGION" \
  --dashboard-name Servidor-Web-Monitoreo-Dashboard \
  --dashboard-body file:///tmp/dashboard-body.json
echo "Listo: https://$REGION.console.aws.amazon.com/cloudwatch/home?region=$REGION#dashboards/dashboard/Servidor-Web-Monitoreo-Dashboard"
