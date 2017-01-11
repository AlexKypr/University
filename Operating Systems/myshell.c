//
// Created by Kyprianidis Alexandros-Charalampos on 30/12/2016.
//

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/mman.h> //thn xrhsimopoihsa gia na exw shared memory

int checkLength(char *buffer);//h sunarthsh me thn opoia elegxw to mhkos ths entolhs sto interactive mode
int calcNumChilds(char *buffer);//h sunarthsh me thn opoia upologizw poses entoles uparxoun se mia grammh
void parseBuffer(char *buffer,char **token2);//h sunarthsh me thn opoia diaxwrizw tis entoles mia seiras metaxu tous
int calcNumArgs(int i,char **token2);//h sunarthsh me thn opoia upologizw apo posa tmhmata apoteleitai kathe entolh
void parseToken(int i,char **token2,char **args2);//h sunarthsh me thn opoia diaxwrizw ta tmhmata mia entolhs dhladh to kurio meros ths entolhs kai ta orismata ths
void forkExecute(char **args2,int i,int numChilds,char **token2);//h sunarthsh me thn opoia dhmiourgw paidia gia na ektelestoun oi entoles
void waitProcess(int numChilds);//h sunarthsh me thn opoia anamenw gia ta paidia poy dhmiourghsa

static int *glob_var;//xrhsimopoiw static gt thelw na krataei thn timh ths anamesa stis diafores sunarthseis

int main(int argc, char *argv[]){
    if(argc == 1){ //Welcome to Interactive mode
        char buffer[512]; //Dhmiourgw buffer megethous 512
        int i;
        int numChilds,numArgs = 0;
        for (;;){ //Atermon epanalhpsh gia prosomoiwsh tou shell
            printf("kyprianidis_8012> "); //Emfanizei to onoma xrhsth
            if(checkLength(buffer) == 1){//Kalei thn sunarthsh checkLength.An einai 1 shmainei oti h entolh exei megethos > 512.
                exit(0);//Efoson exei megethos > 512 termatizoume to programm
            }
            if(strlen(buffer) == 0){//Autos o elegxos ginetai gia ama patithei apla to enter dld mia kenh entolh tote ousiastika na phgainei sthn epomenh epanalhpsh kai na paraleipei ta upoloipa
                continue;//phgainei sthn epomenh epanalhpsh
            }
            glob_var = mmap(NULL, sizeof *glob_var, PROT_READ | PROT_WRITE,
                            MAP_SHARED | MAP_ANONYMOUS, -1, 0);//ginetai mia xartografhsh ths eikonikhs mnhmhs tis trexousas diadikasias me skopo na xrhsimopoieitai kai apo ta paidia kai apo thn "mana".Etsi otan tha emfanizetai to quit tha mporw na xrhsimopoiw ws flag to glob_var
            *glob_var = 0;//Arxikopoiw thn glob_var ish me 0
            numChilds = calcNumChilds(buffer);//Kalei thn sunarthsh calcNumChilds pou upologizei poses entoles periexontai ston buffer
            char *token2[numChilds];
            parseBuffer(buffer,token2);//Kalei thn sunarthsh parseBuffer pou xwrizei tis entoles metaxu tous
            for(i = 0;i<numChilds;i++){ //Gia kathe entolh
                numArgs = calcNumArgs(i,token2);//1)upologizei twn parametrwn dld kurio meros kai parametrous
                char *args2[numArgs];
                parseToken(i,token2,args2);//2)Kalei thn sunarthsh parseToken gia na diaxwrisei tis parametrous
                forkExecute(args2,i,numChilds,token2);//3)ektelei thn entolh anathetontas ths se ena paidi
            }
            waitProcess(numChilds);//Perimenei gia ola ta paidia na "epistrepsoun"
        }
    }else if(argc == 2){//Welcome to Batch mode
        int numChilds,i,numArgs = 0;
        char line[514];//evala megalutero megethos gia na mporei na ftasei to mhkos ths entolhs >512
        FILE *file = fopen(argv[1],"r");//Anoigma Arxeiou
        if(file == NULL){//Elegxos sfalmatos sto anoigma arxeiou
            perror("fopen");
            exit(EXIT_FAILURE);
        }
        while(fgets(line, sizeof(line),file)){//Diadikasia anagnwshs tou arxeiou ana grammh
            printf("%s",line);//Ektupwsh grammhs
            if(strlen(line) > 512){//elegxos ama to mhkos ths entolhs einai megaluterh apo 512
                printf("The length of the string is > 512 so we don't accept it\n");
                exit(0);//Sthn periptwsh pou einai to programma termatizei
            }
            if(line[0] == '\n'){//Elegxos ama uparxei kenh grammh sto arxeio opote na thn prosperasei efoson einai exairesh
                continue;
            }
            line[strcspn(line, "\n")] = 0;//Afairei apo tis entoles to \n kathws h fgets prosthetei sto telos \n
            glob_var = mmap(NULL, sizeof *glob_var, PROT_READ | PROT_WRITE,
                            MAP_SHARED | MAP_ANONYMOUS, -1, 0);//ginetai mia xartografhsh ths eikonikhs mnhmhs tis trexousas diadikasias me skopo na xrhsimopoieitai kai apo ta paidia kai apo thn "mana".Etsi otan tha emfanizetai to quit tha mporw na xrhsimopoiw ws flag to glob_var
            *glob_var = 0;//Arxikopoiw thn glob_var ish me 0
            numChilds = calcNumChilds(line);//to parakatw group entolwn akoloythoun thn idia logikh pou perigrafthke sto interactive mode
            char *token2[numChilds];
            parseBuffer(line,token2);
            for(i = 0;i<numChilds;i++){
                numArgs = calcNumArgs(i,token2);
                char *args2[numArgs];
                parseToken(i,token2,args2);
                forkExecute(args2,i,numChilds,token2);
            }
            waitProcess(numChilds);
        }

        fclose(file);//Kleisimo Arxeiou
    }else{
        printf("Something unexpected happened \n");
        exit(0);
    }
    return 0;
}

