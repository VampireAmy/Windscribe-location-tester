# Usage:  .\ws-cycle.ps1 [-Protocol wireguard]
# Omit -Protocol to use the default saved in Windscribe's settings.
# Examples: .\ws-cycle.ps1 -Protocol stealth     .\ws-cycle.ps1 -Protocol udp:443
param(
    [string]$Protocol = "",
    [int]$TimeoutSec = 30
)

$cli = "C:\Program Files\Windscribe\windscribe-cli.exe"
if (-not (Test-Path $cli)) { $cli = "windscribe-cli" }

$US = @(
    # US East
    "Big Apple","Bles Park","Cloud City","Situation","Sunny","Bulls","Green Mill",
    "Belt Buckle","Big Guava","Moonshine Run","Coney Dog","Hawkins","Snow",
    "King James","Cub","Empire","Insomnia","Bill","Fresh Prince","Wrigley",
    "Florida Man","Cuban Sandwich","Inside Job","Vice","MIT","Harvard","Trade War",
    # US Central
    "Barbecue","Nuggets","Grassy Knoll","Mile High","Ranch","Piedmont",
    "Magic City","Space City","BBQ","Peachtree","Glinda",
    # US West
    "Missionary","Cube","Lamar","Cornell","Casino","Vaporware","Dogg",
    "Sanitation","Copper Cactus","Santana","Hendrix","Cobain","Oregon Trail",
    "Coconut Wireless"
)

$JAPAN = @("Shinkansen","Wabi-sabi")

$CANADA = @(
    "The 6","Expo 67","Comfort Zone","Crosby","Bagel Poutine",
    "The Forks","Saddledome","Stanley","Vansterdam","Chinook"
)

$EUROPE = @(
    # UK
    "Biscuits","City","Crumpets","1984","United","Keeper Willie",
    # Germany
    "Berghain","Sausage Party","Wurstchen",
    # Netherlands
    "Stolen Cheese","Stroopwafel","Tulip",
    # France
    "Cite du Vin","Jardin","Seine","La Marseillaise",
    # Switzerland
    "Lindenhof","Alphorn","Altstadt",
    # Sweden
    "Fika","Djurgarden","Ikea","Syndrome",
    # Norway, Finland, Denmark
    "Fjord","Rakfisk","Sauna","Tram","LEGO","Hyggenhagen",
    # Spain, Italy, Austria, Belgium, Ireland
    "Prado","Plaza Mayor","Batllo",
    "Galleria","Duomo","Sicilicious",
    "Hofburg","Couch of Freud",
    "Guildhouse","Funfrites",
    "Grafton","Dullahan",
    # Czech, Poland, Portugal, Iceland, Luxembourg
    "Vltava","Staromak",
    "Curie","Vistula","Motlawa",
    "Bairro",
    "Fuzzy Pony","Reyka",
    "Tax Shelter",
    # Eastern/Southern Europe
    "Noctropolis","No Vampires","Vitoshka","Nevski",
    "Goulash","Danube","Devin Castle","Melania","Tkalciceva",
    "Rakia","Pisanica","Burek","Besa","Fergese",
    "Vardar","Ajvar","Odeon",
    "Digital Bromad","Saeima","Daugava","Neris",
    "Dendrarium","Slava",
    # Russia, Turkey, Georgia, Cyprus
    "Hermitage","Lygos","Ghvino","Blue Lagoon","Amathusia"
)

$REST = @(
    # Asia / Middle East
    "SMRT","Laksa","Marina Bay","Phooey","Victoria","Tianlong",
    "Namsan","Hangang","Perdana",
    "Happy Ending","Wat Pho","Lumphini","Hotdog",
    "Train Street","Red River",
    "Ancol","Pulau Dewata","Indomie","Old Town","Nasi Goreng",
    "Mayanagari","Old Spice","Chole Bhature","Khalifa",
    # Oceania
    "Kings Park","Oval","Yarra","Eshay","Bad Koala","Squidney","Lofty",
    "Port Phillip","Good Koala","Herdsman","Parnell","Hauraki",
    # Latin America
    "Aqueduct","Papers","Rololandia","Cueca","Cuy","Amaru",
    "Mercadao","Pinacoteca","Tango","Yerba Mate","Chipa","Gaucho",
    "Pepian","HODL",
    # Antarctica
    "Station"
)

$AFRICA = @("Lekki","Matatu","District 69","Springbok","Lindfield")

# Last resort only (delete this line and the ISRAEL call below to skip it)
$ISRAEL = @("Jaffa","Yam Park")

function Test-Connected {
    $out = & $cli status 2>$null | Out-String
    return ($out -match '(?m)^Connect state: Connected')
}

function Try-List {
    param([string]$Label, [string[]]$Locations)
    foreach ($loc in $Locations) {
        $suffix = ""
        if ($Protocol) { $suffix = " ($Protocol)" }
        Write-Host "[$Label] Trying $loc$suffix..."

        & $cli disconnect *> $null

        $argString = "connect `"$loc`""
        if ($Protocol) { $argString += " $Protocol" }

        $proc = Start-Process -FilePath $cli -ArgumentList $argString `
            -WindowStyle Hidden -PassThru
        if (-not $proc.WaitForExit($TimeoutSec * 1000)) {
            try { $proc.Kill() } catch {}
        }

        if (Test-Connected) {
            Write-Host "Connected to $loc" -ForegroundColor Green
            (& $cli status 2>$null) | Select-String '^(Connect state|Public IP)'
            exit 0
        }
    }
}

Try-List "US"     $US
Try-List "JAPAN"  $JAPAN
Try-List "CANADA" $CANADA
Try-List "EUROPE" $EUROPE
Try-List "ISRAEL" $ISRAEL
Try-List "REST"   $REST
Try-List "AFRICA" $AFRICA

Write-Host "Nothing connected." -ForegroundColor Red
& $cli disconnect *> $null
exit 1
