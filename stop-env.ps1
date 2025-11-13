$rg = "rg-cartrack-dev"
$frontend = "cartrack-app"
$backend  = "cartrack-backend-app"
$db       = "cartrack-db"

Write-Host "== Stop: App Service =="
az webapp stop -g $rg -n $frontend | Out-Null
az webapp stop -g $rg -n $backend  | Out-Null

Write-Host "== Stop: PostgreSQL Flexible Server =="
az postgres flexible-server stop -g $rg -n $db | Out-Null

Write-Host "`n== Status =="
az webapp list -g $rg --query "[].{name:name,state:state}" -o table
az postgres flexible-server show -g $rg -n $db --query "{name:name,state:state}" -o table
