#include <iostream>
#include <winsock2.h>
#include <windows.h>
#include <ctime>

using namespace std;


class Client{
public:
    WSADATA WSAData;
    SOCKET server;
    SOCKADDR_IN addr;
    char buffer[1024]=" ";
    bool regresar=false;

    Client(int puerto){
       cout<<"Conectando al servidor..."<<endl<<endl;

        WSAStartup(MAKEWORD(2,0), &WSAData);
        server = socket(AF_INET, SOCK_STREAM, 0);
        addr.sin_addr.s_addr = inet_addr("192.168.1.106 ");
        addr.sin_family = AF_INET;
        addr.sin_port = htons(puerto);
        if(puerto!= 5000){
            cout<<"Error, solo se permite el puerto 5000."<<endl;
             exit(0);

        }
        if(connect(server, (SOCKADDR *)&addr, sizeof(addr))==SOCKET_ERROR)
        {
            cout<<"Error, no se encontro servidor con ese puerto."<<endl;
            system("pause");
             exit(0);
        }else{
            cout << "Conectado al Servidor!" << endl;
            system("pause");
            system("cls");
        }
    }

    void Enviar(){
        char aux[7]="volver";
        cout<<"Escribe el mensaje a enviar: ";
        fflush(stdin);
        gets(this->buffer);
        send(server, buffer, sizeof(buffer), 0);
        if(strcmp(buffer,aux)==0){
            regresar=true;
        }
        cout << "Mensaje enviado!" << endl;

    }


    void incativo(){
    send(server,"volver", sizeof(buffer), 0);
    }

    void Recibir(){
    recv(server, buffer, sizeof(buffer), 0);
    cout << "Resultado: " << buffer << endl;
    }

    void Punto2(){
    char auxChar[1024]=" ";
    int i=0;
        for(i=0;i<strlen(auxChar);i++){
            if(auxChar[i] == ' ')
                {
                recv(server, auxChar, sizeof(auxChar), 0);
                cout<< auxChar << endl;
                i=0;
            }
        }

    }

     void enviarAutomaticamente (int opcion){
        if(opcion==0){
            send(server, "0", sizeof(buffer), 0);
        }

        if(opcion==1){
            send(server, "1", sizeof(buffer), 0);
        }
        if(opcion==2){
            send(server, "2", sizeof(buffer), 0);

        }
        if(opcion==4){
            send(server, "4", sizeof(buffer), 0);

        }
     }

     void CerrarSocket(){
       closesocket(server);
       WSACleanup();
       cout << "Socket cerrado." << endl << endl;
    }


    void SinRetorno(){
    recv(server, buffer, sizeof(buffer), 0);
    }


};

int main()
{
    bool regresar=false;
    int opcion=0;
    int puerto=0;
    cout<<"Por favor ingrese el numero de puerto:"<<endl;
    cin>>puerto;
    Client *Cliente = new Client(puerto);

    clock_t t;
    t=clock();
    t=clock()-t;
    while (regresar == false){

            t=clock()-t;
                if(t/CLOCKS_PER_SEC>=180){

                    cout<<"---- Desconectado por inactividad. Superaste los 3 minutos. ----"<<endl;
                    regresar=true;
                    Cliente->regresar=false;

                    Cliente->SinRetorno();
                    }

        cout << endl;
        cout<<  "######################################################"<<endl;
        cout << "####\t ----------BIENVENIDO AL MENU----------   ####" <<endl;
        cout << "####\t1 .- Calcular                             ####" <<endl;
        cout << "####\t2 .- Ver Registros De Actividades         ####" <<endl;
        cout << "####\t0 .- Cerrar Sesion                        ####" <<endl;
         cout<< "######################################################"<<endl;
        cout << "\t Digite su opcion:";
        cin >> opcion;

        switch(opcion){
        case 1:
            Cliente->enviarAutomaticamente(opcion);
            system("cls");
            cout<<"Ingrese el calculo a resolver o escriba 'volver' para regresar al menu.\n"<<endl;
                Cliente->Enviar();
                t=clock()-t;
                if(t/CLOCKS_PER_SEC>=180){

                    cout<<"---- Desconectado por inactividad. Superaste los 3 minutos. ----"<<endl;
                    regresar=true;
                    Cliente->regresar=false;

                    Cliente->SinRetorno();
                    }else{
                    Cliente->Recibir();
                    }

                memset(Cliente->buffer,0,sizeof(Cliente->buffer));
                Cliente->regresar=true;
        break;
        case 2:
                system("cls");
                Cliente->enviarAutomaticamente(opcion);
                cout<<"El registro es:"<<endl;
                Cliente->Punto2();
                break;
            case 0:
                Cliente->enviarAutomaticamente(opcion);
                cout<< "Usted se desconecto.Hasta la proxima."<< endl;
                regresar=true;
                break;

            default:
                cout << "Error, esa opcion no existe"<< endl;
        }


    }//WHILE
    if(regresar==true){
        Cliente->enviarAutomaticamente(4);
    }

    if(t/CLOCKS_PER_SEC>=180){

        cout<<"---- Desconectado por inactividad. Superaste los 3 minutos. ----"<<endl;
        Cliente->enviarAutomaticamente(4);
        return 0;
    }

}
