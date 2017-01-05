#! /usr/bin/perl

# Program dalam bahasa Perl untuk mengendalikan komponen elektronik seperti lampu LED, servo, motor DC, dan kamera yang terhubung pada Raspberry Pi
# Untuk menggunakan pin GPIO, instal header wiringPi (dalam folder wiringPi) pada library C:
# $ cd wiringPi
# $ ./build
# Jalankan program ini HANYA pada perangkat Raspberry Pi, dengan mengetikkan ./start-raspberry.pl pada terminal

use strict;
use LWP::UserAgent;
use HTTP::Request::Common;
use Getopt::Long;
use File::Basename;
use LWP::Simple;
use Time::HiRes qw(usleep nanosleep);

$|=1 ;

my $password = "password";

# API key buat webserver
my $encryptJWT="c03gs3k4l1";
my $i = 0;
my $charAsal = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-";

if(length($password) < 8){
  print "Password '" . $password . "'too short (min. 8 characters)";
}
if(length($password) > 30){
  print "Password '" . $password . "'too long (max. 30 characters)";
}

if( !($password eq "")){
  for($i = 0; $i < length($password); $i++){
    if(index($charAsal, substr($password, $i, 1)) < 0){
      print("Invalid character in password!");
      exit(1);
    }
  }
}
else{
  print("Password not set!");
  exit(1);
}

my $encode_string = "";
my $char_pos = 0;
for($i = 0; $i < length($password); $i++){
  $char_pos = index($encryptJWT, substr($password, $i, 1));
  $encode_string = $encode_string . $char_pos . "-";
}
$password = $encode_string;

print "passwd=" . $password . "\n";

my $LEDGreenAktif = 0;
my $LEDYellowAktif = 0;
my $LEDRedAktif = 0;
my $LEDWhiteAktif = 0;
my $arahMotor = 0;
my $pwmMotor = 0;
my $servo1Aktif = 0;
my $servo2Aktif = 0;
my $saklar1Aktif = 0;
my $saklar2Aktif = 0;
my $saklarKameraAktif = -1;

my $LEDGreen = $LEDGreenAktif;
my $LEDYellow = $LEDYellowAktif;
my $LEDRed = $LEDRedAktif;
my $LEDWhite = $LEDWhiteAktif;
my $motor_direction = $arahMotor;
my $motor_pwm = $pwmMotor;
my $servo_1 = $servo1Aktif;
my $servo_2 = $servo2Aktif;
my $switch_1 = $saklar1Aktif;
my $switch_2 = $saklar2Aktif;
my $make_snapshot = $saklarKameraAktif;

my $kameraStat = 1;

my $scriptResponse="";
my $temp = 0;
my $char_temp = "";

# set variabel penampung sementara
my $LEDGreenTmp = -1000;
my $LEDYellowTmp = -1000;
my $LEDRedTmp = -1000;
my $LEDWhiteTmp = -1000;
my $arahMotorTmp = -1000;
my $pwmMotorTmp = -1000;
my $servo1Tmp = -1000;
my $servo2Tmp = -1000;
my $saklarKameraTmp = 0;
my $servo_1_duration = 2;
my $servo1DurationStart = 0;
my $servo_2_duration = 2;
my $servo_2_duration_start = 0;
my $last_call = 0;
my $do_reboot = 0;
my $snapshot_file = "foto.jpg";
my $upload_command = "";

my $URL = 'http://agungdp.agri.web.id:3456/server.pl?passwd=' . $password ;

#restart GPIO-pwm
print "Stopping GPIO-pwm\n";
system("killall GPIO-pwm");
sleep(2);

if($LEDRedAktif > -1){
  $kameraStat = 0;
}
if($LEDGreenAktif > -1){
  $kameraStat = 0;
}
if($LEDYellowAktif > -1){
  $kameraStat = 0;
}
if($LEDWhiteAktif > -1){
  $kameraStat = 0;
}
if($servo1Aktif > -1){
  $kameraStat = 0;
}
if($servo2Aktif > -1){
  $kameraStat = 0;
}
if($pwmMotor > -1){
  $kameraStat = 0;
}
if($arahMotor > -1){
  $kameraStat = 0;
}

