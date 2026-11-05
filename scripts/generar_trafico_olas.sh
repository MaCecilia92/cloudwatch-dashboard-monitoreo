#!/usr/bin/env bash
# Tráfico en "olas" durante ~30 minutos, para ver en el dashboard cómo cambian los gráficos con el tiempo.
# Uso: ./scripts/generar_trafico_olas.sh http://<UrlServidor>
#   Ola 1 (10 min): muchas visitas chicas a la página principal  -> sube NetworkPacketsIn/Out, pocos bytes
#   Pausa (5 min): sin tráfico                                   -> las curvas bajan a ~0
#   Ola 2 (10 min): descargas del archivo de 20 MB               -> NetworkOut muy alto
set -uo pipefail
URL="${1:?Indicá la URL del servidor}"
fin=$(( $(date +%s) + 600 )); n=0
echo "Ola 1: visitas chicas"; while [ "$(date +%s)" -lt "$fin" ]; do curl -s -o /dev/null "$URL/"; n=$((n+1)); done; echo "  $n visitas"
echo "Pausa de 5 minutos"; sleep 300
fin=$(( $(date +%s) + 600 )); n=0
echo "Ola 2: descargas grandes"; while [ "$(date +%s)" -lt "$fin" ]; do curl -s -o /dev/null "$URL/archivo-prueba.bin"; n=$((n+1)); done; echo "  $n descargas"
