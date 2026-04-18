#!/bin/bash

if [ -e "programa" ]; then
    echo "Borrando ejecutable anterior..."
    rm -f programa
fi

echo "Compilando CesarAlgoritmo.cpp usando Docker..."
# Agregamos la bandera --user para que el archivo se cree a nombre de tu usuario 'natgri'
docker run --rm --user "$(id -u):$(id -g)" -v "$(pwd):/src" -w /src josem17/tlp:latest g++ CesarAlgoritmo.cpp -o programa

./programa "$@"

echo ""
echo "Proceso finalizado."