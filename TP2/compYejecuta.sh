#!/bin/bash

if [ -e "programa" ]; then
    rm -f programa
fi

docker run --rm --user "$(id -u):$(id -g)" -v "$(pwd):/src" -w /src josem17/tlp:latest g++ VigenereAlgoritmo.cpp -o programa

./programa "$@"

echo ""
echo "Proceso finalizado."