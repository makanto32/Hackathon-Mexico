<#
.SYNOPSIS
    Carga datos CSV a Cosmos DB y archivos al Storage Account desplegado.

.DESCRIPTION
    Este script:
    1. Carga archivos CSV a los contenedores de Cosmos DB (Customers, Transactions, Products)
    2. Sube archivos CSV al Storage Account (contenedor csv-upload)
    3. Extrae y sube archivos PDF de un ZIP al Storage Account (contenedor documents-pdf)

.PARAMETER ResourceGroupName
    Nombre del Resource Group donde se desplegaron los recursos.

.PARAMETER CsvPath
    Ruta a la carpeta que contiene los archivos CSV (customers.csv, transactions.csv, products.csv)

.PARAMETER PdfZipPath
    Ruta al archivo ZIP que contiene los PDFs.

.EXAMPLE
    .\Load-DataToAzure.ps1 -ResourceGroupName "rg-fabric-challenge-test" -CsvPath ".\sample-data" -PdfZipPath ".\documents.zip"

.EXAMPLE
    .\Load-DataToAzure.ps1 -ResourceGroupName "rg-fabric-challenge-msalas"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Nombre del Resource Group")]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false, HelpMessage = "Ruta a la carpeta con archivos CSV")]
    [string]$CsvPath,

    [Parameter(Mandatory = $false, HelpMessage = "Ruta al archivo ZIP con PDFs")]
    [string]$PdfZipPath
)

$ErrorActionPreference = "Stop"

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

