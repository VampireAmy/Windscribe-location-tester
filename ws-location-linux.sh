#!/usr/bin/env bash
# Usage: ./ws-cycle.sh [protocol[:port]]
# Omit protocol to use your saved default.

PROTO="${1:-}"
TIMEOUT=30

US=(
  # US East
  "Big Apple" "Bles Park" "Cloud City" "Situation" "Sunny" "Bulls" "Green Mill"
  "Belt Buckle" "Big Guava" "Moonshine Run" "Coney Dog" "Hawkins" "Snow"
  "King James" "Cub" "Empire" "Insomnia" "Bill" "Fresh Prince" "Wrigley"
  "Florida Man" "Cuban Sandwich" "Inside Job" "Vice" "MIT" "Harvard" "Trade War"
  # US Central
  "Barbecue" "Nuggets" "Grassy Knoll" "Mile High" "Ranch" "Piedmont"
  "Magic City" "Space City" "BBQ" "Peachtree" "Glinda"
  # US West
  "Missionary" "Cube" "Lamar" "Cornell" "Casino" "Vaporware" "Dogg"
  "Sanitation" "Copper Cactus" "Santana" "Hendrix" "Cobain" "Oregon Trail"
  "Coconut Wireless"
)

JAPAN=("Shinkansen" "Wabi-sabi")

CANADA=(
  "The 6" "Expo 67" "Comfort Zone" "Crosby" "Bagel Poutine"
  "The Forks" "Saddledome" "Stanley" "Vansterdam" "Chinook"
)

EUROPE=(
  # UK
  "Biscuits" "City" "Crumpets" "1984" "United" "Keeper Willie"
  # Germany
  "Berghain" "Sausage Party" "Wurstchen"
  # Netherlands
  "Stolen Cheese" "Stroopwafel" "Tulip"
  # France
  "Cite du Vin" "Jardin" "Seine" "La Marseillaise"
  # Switzerland
  "Lindenhof" "Alphorn" "Altstadt"
  # Sweden
  "Fika" "Djurgarden" "Ikea" "Syndrome"
  # Norway, Finland, Denmark
  "Fjord" "Rakfisk" "Sauna" "Tram" "LEGO" "Hyggenhagen"
  # Spain, Italy, Austria, Belgium, Ireland
  "Prado" "Plaza Mayor" "Batllo"
  "Galleria" "Duomo" "Sicilicious"
  "Hofburg" "Couch of Freud"
  "Guildhouse" "Funfrites"
  "Grafton" "Dullahan"
  # Czech, Poland, Portugal, Iceland, Luxembourg
  "Vltava" "Staromak"
  "Curie" "Vistula" "Motlawa"
  "Bairro"
  "Fuzzy Pony" "Reyka"
  "Tax Shelter"
  # Eastern/Southern Europe
  "Noctropolis" "No Vampires" "Vitoshka" "Nevski"
  "Goulash" "Danube" "Devin Castle" "Melania" "Tkalciceva"
  "Rakia" "Pisanica" "Burek" "Besa" "Fergese"
  "Vardar" "Ajvar" "Odeon"
  "Digital Bromad" "Saeima" "Daugava" "Neris"
  "Dendrarium" "Slava"
  # Russia, Turkey, Georgia, Cyprus
  "Hermitage" "Lygos" "Ghvino" "Blue Lagoon" "Amathusia"
)

REST=(
  # Asia / Middle East
  "SMRT" "Laksa" "Marina Bay" "Phooey" "Victoria" "Tianlong"
  "Namsan" "Hangang" "Perdana"
  "Happy Ending" "Wat Pho" "Lumphini" "Hotdog"
  "Train Street" "Red River"
  "Ancol" "Pulau Dewata" "Indomie" "Old Town" "Nasi Goreng"
  "Mayanagari" "Old Spice" "Chole Bhature" "Khalifa"
  # Oceania
  "Kings Park" "Oval" "Yarra" "Eshay" "Bad Koala" "Squidney" "Lofty"
  "Port Phillip" "Good Koala" "Herdsman" "Parnell" "Hauraki"
  # Latin America
  "Aqueduct" "Papers" "Rololandia" "Cueca" "Cuy" "Amaru"
  "Mercadao" "Pinacoteca" "Tango" "Yerba Mate" "Chipa" "Gaucho"
  "Pepian" "HODL"
  # Antarctica
  "Station"
)

AFRICA=("Lekki" "Matatu" "District 69" "Springbok" "Lindfield")

# Last resort only
ISRAEL=("Jaffa" "Yam Park")

is_connected() {
  windscribe-cli status 2>/dev/null | grep -q '^Connect state: Connected'
}

try_list() {
  local label="$1"; shift
  for LOC in "$@"; do
    echo "[$label] Trying $LOC ${PROTO:+($PROTO)}..."
    windscribe-cli disconnect >/dev/null 2>&1
    timeout "$TIMEOUT" windscribe-cli connect "$LOC" $PROTO >/dev/null 2>&1
    if is_connected; then
      echo "Connected to $LOC"
      windscribe-cli status 2>/dev/null | grep -E '^(Connect state|Public IP)'
      exit 0
    fi
  done
}

try_list US     "${US[@]}"
try_list JAPAN  "${JAPAN[@]}"
try_list CANADA "${CANADA[@]}"
try_list EUROPE "${EUROPE[@]}"
try_list ISRAEL "${ISRAEL[@]}"
try_list REST   "${REST[@]}"
try_list AFRICA "${AFRICA[@]}"

echo "Nothing connected."
windscribe-cli disconnect >/dev/null 2>&1
exit 1
