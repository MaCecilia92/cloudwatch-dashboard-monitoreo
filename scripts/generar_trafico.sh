#!/usr/bin/env bash
# Genera tráfico de red contra el servidor para verlo en el dashboard (Linux, macOS o Git Bash).
# Uso: ./scripts/generar_trafico.sh http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com [descargas]
# Cada descarga del archivo de prueba suma ~20 MB a NetworkOut del servidor.
set -euo pipefail
URL="${1:?Indicá la URL del servidor (salida UrlServidor del stack)}"
VECES="${2:-30}"
for i in $(seq 1 "$VECES"); do
  curl -s -o /dev/null -w "Descarga $i: %{size_download} bytes en %{time_total} s\n" "$URL/archivo-prueba.bin"
done
echo "Listo. Las métricas básicas se publican cada 5 minutos: mirá el dashboard en 5 a 10 minutos."
