#!/usr/bin/env bash
# Verifica con AWS CLI que lo DESPLEGADO coincide con lo que está en el repositorio.
# Se puede correr en AWS CloudShell (ya trae AWS CLI y credenciales):
#   git clone https://github.com/MaCecilia92/cloudwatch-dashboard-monitoreo && cd cloudwatch-dashboard-monitoreo
#   bash scripts/verificar_dashboard.sh [nombre-del-stack] [region]
set -euo pipefail
STACK="${1:-monitoreo-servidor-web}"
REGION="${2:-us-east-1}"
NOMBRE="Servidor-Web-Monitoreo-Dashboard"

salida() { aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
  --query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue" --output text; }

echo "1) Stack"
aws cloudformation describe-stacks --region "$REGION" --stack-name "$STACK" \
  --query 'Stacks[0].[StackName,StackStatus]' --output text
INSTANCIA=$(salida InstanciaId)
CUENTA=$(aws sts get-caller-identity --query Account --output text)

echo "2) Instancia monitoreada"
aws ec2 describe-instances --region "$REGION" --instance-ids "$INSTANCIA" \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,InstanceType,VpcId]' --output text

echo "3) Dashboard desplegado vs. dashboard/Servidor-Web-Monitoreo-Dashboard.json"
aws cloudwatch get-dashboard --region "$REGION" --dashboard-name "$NOMBRE" \
  --query DashboardBody --output text > /tmp/desplegado.json
sed -e "s/i-REEMPLAZAR_POR_TU_INSTANCIA/$INSTANCIA/g" -e "s/REEMPLAZAR_ID_CUENTA/$CUENTA/g" \
  dashboard/Servidor-Web-Monitoreo-Dashboard.json > /tmp/esperado.json
# Se comparan los JSON normalizados (mismo orden de claves, sin espacios), no el texto.
python3 - <<'PY'
import json, sys
a = json.load(open('/tmp/desplegado.json')); b = json.load(open('/tmp/esperado.json'))
norm = lambda x: json.dumps(x, sort_keys=True, ensure_ascii=False)
if norm(a) == norm(b):
    print(f"   OK: coinciden los {len(a['widgets'])} widgets")
else:
    print("   DIFERENCIAS:")
    for i, (wa, wb) in enumerate(zip(a['widgets'], b['widgets'])):
        if norm(wa) != norm(wb):
            print(f"   - widget {i}: {wa['properties'].get('title', wa['type'])}")
    sys.exit(1)
PY

echo "4) Alarma"
aws cloudwatch describe-alarms --region "$REGION" --alarm-names servidor-web-cpu-alta \
  --query 'MetricAlarms[0].[AlarmName,StateValue,Threshold,EvaluationPeriods]' --output text
echo "5) Últimos cambios de estado de la alarma"
aws cloudwatch describe-alarm-history --region "$REGION" --alarm-name servidor-web-cpu-alta \
  --history-item-type StateUpdate --max-items 5 --query 'AlarmHistoryItems[].[Timestamp,HistorySummary]' --output text
