#!/bin/bash

# Implementación simple de SHA-256 en bash.
#
# Referencia:
# RFC 6234 https://tools.ietf.org/html/rfc6234

# Se leen los bloques por entrada estándar y se aplica el algoritmo
# para cada uno. Finalmente se retorna el resultado final.
# Esta implemetación solamente puede procesar mensajes con tamaños múltiplo de
# 8 bits. (La implementación completa permite trabajar con bits directamente)

# Constantes y variables globales:

# Para rellenar la palabra incompleta al final del bloque.
declare -a RELLENO=( "80000000" "8000000" "800000" "80000" "8000" "800" "80"
                     "8" "" )

# Digesto. Es un arreglo de 8 palabras, inicializado con las constantes
# obtenidas de los primeros 32 bits de las partes fraccionarias de las
# raíces cuadradas de los primeros 8 números primos.
declare -a H=(
  $((0x6a09e667)) $((0xbb67ae85)) $((0x3c6ef372)) $((0xa54ff53a))
  $((0x510e527f)) $((0x9b05688c)) $((0x1f83d9ab)) $((0x5be0cd19))
)

# Constante. Es un arreglo de 64 palabras, inicializado con las constantes
# obtenidas de los primeros 32 bits de las partes fraccionarias de las
# raíces cubicas de los primeros 64 números primos.
declare -a K=(
  $((0x428a2f98)) $((0x71374491)) $((0xb5c0fbcf)) $((0xe9b5dba5))
  $((0x3956c25b)) $((0x59f111f1)) $((0x923f82a4)) $((0xab1c5ed5))
  $((0xd807aa98)) $((0x12835b01)) $((0x243185be)) $((0x550c7dc3))
  $((0x72be5d74)) $((0x80deb1fe)) $((0x9bdc06a7)) $((0xc19bf174))
  $((0xe49b69c1)) $((0xefbe4786)) $((0x0fc19dc6)) $((0x240ca1cc))
  $((0x2de92c6f)) $((0x4a7484aa)) $((0x5cb0a9dc)) $((0x76f988da))
  $((0x983e5152)) $((0xa831c66d)) $((0xb00327c8)) $((0xbf597fc7))
  $((0xc6e00bf3)) $((0xd5a79147)) $((0x06ca6351)) $((0x14292967))
  $((0x27b70a85)) $((0x2e1b2138)) $((0x4d2c6dfc)) $((0x53380d13))
  $((0x650a7354)) $((0x766a0abb)) $((0x81c2c92e)) $((0x92722c85))
  $((0xa2bfe8a1)) $((0xa81a664b)) $((0xc24b8b70)) $((0xc76c51a3))
  $((0xd192e819)) $((0xd6990624)) $((0xf40e3585)) $((0x106aa070))
  $((0x19a4c116)) $((0x1e376c08)) $((0x2748774c)) $((0x34b0bcb5))
  $((0x391c0cb3)) $((0x4ed8aa4a)) $((0x5b9cca4f)) $((0x682e6ff3))
  $((0x748f82ee)) $((0x78a5636f)) $((0x84c87814)) $((0x8cc70208))
  $((0x90befffa)) $((0xa4506ceb)) $((0xbef9a3f7)) $((0xc67178f2))
)

# Extensor de mensaje. Es un arreglo de 64 palabras. Las primeras 16
# conforman el bloque del mensaje.
declare -a W

# Longitud del mensaje (en bits).
declare -i longitud=0

# Utilizada por leerBloque para entrar una vez más si hace falta.
declare -i bloque_extra=0

# Utilizada por leerBloque detectar que no hay más datos en la entrada
declare -i fin_de_entrada=0

# Operaciones de entrada y salida:

# Toma una serie de números enteros de 32 bits y los mustra por salida estándar.
mostrarHexa () {
  while [ $# -gt 0 ]
  do
    printf "%8.8x" "$1"
    shift
  done
  printf "\n"
}

# Leer un bloque de la entrada, y guardarlo en el buffer principal.
# Cuando se lee un nuevo bloque se inicializa el buffer principal $W.
# La longitud del mensaje en bits $longitud y el buffer se llevan desde
# esta función. Al arrancar la longitud debe inicializarse en 0.
# Si la entrada se corta, se genera el relleno. El bloque tiene que entrar
# como palabras de 32 bits escritas en hexadecimal
# (procesado por xxd -ps -c 4) retorna 0 cuando se procesa un bloque, y 1
# cuando el bloque de relleno ya fue generado. En el caso extremo en que el
# código de relleno no entre en el bloque se utiliza una llamada extra para
# generar otro bloque y completar el relleno. La variable $bloque_extra se usa
# para eso.
# La variable fin_de_entrada se utiliza para indicar que ya se generó el
# relleno y el siguiente llamado debe cortar el bucle.

leerBloque () {
  declare -i i=0
  declare -i relleno=0
  if [ $bloque_extra -eq 1 ]
  then
    W=( 0 0 0 0 0 0 0 0 0 0 0 0 0 0 )
    bloque_extra=0
  elif [ $fin_de_entrada -eq 1 ]
  then
    # Terminamos
    return 1
  else
    W=()
    while [ $i -lt 16 ] && read w
    do
      if [ ${#w} -gt 8 ] || [ $relleno -eq 1 ]
      then
        # Algo anduvo muy mal. Vinieron más de 8 caracteres en una línea,
        # o vino una línea incompleta y después más datos.
        echo "Error de entrada" >&2
        exit 1
      else
        # Si hace falta, se agrega el relleno para completar la palabra.
        W+=( $(("0x$w${RELLENO[${#w}]}")) )
        longitud+=${#w}*4
        i+=1
        # Se avisa que ya se emitió la palabra con relleno.
        [ ${#w} -lt 8 ] && relleno=1
      fi
    done

    if [ $i -eq 16 ] && [ $relleno -eq 0 ]
    then
      # Se procesó un bloque completo, pero podría haber más entrada.
      return 0
    elif [ $relleno -eq 0 ]
    then
      # Aquí se entra en el caso en que no se completó el bloque,
      # pero la longitud del mensaje es múltiplo de 32 bits.
      # Hay que agregar la palabra de relleno.
      # También se entra cuando la entrada está vacía,

      W+=( "0x${RELLENO[0]}" )
      i+=1
    fi
    # Ahora el inicio del relleno ya está emitido.
    # Completar con 0s hasta llegar a las 14 palabras.
    while [ $i -lt 14 ]
    do
      W+=( 0 )
      i+=1
    done
    # Si ya había más de 14 palabras en el bloque, entonces no entra 
    # la palabra con la longitud, hay que hacer otro bloque entero más.
    if [ $i -gt 14 ]
    then
      bloque_extra=1
      # Completar con 0s el bloque actual.
      while [ $i -lt 16 ]
      do
        W+=( 0 )
        i+=1
      done
      return 0
    fi
  fi
  # A esta altura solo puede quedar un bloque de longitud 14, que será el
  # último de la entrada y solo le falta la longitud en bits codificada
  # en las últimas dos palabras, y terminamos.
  W+=( $(($longitud/(1<<32))) $(($longitud%(1<<32))) )
  fin_de_entrada=1
  return 0
}

# Operaciones auxiliares:

# Las operaciones lógicas de bits AND (&), OR (|), XOR (^), NOT (~) y
# desplazamientos a derecha (>>) e izquierda (<<) ya están implementadas en
# bash, pero las rotaciones y la suma en 32 bits hay que implementarlas.

# Suma módulo 2^32. Todos los parámetros son sumados módulo 2^32.
suma () {
  declare -i s=0
  while [ $# -gt 0 ]
  do
    s=$((($s+$1)%(1<<32)))
    shift
  done
  echo "$s"
}

# Rotación a derecha (primero la cantidad de bits, después el entero).
# Limitado a 32 bits
rotr () {
  echo "$(( ( ($2>>$1) | ($2<<(32-$1)) ) & 0xFFFFFFFF ))"
}

# Rotación a izquierda (primero la cantidad de bits, después el entero).
# Limitado a 32 bits
rotl () {
  echo "$(( ( ($2<<$1) | ($2>>(32-$1)) ) & 0xFFFFFFFF ))"
}

# Funciones de SHA-256

# Intercambio:
# El primer número es usado como máscara para intercambiar los bits de los
# otros dos números: donde la máscara es 1 van los bits del segundo número,
# y donde la máscara es 0 van los bits del 3er número.
# CH( A , B , C ) = ( A AND B ) XOR ( (NOT A) AND C )
CH () {
  echo "$(( ( $1 & $2 ) ^ ( (~$1) & $3 ) ))"
}

# Mayoría:
# Si 2 o 3 bits están en 1, entonces el resultado es 1.
# Si 1 o 0 bits están en 1, entonces el resultado es 0.
MAJ () {
  echo "$(( ( $1 & $2 ) ^ ( $1 & $3 ) ^ ( $2 & $3 ) ))"
}

# Rotaciones compuestas:

BSIG0 () {
  echo "$(( $(rotr 2 $1) ^ $(rotr 13 $1) ^ $(rotr 22 $1) ))"
}

BSIG1 () {
  echo "$(( $(rotr 6 $1) ^ $(rotr 11 $1) ^ $(rotr 25 $1) ))"
}

SSIG0 () {
  echo "$(( $(rotr 7 $1) ^ $(rotr 18 $1) ^ ( $1 >> 3 ) ))"
}

SSIG1 () {
  echo "$(( $(rotr 17 $1) ^ $(rotr 19 $1) ^ ( $1 >> 10 ) ))"
}


# Rutina principal. Casos de prueba y ejecución principal.

# Probar la función leerbloque a bajo nivel (recibir los caracteres en
# codificados en palabras hexadecimales por entrada estándar).
if [ "$1" == "-B" ]
then
  while leerBloque
  do
    mostrarHexa ${W[*]}
  done
  exit 0
fi

# Probar la función leerBloque en alto nivel (recibir los caracteres en binario
# por la entrada estándar).
if [ "$1" == "-b" ]
then
  xxd -ps -c4 | (
    while leerBloque
    do
      mostrarHexa ${W[*]}
    done
  )
  exit 0
fi

# Calculo de sha256.

xxd -ps -c4 | (
  while leerBloque
  do
    # El primer paso es armar el extensor completo. Los primeros 16 elementos
    # ya están puestos por la función leerBloque.
    declare -i t=16 ;
    while [ $t -lt 64 ]
    do
      W[$t]=$(suma $(SSIG1 ${W[$t-2]})  ${W[$t-7]} \
                   $(SSIG0 ${W[$t-15]}) ${W[$t-16]})
      t+=1
    done

    # Inicializar las variables de trabajo:
    declare -i a=${H[0]}
    declare -i b=${H[1]}
    declare -i c=${H[2]}
    declare -i d=${H[3]}
    declare -i e=${H[4]}
    declare -i f=${H[5]}
    declare -i g=${H[6]}
    declare -i h=${H[7]}
    declare -i T1
    declare -i T2

    # Rutina principal de cálculo.
    # Es una rotación.
    t=0
    while [ $t -lt 64 ]
    do
      T1=$(suma $h $(BSIG1 $e) $(CH $e $f $g) ${K[$t]} ${W[$t]})
      T2=$(suma $(BSIG0 $a) $(MAJ $a $b $c))
      h=$g
      g=$f
      f=$e
      e=$(suma $d $T1)
      d=$c
      c=$b
      b=$a
      a=$(suma $T1 $T2)

      t+=1
    done

    # Cálculo del valor intermedio del digesto.
    H[0]=$(suma $a ${H[0]})
    H[1]=$(suma $b ${H[1]})
    H[2]=$(suma $c ${H[2]})
    H[3]=$(suma $d ${H[3]})
    H[4]=$(suma $e ${H[4]})
    H[5]=$(suma $f ${H[5]})
    H[6]=$(suma $g ${H[6]})
    H[7]=$(suma $h ${H[7]})
  done
  # Mostrar el resultado final.
  mostrarHexa ${H[*]}
)