if($kameraStat == 0){
  print "Restarting GPIO-pwm\n";
  system("nice -n 0 ./GPIO-pwm&");
  sleep(5);
  print "Initializing peripherals\n";
}

#inisialisasi GPIO
if($LEDGreenAktif > -1){
  system("> /dev/GPIO-pwm/12-0"); # Green LED
}
if($LEDYellowAktif > -1){
  system("> /dev/GPIO-pwm/13-0"); # Yellow LED
}
if($LEDRedAktif > -1){
  system("> /dev/GPIO-pwm/14-0"); # Red LED
}
if($LEDWhiteAktif > -1){
  system("> /dev/GPIO-pwm/0-0"); # White LED
}
if($pwmMotor > -1){
  system("> /dev/GPIO-pwm/2-0"); # PWM H bridge
}
if($arahMotor > -1){
  system("> /dev/GPIO-pwm/3-0"); # Direction H bridge
}
if($servo1Aktif > -1){
  system("> /dev/GPIO-pwm/4-0"); # Servo 1
}
if($servo2Aktif > -1){
  system("> /dev/GPIO-pwm/5-0"); # Servo 2
}
if($saklar1Aktif > -1){
  $switch_1 = system("./GPIO-status 15 > /dev/null");
}
if($saklar2Aktif > -1){
  $switch_2 = system("./GPIO-status 16 > /dev/null");
}

$last_call = time();

