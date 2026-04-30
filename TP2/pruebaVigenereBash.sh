#!/bin/bash

CLAVE="sol"
ORIGINAL="nublado"

# 1. Cifrar
RESULTADO=$(./programa "$CLAVE" "$ORIGINAL" 0)
echo "Cifrado: $RESULTADO"

# 2. Descifrar usando lo que guardamos en RESULTADO
DESCIFRADO=$(./programa "$CLAVE" "$RESULTADO" 1)
echo "Descifrado: $DESCIFRADO"