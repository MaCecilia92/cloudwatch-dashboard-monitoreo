#!/usr/bin/env bash
# Sube la CPU de la instancia durante 10 minutos para ver el pico en CPUUtilization.
# Se ejecuta DENTRO de la instancia: EC2 > Instancias > Conectar > Session Manager.
# t3.micro tiene 2 vCPU, por eso se lanzan 2 procesos. Se detiene solo (timeout).
for n in 1 2; do timeout 600 sh -c 'while :; do :; done' & done
echo "CPU al 100 % por 10 minutos. Para cortarlo antes: pkill -f 'while :; do :; done'"
