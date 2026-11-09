# Windscribe-location-tester
Test all windscribe pro servers to eventually connect

Linux:
./ws-location-linux.sh

Windows, powershell:
powershell -ExecutionPolicy Bypass -File .\ws-cycle.ps1


Flags;
Windows:
powershell -ExecutionPolicy Bypass -File .\ws-cycle.ps1 -Protocol stealth

Linux:
./ws-location-linux.sh wireguard
./ws-location-linux.sh udp:443
