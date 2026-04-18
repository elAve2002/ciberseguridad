//docker run -it --rm -v $(pwd):/src josem17/tlp:latest bash
#include <iostream>
#include <cassert>
#include <cctype>
#include <vector>
using namespace std;

//lo ideal es usar filas (queue) pero no se puede acceder por indices, lo hace mas complejo el codigo
vector<char> getAlfabetoCorrido(const vector<char> &ALF, int clave){
    vector<char> aux;
    for (int i = clave; i < ALF.size(); i++)aux.push_back(ALF[i]);
    for (int i = 0; i < clave; i++)aux.push_back(ALF[i]);
    return aux;
}

int charEnVector(vector<char> &ALF, char c){
    int pos = -1;
    for (int i = 0; i < ALF.size(); i++)
        if (ALF[i] == c){
            pos=i;
            break;
        }
    if (pos != -1)
        return pos;
    else
        throw runtime_error ("ERROR! CHAR NO EN EL ALFABETO");
}

// es innecesario, lo hago en el mismo cifrar
// vector<int> indices(vector<char> &ALF, string palabra){
//     vector<int> aux;
//     for(char c: palabra) aux.push_back(charEnVector(ALF,c));
//     return aux;
// }

string cifrar (vector<char> &ALF_NORMAL, vector<char> &ALF_CIF, string palabra){
    for(int i=0; i<palabra.size(); i++)
        palabra[i] = ALF_CIF[charEnVector(ALF_NORMAL, palabra[i])];
    return palabra;
}

string descifrar (vector<char> &ALF_NORMAL, vector<char> &ALF_CIF, string palabra){
    return cifrar(ALF_CIF, ALF_NORMAL, palabra);
}


int main(int argc, char* argv[]) {

    try {
        if (argc < 2) throw runtime_error("Error: falta argumento");

        string arg = argv[1];
        for (char c : arg) if (!isdigit(c)) throw runtime_error("Error: el argumento no es un número");

        vector<char> alfabetoNormal = {'a','b','c','d','e','f','g','h','i','j',
            'k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'
        };

        int clave = stoi(arg) % alfabetoNormal.size();  //lo normalizo por si se de una clave que sea mayor al tamaño del alfabeto

        vector<char> alfabetoCifrado = getAlfabetoCorrido(alfabetoNormal,clave);

        cout<<"mensaje cifrado:"<<endl;

        if (argc > 2)
            for (int i = 2; i < argc; i++)
                cout<<descifrar(alfabetoNormal,alfabetoCifrado,argv[i])<<" ";
        cout<<endl;
        
    } catch (const runtime_error& e) {
        cerr << "Se produjo una excepción: " << e.what() << endl;
    }

    return 0;
}
