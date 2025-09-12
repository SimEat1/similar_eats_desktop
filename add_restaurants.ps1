param(
    [Parameter(Mandatory=$true)] [string]$ApiKey,
    [Parameter(Mandatory=$true)] [string]$Email,
    [Parameter(Mandatory=$true)] [string]$Password,
    [Parameter(Mandatory=$true)] [string]$DatabaseUrl
)

# --- 1) Sign in with email/password to get idToken ---
$authUrl  = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$ApiKey"
$authBody = @{
    email = $Email
    password = $Password
    returnSecureToken = $true
} | ConvertTo-Json

try {
    $authResponse = Invoke-RestMethod -Method Post -Uri $authUrl -Body $authBody -ContentType "application/json"
} catch {
    Write-Error "Auth failed: $($_.Exception.Message)"
    return
}
$idToken = $authResponse.idToken
Write-Host "✔ Authenticated as $Email" -ForegroundColor Green

# --- 2) Seed restaurants (notice single quotes to avoid & problems) ---
$restaurants = @(
    @{
        id = 'resto101'
        name = 'Drive Thru Burgers'
        openLateFlag = $false
        quickServiceFlag = $true
        serviceTags = @('drive_thru','fast_service','bbq')
    },
    @{
        id = 'resto102'
        name = 'Salad & Go'
        openLateFlag = $false
        quickServiceFlag = $true
        serviceTags = @('healthy','grab_and_go')
    },
    @{
        id = 'resto103'
        name = 'Taco Express'
        openLateFlag = $true
        quickServiceFlag = $true
        serviceTags = @('tacos','late_night','fast_service')
    },
    @{
        id = 'resto104'
        name = 'Bento Box Co.'
        openLateFlag = $false
        quickServiceFlag = $true
        serviceTags = @('japanese','counter')
    },
    @{
        id = 'resto105'
        name = 'Night Owl Pizza'
        openLateFlag = $true
        quickServiceFlag = $false
        serviceTags = @('pizza','late_night')
    },
    @{
        id = 'resto106'
        name = '24/7 Diner'
        openLateFlag = $true
        quickServiceFlag = $false
        serviceTags = @('breakfast','late_night')
    }
)

# --- 3) PUT each restaurant into RTDB ---
$ok = 0; $fail = 0
foreach ($r in $restaurants) {
    $id   = $r.id
    $url  = "$DatabaseUrl/restaurants/$id.json?auth=$idToken"
    $body = $r | ConvertTo-Json -Depth 5
    try {
        Invoke-RestMethod -Method Put -Uri $url -Body $body -ContentType "application/json" | Out-Null
        Write-Host "✔ Added $($r.name)" -ForegroundColor Cyan
        $ok++
    } catch {
        Write-Warning "Failed to add $($r.name): $($_.Exception.Message)"
        $fail++
    }
}
Write-Host "Done. Success: $ok, Failed: $fail" -ForegroundColor Yellow
