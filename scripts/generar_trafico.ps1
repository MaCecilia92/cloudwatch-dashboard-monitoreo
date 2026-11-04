# Genera tráfico de red contra el servidor (Windows PowerShell).
# Uso: .\scripts\generar_trafico.ps1 -Url http://ec2-xx-xx-xx-xx.compute-1.amazonaws.com -Veces 30
param([Parameter(Mandatory=$true)][string]$Url, [int]$Veces = 30)
for ($i = 1; $i -le $Veces; $i++) {
  $t = Measure-Command { Invoke-WebRequest -Uri "$Url/archivo-prueba.bin" -OutFile $env:TEMP\prueba.bin -UseBasicParsing }
  Write-Host ("Descarga {0}: {1:N1} s" -f $i, $t.TotalSeconds)
}
Remove-Item $env:TEMP\prueba.bin -ErrorAction SilentlyContinue
Write-Host "Listo. Las métricas básicas se publican cada 5 minutos: mirá el dashboard en 5 a 10 minutos."
