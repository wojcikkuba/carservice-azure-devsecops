$rg = "rg-cartrack-dev"
$frontend = "cartrack-app"
$backend  = "cartrack-backend-app"
$db       = "cartrack-db"

Write-Host "== Start: PostgreSQL Flexible Server =="
az postgres flexible-server start -g $rg -n $db | Out-Null

Write-Host "Czekam na Ready bazy (max ~2 min)..."
for ($i=0; $i -lt 24; $i++) {
  $state = az postgres flexible-server show -g $rg -n $db --query state -o tsv
  if ($state -eq "Ready") { break }
  Start-Sleep -Seconds 5
}

Write-Host "== Start: App Service =="
az webapp start -g $rg -n $frontend | Out-Null
az webapp start -g $rg -n $backend  | Out-Null

Write-Host "`n== Status =="
az webapp list -g $rg --query "[].{name:name,state:state}" -o table
az postgres flexible-server show -g $rg -n $db --query "{name:name,state:state}" -o table
