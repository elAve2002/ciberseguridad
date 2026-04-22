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

int main(int argc,char* argv[]){

    try {
        if (argc < 2) throw runtime_error("Error: falta argumento");

        string arg = argv[1];
        for (char c : arg) if (isdigit(c)) throw runtime_error("Error: el argumento no es una letra");

        vector<char> alfabetoNormal = {'a','b','c','d','e','f','g','h','i','j',
            'k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'
        };

        vector<vector<char>> matVigenere;
        for (int i=0; i< alfabetoNormal.size(); i++)
            matVigenere.push_back(getAlfabetoCorrido(alfabetoNormal,i));

        for (size_t i = 0; i < matVigenere.size(); i++) {
            for (size_t j = 0; j < matVigenere[i].size(); j++) {
                cout << matVigenere[i][j] << " ";
            }
            cout << endl;
        }

    } catch (const runtime_error& e) {
        cerr << "Se produjo una excepción: " << e.what() << endl;
    }

    return 0;
}