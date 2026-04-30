#include <iostream>
#include <cassert>
#include <cctype>
#include <vector>
using namespace std;

const static vector<char> alfabetoNormal = {'a','b','c','d','e','f','g','h','i','j',
            'k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'
        };

vector<char> getAlfabetoCorrido(const vector<char> &ALF, int clave){
    vector<char> aux;
    for (int i = clave; i < ALF.size(); i++)aux.push_back(ALF[i]);
    for (int i = 0; i < clave; i++)aux.push_back(ALF[i]);
    return aux;
}

vector<int> getPos(const string &palabra){
    vector<int> aux;
    
    for (char c : palabra){
        for (size_t i = 0; i < alfabetoNormal.size(); i++){
            if (alfabetoNormal[i] == c) aux.push_back(i);
        }
    }

    return aux;
}

string cifrar(const vector<int> &palabra, const vector<int> &clave, const vector<vector<char>> &matVigenere){
    string cifrado;
    int valClave = 0;

    for (size_t i = 0; i < palabra.size(); i++){

        cifrado += matVigenere[clave[valClave]][palabra[i]];
        valClave ++;

        if(valClave >= clave.size()) 
            valClave = 0;
    }
    return cifrado;
}

string descifrar(const vector<int> &palabra, const vector<int> &clave, const vector<vector<char>> &matVigenere){
    string descifrado;
    int valClave = 0;

    cout<<palabra.size()<<endl;
        
    for (size_t i = 0; i < palabra.size(); i++){
        int columna = -1;

        for(int j =0; j<matVigenere[0].size();j++){
            if (matVigenere[palabra[i]][0] == matVigenere[clave[valClave]][j]){
                columna = j;
                break;
            }
        }

        descifrado += matVigenere[0][columna];
        valClave ++;

        if(valClave >= clave.size()) 
            valClave = 0;
    }

    return descifrado;
}

int main(int argc,char* argv[]){

    try {

        if (argc < 4) throw std::runtime_error("Error: falta argumento: clave palabra accion");

        if(string(argv[3])!= "0" && string(argv[3])!="1")
            throw std::runtime_error("Error: la accion debe ser 0 (cifrar) ó 1 (decifrar)");

        for (char c : std::string(argv[1])) 
            if (!std::isalpha(static_cast<unsigned char>(c))) 
                throw std::runtime_error("Error: el argumento[1] (clave) debe ser solo letras");

        for (char c : std::string(argv[2])) 
            if (!std::isalpha(static_cast<unsigned char>(c))) 
                throw std::runtime_error("Error: el argumento[2] (palabra) debe ser solo letras");

        vector<vector<char>> matVigenere;
        for (int i=0; i< alfabetoNormal.size(); i++)
            matVigenere.push_back(getAlfabetoCorrido(alfabetoNormal,i));

        if(string(argv[3]) == "0"){
            string menCif = cifrar(getPos(argv[2]),getPos(argv[1]), matVigenere);
            cout<<"el mensaje "<<argv[2]<<" cifrado es: "<<menCif<<endl;
        }else{
            string menDescif = descifrar(getPos(argv[2]),getPos(argv[1]), matVigenere);
            cout<<"el mensaje "<<argv[2]<<" descifrado es: "<<menDescif<<endl;
        }

    } catch (const runtime_error& e) {
        cerr << "Se produjo una excepción: " << e.what() << endl;
    }

    return 0;
}