function Write-Step { param([string]$Message) Write-Host "`n📌 $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Info { param([string]$Message) Write-Host "ℹ️  $Message" -ForegroundColor Yellow }
function Write-ErrorMsg { param([string]$Message) Write-Host "❌ $Message" -ForegroundColor Red }

# Función para insertar documento en Cosmos DB
function Add-CosmosDocument {
    param(
        [string]$Endpoint,
        [string]$Key,
        [string]$Database,
        [string]$Container,
        [hashtable]$Document
    )

    $resourceLink = "dbs/$Database/colls/$Container"
    $uri = "$Endpoint$resourceLink/docs"
    $date = [DateTime]::UtcNow.ToString("r")

    # Generar firma
    $keyBytes = [System.Convert]::FromBase64String($Key)
    $text = "post`ndocs`n$resourceLink`n$($date.ToLower())`n`n"
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $keyBytes
    $hash = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($text))
    $signature = [System.Convert]::ToBase64String($hash)
    $authToken = [System.Web.HttpUtility]::UrlEncode("type=master&ver=1.0&sig=$signature")

    # Obtener partition key value
    $partitionKeyValue = switch ($Container) {
        "Customers" { $Document.customerId }
        "Transactions" { $Document.transactionId }
        "Products" { $Document.productId }
        default { $Document.id }
    }

    $headers = @{
        "Authorization"                    = $authToken
        "x-ms-date"                        = $date
        "x-ms-version"                     = "2018-12-31"
        "Content-Type"                     = "application/json"
        "x-ms-documentdb-partitionkey"     = "[`"$partitionKeyValue`"]"
        "x-ms-documentdb-is-upsert"        = "true"
    }

    try {
        $body = $Document | ConvertTo-Json -Depth 10 -Compress
        $response = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body -ContentType "application/json"
        return $true
    }
    catch {
        if ($_.Exception.Response.StatusCode -eq 409) {
            return $true  # Ya existe
        }
        return $false
    }
}

# ============================================================================
# BANNER
# ============================================================================
Write-Host @"

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   📊  FABRIC DATA CHALLENGE - DATA LOADER                                   ║
║                                                                              ║
║   Este script cargará:                                                       ║
║   • Datos CSV a Cosmos DB (Customers, Transactions, Products)               ║
║   • Archivos CSV al Storage Account                                         ║
║   • Archivos PDF al Storage Account                                         ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Magenta

# ============================================================================
# OBTENER INFORMACIÓN DE LOS RECURSOS
# ============================================================================
Write-Step "Obteniendo información de los recursos desplegados..."

# Verificar login en Azure
$account = az account show --output json 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Info "Iniciando sesión en Azure..."
    az login
}

# Obtener recursos del Resource Group
Write-Info "Buscando recursos en: $ResourceGroupName"

# Cosmos DB
$cosmosAccount = az cosmosdb list --resource-group $ResourceGroupName --query "[0]" --output json | ConvertFrom-Json
if (-not $cosmosAccount) {
    Write-ErrorMsg "No se encontró Cosmos DB en el Resource Group"
    exit 1
}
$cosmosAccountName = $cosmosAccount.name
$cosmosEndpoint = $cosmosAccount.documentEndpoint
Write-Success "Cosmos DB encontrado: $cosmosAccountName"

# Obtener key de Cosmos DB
$cosmosKeys = az cosmosdb keys list --name $cosmosAccountName --resource-group $ResourceGroupName --output json | ConvertFrom-Json
$cosmosKey = $cosmosKeys.primaryMasterKey

# Storage Account
$storageAccount = az storage account list --resource-group $ResourceGroupName --query "[0]" --output json | ConvertFrom-Json
if (-not $storageAccount) {
    Write-ErrorMsg "No se encontró Storage Account en el Resource Group"
    exit 1
}
$storageAccountName = $storageAccount.name
Write-Success "Storage Account encontrado: $storageAccountName"

# ============================================================================
# CARGAR DATOS CSV A COSMOS DB
# ============================================================================
Write-Step "Cargando datos a Cosmos DB..."

$DatabaseName = "FabricChallengeDB"

# Definir datos de ejemplo si no se proporciona CsvPath
$ScriptRoot = $PSScriptRoot
if (-not $CsvPath) {
    $CsvPath = Join-Path (Split-Path $ScriptRoot -Parent) "sample-data"
}

# Mapeo de archivos a contenedores
$csvMapping = @{
    "customers.csv"    = @{ Container = "Customers"; IdField = "customerId" }
    "transactions.csv" = @{ Container = "Transactions"; IdField = "transactionId" }
    "products.csv"     = @{ Container = "Products"; IdField = "productId" }
}

if (Test-Path $CsvPath) {
    $csvFiles = Get-ChildItem -Path $CsvPath -Filter "*.csv" -ErrorAction SilentlyContinue

    foreach ($csvFile in $csvFiles) {
        $fileName = $csvFile.Name.ToLower()
        
        if ($csvMapping.ContainsKey($fileName)) {
            $mapping = $csvMapping[$fileName]
            $containerName = $mapping.Container
            $idField = $mapping.IdField
            
            Write-Info "Procesando: $($csvFile.Name) -> $containerName"
            
            # Leer CSV
            $data = Import-Csv -Path $csvFile.FullName -Encoding UTF8
            $total = $data.Count
            $loaded = 0
            $failed = 0
            
            foreach ($row in $data) {
                # Convertir fila a hashtable
                $document = @{}
                foreach ($prop in $row.PSObject.Properties) {
                    $document[$prop.Name] = $prop.Value
                }
                
                # Asegurar campo id
                if ($document.ContainsKey($idField)) {
                    $document["id"] = $document[$idField]
                }
                else {
                    $document["id"] = [guid]::NewGuid().ToString()
                }
                
                # Insertar en Cosmos DB
                $success = Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey `
                    -Database $DatabaseName -Container $containerName -Document $document
                
                if ($success) { $loaded++ } else { $failed++ }
            }
            
            Write-Success "$containerName : $loaded cargados / $failed fallidos / $total total"
        }
    }
}
else {
    Write-Info "No se encontró carpeta CSV en: $CsvPath"
    Write-Info "Creando datos de ejemplo directamente..."
    
    # Datos de ejemplo embebidos
    $sampleCustomers = @(
        @{id="CUST001"; customerId="CUST001"; firstName="Carlos"; lastName="García"; email="carlos.garcia@email.com"; country="Mexico"; segment="Premium"; loyaltyPoints=2500},
        @{id="CUST002"; customerId="CUST002"; firstName="María"; lastName="López"; email="maria.lopez@email.com"; country="Mexico"; segment="Standard"; loyaltyPoints=1200},
        @{id="CUST003"; customerId="CUST003"; firstName="Juan"; lastName="Martínez"; email="juan.martinez@email.com"; country="Mexico"; segment="Premium"; loyaltyPoints=3100},
        @{id="CUST004"; customerId="CUST004"; firstName="Ana"; lastName="Rodríguez"; email="ana.rodriguez@email.com"; country="Colombia"; segment="Gold"; loyaltyPoints=4500},
        @{id="CUST005"; customerId="CUST005"; firstName="Pedro"; lastName="Hernández"; email="pedro.hernandez@email.com"; country="Chile"; segment="Standard"; loyaltyPoints=800}
    )
    
    $sampleTransactions = @(
        @{id="TXN001"; transactionId="TXN001"; customerId="CUST001"; productId="PROD001"; amount=150.00; date="2024-01-15"; status="Completed"},
        @{id="TXN002"; transactionId="TXN002"; customerId="CUST002"; productId="PROD005"; amount=89.99; date="2024-01-16"; status="Completed"},
        @{id="TXN003"; transactionId="TXN003"; customerId="CUST003"; productId="PROD010"; amount=45.50; date="2024-01-17"; status="Completed"},
        @{id="TXN004"; transactionId="TXN004"; customerId="CUST001"; productId="PROD003"; amount=299.99; date="2024-01-18"; status="Completed"},
        @{id="TXN005"; transactionId="TXN005"; customerId="CUST004"; productId="PROD007"; amount=75.00; date="2024-01-19"; status="Pending"}
    )
    
    $sampleProducts = @(
        @{id="PROD001"; productId="PROD001"; productName="Laptop Pro 15"; category="Electronics"; unitPrice=150.00; stock=250},
        @{id="PROD003"; productId="PROD003"; productName="Smart Watch Series 5"; category="Electronics"; unitPrice=299.99; stock=350},
        @{id="PROD005"; productId="PROD005"; productName="Bluetooth Speaker"; category="Electronics"; unitPrice=89.99; stock=500},
        @{id="PROD007"; productId="PROD007"; productName="Wireless Mouse"; category="Accessories"; unitPrice=75.00; stock=750},
        @{id="PROD010"; productId="PROD010"; productName="Webcam HD"; category="Electronics"; unitPrice=45.50; stock=550}
    )
    
    # Cargar Customers
    Write-Info "Cargando Customers..."
    $loaded = 0
    foreach ($doc in $sampleCustomers) {
        if (Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey -Database $DatabaseName -Container "Customers" -Document $doc) {
            $loaded++
        }
    }
    Write-Success "Customers: $loaded cargados"
    
    # Cargar Transactions
    Write-Info "Cargando Transactions..."
    $loaded = 0
    foreach ($doc in $sampleTransactions) {
        if (Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey -Database $DatabaseName -Container "Transactions" -Document $doc) {
            $loaded++
        }
    }
    Write-Success "Transactions: $loaded cargados"
    
    # Cargar Products
    Write-Info "Cargando Products..."
    $loaded = 0
    foreach ($doc in $sampleProducts) {
        if (Add-CosmosDocument -Endpoint $cosmosEndpoint -Key $cosmosKey -Database $DatabaseName -Container "Products" -Document $doc) {
            $loaded++
        }
    }
    Write-Success "Products: $loaded cargados"
}