while (1){

  if(time - $last_call > 10){
    $last_call = time();
    $scriptResponse = get $URL . "&LEDRed=" . $LEDRed . "&LEDGreen=" . $LEDGreen . "&LEDYellow=" . $LEDYellow . "&LEDWhite=" . $LEDWhite . "&SWITCH_1=" . $switch_1 . "&SWITCH_2=" . $switch_2 . "&SERVO_1=" . $servo_1 . "&SERVO_2=" . $servo_2 . "&MOTOR_DIRECTION=" . $motor_direction . "&MOTOR_PWM=" . $motor_pwm . "&MAKE_SNAPSHOT=" . $make_snapshot;
    
    print "Script answer=\"" . $scriptResponse . "\" at " . (localtime) . "\n";
    
    if(length($scriptResponse) > 18){
    
      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));  
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));      
      if($LEDRedAktif > -1){
        if($temp < 0){
          $temp = 0;
        }
        $LEDRed = $temp;
      }

      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($LEDGreenAktif > -1){
        if($temp < 0){
          $temp = 0;
        }
        $LEDGreen = $temp;
      }

      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($LEDYellowAktif > -1){
        if($temp < 0){
          $temp = 0;
        }
        $LEDYellow = $temp;
      }
      
      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($LEDWhiteAktif > -1){
        if($temp < 0){
          $temp = 0;
        }
        $LEDWhite = $temp;
      }

      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($saklar1Aktif > -1){
        if($temp < 0){
          $temp = 0;
        }
        $switch_1 = $temp;
      }

      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($saklar2Aktif > -1){
        if($temp < 0){
          $temp = 0;
        }
        $switch_2 = $temp;
      }

      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($servo1Aktif > -1){
        if($temp < 0){
          $temp = 0;
        }
        $servo_1 = $temp;
      }

      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($servo2Aktif > -1){
        if($temp < 0){
          $temp = 0;
        }
        $servo_2 = $temp;
      }

      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($arahMotor > -1){
        if($temp < 0){
          $temp = 0;
        }
        $motor_direction = $temp;
      }

      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($pwmMotor > -1){
        if($temp < 0){
          $temp = 0;
        }
        $motor_pwm = $temp;
      }
      
      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($do_reboot > -1){
        if($temp < 0){
          $temp = 0;
        }
        $do_reboot = $temp;
      }
      
      $temp=substr($scriptResponse, 0, index($scriptResponse, "_"));
      $scriptResponse = substr($scriptResponse, index($scriptResponse, "_") + 1, length($scriptResponse));
      if($saklarKameraAktif > -1){
        if($temp < 0){
          $temp = 0;
        }
        $make_snapshot = $temp;
      }

    }
  }

  if($saklar1Aktif > -1){
    $switch_1 = system("./GPIO-status 15 > /dev/null");
  }
  if($saklar2Aktif > -1){
    $switch_2 = system("./GPIO-status 16 > /dev/null");
  }

  if($LEDGreenTmp != $LEDGreen){
    if($LEDGreen > -1 && $LEDGreen < 201 && $LEDGreenAktif > -1){
      system ("> /dev/GPIO-pwm/12-$LEDGreen");
    }
  }

  if($LEDRedTmp != $LEDRed){
    if($LEDRed > -1 && $LEDRed < 201 && $LEDRedAktif > -1){
      system ("> /dev/GPIO-pwm/14-$LEDRed");
    }
  }

  if($LEDYellowTmp != $LEDYellow){
    if($LEDYellow > -1 && $LEDYellow < 201 && $LEDYellowAktif > -1){
      system ("> /dev/GPIO-pwm/13-$LEDYellow");
    }
  }
  if($LEDWhiteTmp != $LEDWhite){
    if($LEDWhite > -1 && $LEDWhite < 201 && $LEDWhiteAktif > -1){
      system ("> /dev/GPIO-pwm/0-$LEDWhite");
    }
  }

  #Set servo
  if($servo1Aktif > -1){
    if($servo1Tmp != $servo_1){
      if($servo_1 > -1 && $servo_1 < 201){
        system ("> /dev/GPIO-pwm/4-$servo_1");
        $servo1DurationStart = time();
      }
    }

    if(time() - $servo1DurationStart > $servo_1_duration){
      system ("> /dev/GPIO-pwm/4-0"); # Stop servo
    }
  }

  if($servo2Aktif > -1){
    if($servo2Tmp != $servo_2){
      if($servo_2 > -1 && $servo_2 < 201){
        system ("> /dev/GPIO-pwm/5-$servo_2");
        $servo_2_duration_start = time();
      }
    }

    if(time() - $servo_2_duration_start > $servo_2_duration){
      system ("> /dev/GPIO-pwm/5-0"); # Stop servo
    }
  }
  

  if($arahMotorTmp != $motor_direction || $pwmMotorTmp != $motor_pwm){
    if($motor_direction == 0){
      if($motor_pwm > -1 && $motor_pwm < 201){
        if($arahMotor > -1){
          system ("> /dev/GPIO-pwm/3-0"); # arah
        }
        if($pwmMotor > -1){
          system ("> /dev/GPIO-pwm/2-$motor_pwm"); # PWM
        }
      }
    }
    else{
      if($motor_pwm > -1 && $motor_pwm < 201){
        if($arahMotor > -1){
          system ("> /dev/GPIO-pwm/3-200"); # arah
        }
        $temp = 200 - $motor_pwm;
        if($pwmMotor > -1){
          system ("> /dev/GPIO-pwm/2-$temp"); # PWM
        }
      }
    }
  }

  if($do_reboot == 1){
    print "Rebooting...\n";
    system ("init 6");
  }
  if($do_reboot == 2){
    print "Shuting down!\n";
    system ("init 0");
  }
  
  # Kirim foto yang diambi pada kamera raspi ke server
  if($make_snapshot == 1 && $saklarKameraTmp > 25){
    $make_snapshot = 0;
    system("raspistill -w 320 -h 240 -o " . $snapshot_file);
    if ( -e $snapshot_file ) {
      $upload_command = "snapshot";
      my $ua  = LWP::UserAgent->new();
      my $req = POST $URL, Content_Type => 'form-data', Content => [submit => 1, TRANSFER_FILE => [ $snapshot_file ], passwd => $password, UPLOAD_COMMAND => $upload_command];
      my $response = $ua->request($req);

      if ($response->is_success()) {
        print "Sending snapshot OK: " . $response->content . "\n";
      }
      else{
        print "ERROR sending snapshot: " . $response->as_string . "\n";
      }
    }
    else{
      print $snapshot_file . " Camera not found/not installed?\n";
    }
    $saklarKameraTmp = 0;
  }

  $LEDGreenTmp = $LEDGreen;
  $LEDYellowTmp = $LEDYellow;
  $LEDRedTmp = $LEDRed;
  $LEDWhiteTmp = $LEDWhite;
  $arahMotorTmp = $motor_direction;
  $pwmMotorTmp = $motor_pwm;
  $servo1Tmp = $servo_1;
  $servo2Tmp = $servo_2;
  $saklarKameraTmp++;
  
  sleep(1);
}