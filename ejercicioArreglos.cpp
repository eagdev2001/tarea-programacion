#include <iostream>
#include <vector>
#include <cstdlib>

int main () {
    int opcionMenu;

    std::cout << "Menu para seleccionar el tipo de ejercicio a realizar" << std::endl;
    std::cout << "1.Suma de los elementos" << std::endl;    
    std::cout << "2.Promedio de los elementos" << std::endl;
    std::cout << "3.Elemento mayor y menor del arreglo" << std::endl;
    std::cout << "4.Conteo de numeros pares en el arreglo" << std::endl;
    std::cout << "5.Busqueda de elementos en un arreglo" << std::endl;
    std::cout << "6.Salir del programa" << std::endl;
    while (opcionMenu < 1 || opcionMenu > 6) {
        std::cout << "Puede ingresar el numero de la opcion" << std::endl;
        std::cin >> opcionMenu;
        switch (opcionMenu)
        {
        case 1: {
        
            std::vector<int> arregloSuma(5);
            std::cout << "Ingrese los 5 numeros para el arreglo" << std::endl;
            std::cin >> arregloSuma[0] >> arregloSuma[1] >> arregloSuma[2] >> arregloSuma[3] >> arregloSuma[4];
            int sumaTotal = arregloSuma[0] + arregloSuma[1] + arregloSuma[2] + arregloSuma[3] + arregloSuma[4];
            std::cout << "La suma total es: " << sumaTotal << std::endl;
            break;
        }
        case 2: {
            std::vector<int> arregloPromedios(8);
            std::cout << "Ingrese los 8 numeros para el arreglo" << std::endl;
            std::cin >> arregloPromedios[0] >> arregloPromedios[1] >> arregloPromedios[2] >> arregloPromedios[3] >> arregloPromedios[4] >> arregloPromedios[5] >> arregloPromedios[6] >> arregloPromedios[7];
            int promedioTotal = (arregloPromedios[0] + arregloPromedios[1] + arregloPromedios[2] + arregloPromedios[3] + arregloPromedios[4] + arregloPromedios[5] + arregloPromedios[6] + arregloPromedios[7]) / 8;
            std::cout << "El promedio total es: " << promedioTotal << std::endl;
            break;
        }
        default:
            std::cout << "Opcion no valida" << std::endl;
            continue;
        }
        return 0;
    }
    
}