# ============================================================================
# SUBIR ARCHIVOS CSV AL STORAGE ACCOUNT
# ============================================================================
Write-Step "Subiendo archivos CSV al Storage Account..."

if (Test-Path $CsvPath) {
    $csvFiles = Get-ChildItem -Path $CsvPath -Filter "*.csv" -ErrorAction SilentlyContinue
    foreach ($csv in $csvFiles) {
        Write-Info "Subiendo $($csv.Name)..."
        az storage blob upload `
            --account-name $storageAccountName `
            --container-name "csv-upload" `
            --file $csv.FullName `
            --name $csv.Name `
            --auth-mode login `
            --overwrite `
            --output none 2>$null
    }
    Write-Success "Archivos CSV subidos al contenedor 'csv-upload'"
}
else {
    Write-Info "No se encontraron archivos CSV para subir al Storage"
}

# ============================================================================
# SUBIR ARCHIVOS PDF AL STORAGE ACCOUNT
# ============================================================================
if ($PdfZipPath -and (Test-Path $PdfZipPath)) {
    Write-Step "Procesando archivo ZIP con PDFs..."
    
    # Crear carpeta temporal
    $tempFolder = Join-Path $env:TEMP "pdf-extract-$(Get-Random)"
    New-Item -Path $tempFolder -ItemType Directory -Force | Out-Null
    
    try {
        # Extraer ZIP
        Write-Info "Extrayendo archivos del ZIP..."
        Expand-Archive -Path $PdfZipPath -DestinationPath $tempFolder -Force
        
        # Buscar PDFs (incluyendo subcarpetas)
        $pdfFiles = Get-ChildItem -Path $tempFolder -Filter "*.pdf" -Recurse
        
        if ($pdfFiles.Count -gt 0) {
            Write-Info "Encontrados $($pdfFiles.Count) archivos PDF"
            
            foreach ($pdf in $pdfFiles) {
                Write-Info "Subiendo $($pdf.Name)..."
                az storage blob upload `
                    --account-name $storageAccountName `
                    --container-name "documents-pdf" `
                    --file $pdf.FullName `
                    --name $pdf.Name `
                    --auth-mode login `
                    --overwrite `
                    --output none 2>$null
            }
            Write-Success "$($pdfFiles.Count) archivos PDF subidos al contenedor 'documents-pdf'"
        }
        else {
            Write-Info "No se encontraron archivos PDF en el ZIP"
        }
    }
    finally {
        # Limpiar carpeta temporal
        if (Test-Path $tempFolder) {
            Remove-Item -Path $tempFolder -Recurse -Force
        }
    }
}
elseif ($PdfZipPath) {
    Write-Info "Archivo ZIP no encontrado: $PdfZipPath"
}
else {
    Write-Info "No se especificó archivo ZIP con PDFs. Usa -PdfZipPath para incluir PDFs."
}

# ============================================================================
# RESUMEN FINAL
# ============================================================================
Write-Host @"

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║   🎉  ¡CARGA DE DATOS COMPLETADA!                                           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Green

Write-Host " RESUMEN:" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Gray
Write-Host ""
Write-Host "  COSMOS DB: $cosmosAccountName" -ForegroundColor Yellow
Write-Host "   Database:   FabricChallengeDB"
Write-Host "   Contenedores: Customers, Transactions, Products"
Write-Host ""
Write-Host " STORAGE ACCOUNT: $storageAccountName" -ForegroundColor Yellow
Write-Host "   Contenedores con datos:"
Write-Host "   • csv-upload     - Archivos CSV"
Write-Host "   • documents-pdf  - Archivos PDF"
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Gray

Write-Host "`n CONEXIÓN DESDE FABRIC:" -ForegroundColor Cyan
Write-Host "   Cosmos DB Endpoint: $cosmosEndpoint"
Write-Host "   Storage Account:    https://$storageAccountName.dfs.core.windows.net/"
Write-Host ""
