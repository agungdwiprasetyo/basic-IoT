#include <wiringPi.h>
#include <softPwm.h>
#include <stdio.h>
#include <dirent.h>
#include <string.h>

/*
pin GPIO di raspi
    pin header      GPIO number
      P1-3               8
      P1-5               9
      P1-7               7
      P1-8              15
      P1-10             16
      P1-11              0
      P1-12              1
      P1-13              2
      P1-15              3
      P1-16              4
      P1-18              5
      P1-19             12
      P1-21             13
      P1-22              6
      P1-23             14
      P1-24             10
      P1-26             11
*/

#define DIRECTORYNAME "/dev/GPIO-pwm"


int main (int argc, char **argv){
  int i;
  char charArray[1000];
  int gpioNumber = 0;
  int pwm = 0;
  DIR *pDIR;
  struct dirent *pDirEnt;
  
  if (wiringPiSetup () == -1)
    return(-1) ;  

  pDIR = opendir(DIRECTORYNAME);
  
  if(pDIR == NULL){
    strcpy(charArray, "mkdir ");
    strcat(charArray, DIRECTORYNAME);
    system(charArray);

    strcpy(charArray, "chmod a+w ");
    strcat(charArray, DIRECTORYNAME);
    system(charArray);
  }
  else{
    closedir(pDIR);
  }
  

  while(1){
    pDIR = opendir(DIRECTORYNAME);
    if(pDIR == NULL){
      printf("opendir() failed !\n");
      return(1);
    }

    pDirEnt = readdir(pDIR);
    while(pDirEnt != NULL){
      if(strlen(pDirEnt->d_name) > 2){
        strcpy(charArray, "rm -f ");
        strcat(charArray, DIRECTORYNAME);
        strcat(charArray, "/");
        strcat(charArray, pDirEnt->d_name);
        system(charArray);
        int iOffset = 0;
        gpioNumber = -1;
        pwm = -1;
        for(i = 0; i < strlen(pDirEnt->d_name); i++){
          charArray[i + 1 - iOffset] = '\0';
          if(pDirEnt->d_name[i]!='-'){
            charArray[i - iOffset] = pDirEnt->d_name[i];
          }
          else{
            charArray[i] = '\0';
            iOffset = i + 1;
            gpioNumber = atoi(charArray);
          }
        }
        pwm = atoi(charArray);
        if(gpioNumber > -1 && gpioNumber < 18 && pwm > -1 && pwm < 201){
          softPwmCreate(gpioNumber, pwm, 200);
          softPwmWrite(gpioNumber, pwm);
        }
      }
      pDirEnt = readdir(pDIR);
    }
    closedir(pDIR);
    sleep(1);
  }
  return 0 ;
}
