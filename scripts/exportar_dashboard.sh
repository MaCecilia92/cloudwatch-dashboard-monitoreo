#!/usr/bin/env bash
# Exporta la definición actual del dashboard (lo mismo que "Actions > View/edit source" en la consola).
# Uso: ./scripts/exportar_dashboard.sh [region]
set -euo pipefail
REGION="${1:-us-east-1}"
aws cloudwatch get-dashboard --region "$REGION" --dashboard-name Servidor-Web-Monitoreo-Dashboard \
  --query DashboardBody --output text | python3 -m json.tool > dashboard/exportado-desde-aws.json
echo "Guardado en dashboard/exportado-desde-aws.json"