int checkLength(char *buffer) {//h sunarthsh me thn opoia elegxw to mhkos ths entolhs sto interactive mode
    long int lengthLine;
    if (gets(buffer) != NULL) {//elegxei ama einai kenos o buffer
        lengthLine = strlen(buffer);//ama den einai pairnei to mhkos tou
        if (lengthLine > 512) {//an to megethos tou xepernaei to 512 tote epistrefei 1
            printf("The length of the string is %ld(>512) so we don't accept it\n", lengthLine);
            return 1;
        }
    }
    return 0;//alliws epistrefei 0
}

int calcNumChilds(char *buffer){//h sunarthsh me thn opoia upologizw poses entoles uparxoun se mia grammh
    int numChildstest = 1;//Αrxikopoihsh gia kathe entoli
    for (int i=0; buffer[i]; i++) //anatrexw gia olo to buffer mexri na einai iso me 0 dld na teleiwnei to string
        numChildstest += (buffer[i] == ';');//auxanei o arithmos twn entolwn an to stoixeio tou buffer einai iso me ;
    printf("Number of Childs:%d \n", numChildstest);
    return numChildstest;
}

void parseBuffer(char *buffer,char **token2){//h sunarthsh me thn opoia diaxwrizw tis entoles mia seiras metaxu tous
    int i = 0;
    char *token;
    const char delimiter[2] = ";";
    token = strtok(buffer, delimiter);//H strtok spaei to buffer me vash to delimiter pou exei epilegei.Edw theloume na diaxwrisoume tis entoles gia auto epilegetai to ;
    token2[i] = token;//Swzw tis entoles se allo token alliws tha xathoun
    while(token != NULL){ //parsing procedure
        printf("token[%d] = %s\n", i,token2[i]);
        token = strtok(NULL, delimiter);//omoiws me panw
        i++;
        token2[i] = token;
    }
}



int calcNumArgs(int i,char **token2){//h sunarthsh me thn opoia upologizw apo posa tmhmata apoteleitai kathe entolh
    int numArgs = 1;
    for (int j=0; token2[i][j]; j++)//Anatrexw gia thn i entolh na vrw apo poses parametrous apoteleitai mazi me to kurio meros ths
        numArgs += (token2[i][j] == ' ');
    return numArgs;
}

void parseToken(int i,char **token2,char **args2){//h sunarthsh me thn opoia diaxwrizw ta tmhmata mia entolhs dhladh to kurio meros ths entolhs kai ta orismata ths
    char *args;
    int j = 0;
    const char delimiter2[2] = " ";
    args = strtok(token2[i],delimiter2);//Thelw na spasw to token2[i] dld thn i-osth entolh stis diafores parametrous apo tis opoies apoteleitai
    args2[j] = args;
    while(args != NULL){
        printf("arguments of token[%d] = %s \n", i,args2[j]);
        args = strtok(NULL,delimiter2);//omoiws me panw
        j++;
        args2[j] = args;
    }
}

void forkExecute(char **args2,int i,int numChilds,char **token2){//h sunarthsh me thn opoia dhmiourgw paidia gia na ektelestoun oi entoles
    int pid[numChilds];
    if((pid[i] = fork()) < 0){//Elegxw ama den pragmatopoihthei to fork
        perror("fork");
        exit(1);
    }
    if(pid[i] == 0){//Eimaste sto child process
        if(execvp(args2[0],args2) == -1){//ektelw thn entolh alla ama einai ish me -1 shmainei oti dn ufistatai
            if(strcmp(args2[0],"quit") != 0) {//elegxw ama einai h entolh quit.Ama den einai tote stelnw shma wste na kleisei to programma
                printf("The command %s doesn't exist \n",token2[i]);
                kill(pid[i], SIGTERM);//ctrl+c
            }else{//Ama einai to quit termatizw to paidi kai akoloutheitai diadikasia wste na oloklirwthei h diadikasia twn allwn paidiwn kai meta na termatisei to programma
                *glob_var = 1;//to anathetw iso me 1 me thn morfh flag gia na deixnei oti vrethike quit
                _exit(0);
            }
        }
    }
}


void waitProcess(int numChilds){//h sunarthsh me thn opoia anamenw gia ta paidia poy dhmiourghsa
    int status,pid2;
    while(numChilds > 0){//Elegxw ama o arithmos twn paidiwn einai thetiko gt to meiwnw se kathe epanalhpsh opote otan einai 0 tha exoun gurisei ola
        pid2 = wait(&status);//anamenei thn allagh katastashs tou paidiou dld ton termatismo tou
        printf("Child with PID %d exited with status 0x%x.\n", pid2, status);
        --numChilds;
    }
    if(*glob_var == 1){//Elegxw ama mphke sto quit sto forkExecute an nai termatizw to programma kai tha exoun oloklirwthei oi diadikasies olwn twn paidiwn epeidh epetai tou wait
        printf("We are quiting...\n");
        exit(0);
    }
}