//Program ngecek status GPIO

#include <wiringPi.h>
#include <softPwm.h>
#include <stdio.h>

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


static void usage(){
  printf("Program reads status of GPIOs.\n");
  printf("Examples of usage:\n");
  printf("Test GPIO number 5: ./GPIO-status 5\n");
}


int main (int argc, char **argv){
  int i;
  int gpioNumber = 0;

  if(argc < 2){
    usage();
    return(0);
  }
  
  if (wiringPiSetup () == -1)
    return(-1) ;

  gpioNumber = atoi(argv[1]); // set GPIO yg aktif
  
  if(gpioNumber < 0 || gpioNumber > 17){
    printf("Invalid GPIO number %d! Must be between 0 and 17!\n", gpioNumber);;
    return(0);
  }
  
  pinMode (gpioNumber, INPUT);
  pullUpDnControl (gpioNumber, PUD_OFF);

  if(digitalRead(gpioNumber) == 1){
    printf("Switch at GPIO %d is OPEN\n", gpioNumber);
    return(1);
  }
  else{
    printf("Switch at GPIO %d is CLOSED\n", gpioNumber);
    return(2);
  }

  return 0 ;
}
