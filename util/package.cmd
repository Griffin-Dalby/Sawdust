@echo off
set /p version=Package version: 
echo Package for Wally...
wally package -v --output build/sawdust-v%version%

echo Build for Release...
rojo build -v --output build/sawdust-v%version%.rbxl
rojo build -v --output build/sawdust-v%version%.rbxmx