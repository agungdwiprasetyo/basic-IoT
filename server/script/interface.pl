#! /usr/bin/perl
# Bagian interface pada web untuk mengendalikan alat

use strict;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);

my $passwd = "";
my $status_only = "";
my $led_red = "";
my $led_green = "";
my $led_yellow = "";
my $led_white = "";
my $servo_1 = "";
my $servo_2 = "";
my $switch_1 = "";
my $switch_2 = "";
my $motor_direction = "";
my $motor_pwm = "";
my $do_reboot = "";
my $make_snapshot = "";

$passwd = param("passwd");
$status_only = param("statusONLY");
$led_red = param("LED_RED");
$led_green = param("LED_GREEN");
$led_yellow = param("LED_YELLOW");
$led_white = param("LED_WHITE");
$servo_1 = param("SERVO_1");
$servo_2 = param("SERVO_2");
$switch_1 = param("SWITCH_1");
$switch_2 = param("SWITCH_2");
$motor_direction = param("MOTOR_DIRECTION");
$motor_pwm = param("MOTOR_PWM");
$do_reboot = param("DOREBOOT");
$make_snapshot = param("MAKE_SNAPSHOT");

my $status_led_green = 0;
my $status_led_red = 0;
my $status_led_yellow = 0;
my $status_led_white = 0;
my $status_servo_1 = 0;
my $status_servo_2 = 0;
my $status_switch_1 = -1;
my $status_switch_2 = -1;
my $status_motor_direction = 0;
my $status_motor_pwm = 0;
my $status_make_snapshot = 0;

my $status_received = "";
my $file_name = "";
my $system_command = "";
my $charAsal = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-";
my $no_matching_password = 1;
my $online_status = 0;
my $last_status_time = 0;
my $last_status_received = "";

my $i = 0;

print "Content-type: text/html\n\n";
print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">' . "\n";
print "<html><head><title>Internet Of Things</title>" . "\n";


&CheckParameter($led_red, "led_red", 4);
&CheckParameter($led_green, "led_green", 4);
&CheckParameter($led_yellow, "led_yellow", 4);
&CheckParameter($led_white, "led_white", 4);
&CheckParameter($servo_1, "servo_1", 4);
&CheckParameter($servo_2, "servo_2", 4);
&CheckParameter($switch_1, "switch_1", 4);
&CheckParameter($switch_2, "switch_2", 4);
&CheckParameter($motor_direction, "motor_direction", 4);
&CheckParameter($motor_pwm, "motor_pwm", 4);

if( !($passwd eq "")){
  &CheckParameter($passwd, "passwd", 100);
}

if(length($passwd) > 0){
  opendir(DIR, "status") || die "Can not find directory 'status'!\n";
  while (my $file = readdir(DIR)){
    if(index($file, $passwd . "_") > -1){
      $status_received = substr($file, index($file, "_") + 1, length($file));
      $last_status_received = $status_received;
      $no_matching_password = 0;
      $last_status_time = (stat("status/" . $file))[9];
      if(time() - $last_status_time < 60){
        $online_status = 1;
      }
    }
  }
  closedir(DIR);
}

if($no_matching_password == 1 && length($passwd) > 0){
  sleep(10);
}

if($make_snapshot == 2){
  $system_command = "rm snapshot/" . $passwd . "_foto.jpg -f";
  system($system_command);
}


if(length($status_received) > 18){

  $status_led_red=substr($status_received, 0, index($status_received, "_"));  
  $status_received = substr($status_received, index($status_received, "_") + 1, length($status_received));

  $status_led_green=substr($status_received, 0, index($status_received, "_"));
  $status_received = substr($status_received, index($status_received, "_") + 1, length($status_received));

  $status_led_yellow=substr($status_received, 0, index($status_received, "_"));
  $status_received = substr($status_received, index($status_received, "_") + 1, length($status_received));
  
  $status_led_white=substr($status_received, 0, index($status_received, "_"));
  $status_received = substr($status_received, index($status_received, "_") + 1, length($status_received));

  $status_switch_1=substr($status_received, 0, index($status_received, "_"));
  $status_received = substr($status_received, index($status_received, "_") + 1, length($status_received));

  $status_switch_2=substr($status_received, 0, index($status_received, "_"));
  $status_received = substr($status_received, index($status_received, "_") + 1, length($status_received));

  $status_servo_1=substr($status_received, 0, index($status_received, "_"));
  $status_received = substr($status_received, index($status_received, "_") + 1, length($status_received));

  $status_servo_2=substr($status_received, 0, index($status_received, "_"));
  $status_received = substr($status_received, index($status_received, "_") + 1, length($status_received));

  $status_motor_direction=substr($status_received, 0, index($status_received, "_"));
  $status_received = substr($status_received, index($status_received, "_") + 1, length($status_received));

  $status_motor_pwm=substr($status_received, 0, index($status_received, "_"));
  $status_received = substr($status_received, index($status_received, "_") + 1, length($status_received));
  
  $status_make_snapshot=$status_received;
}


if($status_only == 1){
  print "</head><body style=\"background-color:#000000; color:#FFFFFF;\">";
  if($no_matching_password == 0){
    $system_command = "rm command/" . $passwd . "_* -f";
    system($system_command);

    $file_name = $passwd . "_" . $led_red . "_" . $led_green . "_" . $led_yellow . "_" . $led_white . "_" . $switch_1 . "_" . $switch_2 . "_" . $servo_1 . "_" . $servo_2 . "_" . $motor_direction . "_" . $motor_pwm . "_" . $do_reboot . "_" . $make_snapshot;
    open(FILEOUT, "> command/" . $file_name) || die("Can not open command file!</body></html>");
      print FILEOUT "";
    close(FILEOUT);
  }
  print '<table width="520px" align="left" border="1" cellpadding="5" cellspacing="0">';
  print '<tr>';
  if($status_switch_1 > -1){
    print '<td>';
    print 'SWITCH 1';
    print '</td>';
    if($status_switch_1 == 512){
      print '<td align="center" style="background-color:#AAFFAA; color:#000000;">';
      print "CLOSED";
    }
    else{
      print '<td align="center" style="background-color:#FFAAAA; color:#000000;">';
      print "OPEN";
    }
    print '</td>';
  }
  if($status_switch_2 > -1){
    print '<td>';
    print 'SWITCH 2';
    print '</td>';
    if($status_switch_2 == 512){
      print '<td align="center" style="background-color:#AAFFAA; color:#000000;">';
      print "CLOSED";
    }
    else{
      print '<td align="center" style="background-color:#FFAAAA; color:#000000;">';
      print "OPEN";
    }
    print '</td>';
  }
  if($online_status == 1){
    print '<td style="background-color:#AAFFAA; color:#000000;">';
    print 'ONLINE';
  }
  else{
    print '<td style="background-color:#FFAAAA; color:#000000;">';
    print 'OFFLINE';
  }
  print '</td>';
  print '</tr>';
  print '</table>';
  print '<br clear="all">';
  print '<table width="520px" align="left" border="1" cellpadding="1" cellspacing="0">';
  print '<tr>';
  print '<td>';
  print 'Status received:';
  print '</td>';

  if($status_led_red eq $led_red &&
     $status_led_green eq $led_green &&
     $status_led_yellow eq $led_yellow &&
     $status_led_white eq $led_white &&
     $status_servo_1 eq $servo_1 &&
     $status_servo_2 eq $servo_2 &&
     $status_motor_direction eq $motor_direction &&
     $status_motor_pwm eq $motor_pwm){
      print '<td style="background-color:#AAFFAA; color:#000000;">';
  }
  else{
      print '<td style="background-color:#FFAAAA; color:#000000;">';
  }
  print $last_status_received;
  print '</td>';
  print '</tr>';
  print '<td>';
  print 'Date / time: ';
  print '</td>';
  print '<td>';
  print "" . localtime($last_status_time);
  print '</td>';
  print '</tr>';
  print '</table>';
  print "</body></html>\n";
}

if($status_only == 0){
  print '<script type="text/javascript">' . "\n";
  print '  var StatusLedGreen = ' . $status_led_green . ';' . "\n";
  print '  var StatusLedRed = ' . $status_led_red . ';' . "\n";
  print '  var StatusLedYellow = ' . $status_led_yellow . ';' . "\n";
  print '  var StatusLedWhite = ' . $status_led_white . ';' . "\n";
  print '  var StatusSwitch1 = ' . $status_switch_1 . ';' . "\n";
  print '  var StatusSwitch2 = ' . $status_switch_2 . ';' . "\n";
  print '  var StatusServo1 = ' . $status_servo_1 . ';' . "\n";
  print '  var StatusServo2 = ' . $status_servo_2 . ';' . "\n";
  print '  var StatusMotorDirection = ' . $status_motor_direction . ';' . "\n";
  print '  var StatusMotorPwm = ' . $status_motor_pwm . ';' . "\n";
  print '  var passwd = "' . $passwd . '";' . "\n";
  print '  var DoReboot = 0;' . "\n";
  print '  var MakeSnapshot = ' . $status_make_snapshot . ';' . "\n";
  print '  var ButtonPressed = 0;' . "\n";
  print '  var RebootCount = 100;' . "\n";
  print '  var SnapshotCounter = 0;' . "\n";

  print '  var EncryptKeyShift = "c03gs3k4l1";' . "\n"; # disamakan dengan di script Raspberry.pl

  print '  function checkImage (src, good, bad){' . "\n";
  print '      var img = new Image();' . "\n";
  print '      img.onload = good; ' . "\n";
  print '      img.onerror = bad;' . "\n";
  print '      img.src = src;' . "\n";
  print '  }' . "\n";

  print '  function snapshotOK (src){' . "\n";
  print '    document.getElementById("SnapshotID").src=src;' . "\n";
  print '    MakeSnapshot = 2;' . "\n";
  print '  }' . "\n";

  print '  function snapshotNotFound(){' . "\n";
  print '    NotFound = 1;' . "\n";
  print '  }' . "\n";


  print 'function encode(original){' . "\n";
  print '  var encodeString = "";' . "\n";
  print '  var charPos;' . "\n";
  print '  var i;' . "\n";
  print '  for (i = 0; i < original.length; i++){' . "\n";
  print '    charPos=EncryptKeyShift.indexOf(original.substr(i,1));' . "\n";
  print '    encodeString += charPos + "-";' . "\n";
  print '  }' . "\n";
  print '  return (encodeString);  ' . "\n";
  print '}' . "\n";

  if($status_led_green > -1){
    print 'function ButtonLedGreenOFFClicked(){' . "\n";
    print '  StatusLedGreen = 0;' . "\n";
    print '  document.Form01.ButtonLedGreen.value = "PWM = " + StatusLedGreen;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedGreenONClicked(){' . "\n";
    print '  StatusLedGreen = 200;' . "\n";
    print '  document.Form01.ButtonLedGreen.value = "PWM = " + StatusLedGreen;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedGreenMinusClicked(){' . "\n";
    print '  if(StatusLedGreen > 10){' . "\n";
    print '    StatusLedGreen -= 10;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusLedGreen = 0;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonLedGreen.value = "PWM = " + StatusLedGreen;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedGreenPlusClicked(){' . "\n";
    print '  if(StatusLedGreen < 190){' . "\n";
    print '    StatusLedGreen += 10;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusLedGreen = 200;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonLedGreen.value = "PWM = " + StatusLedGreen;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";
  }

  if($status_led_red > -1){
    print 'function ButtonLedRedOFFClicked(){' . "\n";
    print '  StatusLedRed = 0;' . "\n";
    print '  document.Form01.ButtonLedRed.value = "PWM = " + StatusLedRed;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedRedONClicked(){' . "\n";
    print '  StatusLedRed = 200;' . "\n";
    print '  document.Form01.ButtonLedRed.value = "PWM = " + StatusLedRed;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedRedMinusClicked(){' . "\n";
    print '  if(StatusLedRed > 10){' . "\n";
    print '    StatusLedRed -= 10;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusLedRed = 0;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonLedRed.value = "PWM = " + StatusLedRed;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedRedPlusClicked(){' . "\n";
    print '  if(StatusLedRed < 190){' . "\n";
    print '    StatusLedRed += 10;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusLedRed = 200;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonLedRed.value = "PWM = " + StatusLedRed;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";
  }

  if($status_led_yellow > -1){
    print 'function ButtonLedYellowOFFClicked(){' . "\n";
    print '  StatusLedYellow = 0;' . "\n";
    print '  document.Form01.ButtonLedYellow.value = "PWM = " + StatusLedYellow;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedYellowONClicked(){' . "\n";
    print '  StatusLedYellow = 200;' . "\n";
    print '  document.Form01.ButtonLedYellow.value = "PWM = " + StatusLedYellow;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedYellowMinusClicked(){' . "\n";
    print '  if(StatusLedYellow > 10){' . "\n";
    print '    StatusLedYellow -= 10;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusLedYellow = 0;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonLedYellow.value = "PWM = " + StatusLedYellow;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedYellowPlusClicked(){' . "\n";
    print '  if(StatusLedYellow < 190){' . "\n";
    print '    StatusLedYellow += 10;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusLedYellow = 200;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonLedYellow.value = "PWM = " + StatusLedYellow;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";
  }

  if($status_led_white > -1){
    print 'function ButtonLedWhiteOFFClicked(){' . "\n";
    print '  StatusLedWhite = 0;' . "\n";
    print '  document.Form01.ButtonLedWhite.value = "PWM = " + StatusLedWhite;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedWhiteONClicked(){' . "\n";
    print '  StatusLedWhite = 200;' . "\n";
    print '  document.Form01.ButtonLedWhite.value = "PWM = " + StatusLedWhite;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedWhiteMinusClicked(){' . "\n";
    print '  if(StatusLedWhite > 10){' . "\n";
    print '    StatusLedWhite -= 10;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusLedWhite = 0;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonLedWhite.value = "PWM = " + StatusLedWhite;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonLedWhitePlusClicked(){' . "\n";
    print '  if(StatusLedWhite < 190){' . "\n";
    print '    StatusLedWhite += 10;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusLedWhite = 200;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonLedWhite.value = "PWM = " + StatusLedWhite;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";
  }

  if($status_servo_1 > -1){
    print 'function ButtonServo1OFFClicked(){' . "\n";
    print '  StatusServo1 = 10;' . "\n";
    print '  document.Form01.ButtonServo1.value = "PWM = " + StatusServo1;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonServo1ONClicked(){' . "\n";
    print '  StatusServo1 = 20;' . "\n";
    print '  document.Form01.ButtonServo1.value = "PWM = " + StatusServo1;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonServo1MinusClicked(){' . "\n";
    print '  if(StatusServo1 > 10){' . "\n";
    print '    StatusServo1 -= 1;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusServo1 = 10;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonServo1.value = "PWM = " + StatusServo1;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonServo1PlusClicked(){' . "\n";
    print '  if(StatusServo1 < 19){' . "\n";
    print '    StatusServo1 += 1;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusServo1 = 20;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonServo1.value = "PWM = " + StatusServo1;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";
  }

  if($status_servo_2 > -1){
    print 'function ButtonServo2OFFClicked(){' . "\n";
    print '  StatusServo2 = 10;' . "\n";
    print '  document.Form01.ButtonServo2.value = "PWM = " + StatusServo2;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonServo2ONClicked(){' . "\n";
    print '  StatusServo2 = 20;' . "\n";
    print '  document.Form01.ButtonServo2.value = "PWM = " + StatusServo2;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonServo2MinusClicked(){' . "\n";
    print '  if(StatusServo2 > 10){' . "\n";
    print '    StatusServo2 -= 1;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusServo2 = 10;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonServo2.value = "PWM = " + StatusServo2;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonServo2PlusClicked(){' . "\n";
    print '  if(StatusServo2 < 19){' . "\n";
    print '    StatusServo2 += 1;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusServo2 = 20;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonServo2.value = "PWM = " + StatusServo2;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";
  }

  if($status_motor_pwm > -1){
    print 'function ButtonMotorPwmOFFClicked(){' . "\n";
    print '  StatusMotorPwm = 0;' . "\n";
    print '  document.Form01.ButtonMotorPwm.value = "PWM = " + StatusMotorPwm;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonMotorPwmONClicked(){' . "\n";
    print '  StatusMotorPwm = 200;' . "\n";
    print '  document.Form01.ButtonMotorPwm.value = "PWM = " + StatusMotorPwm;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonMotorPwmMinusClicked(){' . "\n";
    print '  if(StatusMotorPwm > 10){' . "\n";
    print '    StatusMotorPwm -= 10;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusMotorPwm = 0;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonMotorPwm.value = "PWM = " + StatusMotorPwm;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";

    print 'function ButtonMotorPwmPlusClicked(){' . "\n";
    print '  if(StatusMotorPwm < 190){' . "\n";
    print '    StatusMotorPwm += 10;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusMotorPwm = 200;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonMotorPwm.value = "PWM = " + StatusMotorPwm;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";
  }

  if($status_motor_direction > -1){
    print 'function ButtonMotorDirectionClicked(){' . "\n";
    print '  if(StatusMotorDirection == 0){' . "\n";
    print '    StatusMotorDirection = 1;' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print '    StatusMotorDirection = 0;' . "\n";
    print '  }' . "\n";
    print '  document.Form01.ButtonMotorDirection.value = "Direction = " + StatusMotorDirection;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";
  }

  print 'function ButtonRebootClicked(){' . "\n";
  print '  if(confirm("Are you sure you want to reboot your Rasperry Pi?")){' . "\n";
  print '    DoReboot = 1;' . "\n";
  print '    ButtonPressed = 1;' . "\n";
  print '    SendCommand();' . "\n";
  print '    RebootCount = 0;' . "\n";  
  print '  }' . "\n";
  print '}' . "\n";

  print 'function ButtonShutdownClicked(){' . "\n";
  print '  if(confirm("Are you sure you want to SHUTDOWN your Rasperry Pi?")){' . "\n";
  print '    if(confirm("Your Raspberry will SHUTDOWN if you confirm this 2nd and last alert!!!")){' . "\n";
  print '      DoReboot = 2;' . "\n";
  print '      ButtonPressed = 1;' . "\n";
  print '      SendCommand();' . "\n";
  print '      RebootCount = 0;' . "\n";  
  print '    }' . "\n";
  print '  }' . "\n";
  print '}' . "\n";

  if($status_make_snapshot > -1){
    print 'function ButtonMakeSnapshotClicked(){' . "\n";
    print '  document.Form01.ButtonMakeSnapshot.disabled = true;' . "\n";
    print '  MakeSnapshot = 1;' . "\n";
    print '  ButtonPressed = 1;' . "\n";
    print '  SnapshotCounter = 0;' . "\n";
    print '  SendCommand();' . "\n";
    print '}' . "\n";
  }

  if($no_matching_password == 1){
    print 'function ButtonPWClicked(){' . "\n";
    print '  var i = 0;' . "\n";
    print '  var i2 = 0;' . "\n";
    print '  var tempVar = 0;' . "\n";
    print '  var AllowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";' . "\n";
    print '  passwd=document.Form01.PasswordText.value;' . "\n";
    print '  ' . "\n";
    print '  for(i = 0; i < passwd.length; i++){' . "\n";
    print '    tempVar = -1;' . "\n";
    print '    for(i2 = 0; i2 < AllowedChars.length; i2++){' . "\n";
    print '      if(AllowedChars.charAt(i2) == passwd.charAt(i)){' . "\n";
    print '        tempVar = 1;' . "\n";
    print '      }' . "\n";
    print '    }' . "\n";
    print '    if (tempVar == -1){' . "\n";
    print '      i = passwd.length;' . "\n";
    print '    }' . "\n";
    print '  }' . "\n";
    print '  if (tempVar == -1 || passwd.length < 1){' . "\n";
    print '    alert("Only characters (a-z, A-Z) and numbers (0-9) allowed for password! Please correct your password.");' . "\n";
    print '    document.Form01.PasswordText.focus();' . "\n";
    print '  }' . "\n";
    print '  else{' . "\n";
    print  '   passwd=encode(passwd);' . "\n";
    print '    window.open("http://agungdp.agri.web.id:3456/server.pl?statusONLY=0&passwd=" + passwd, "_parent");' . "\n";
    print '  }' . "\n";
    print '}' . "\n";
  }

  print 'function SendCommand(){' . "\n";
#  print '  passwd=document.Form01.PasswordText.value;' . "\n";
  print '  if(passwd != ""){' . "\n";
  print '    window.frames.RasperryStatus.location.href = "http://agungdp.agri.web.id:3456/server.pl?passwd=" + passwd + "&LED_RED=" + StatusLedRed + "&LED_GREEN=" + StatusLedGreen + "&LED_YELLOW=" + StatusLedYellow + "&LED_WHITE=" + StatusLedWhite + "&SWITCH_1=" + StatusSwitch1 + "&SWITCH_2=" + StatusSwitch2 + "&SERVO_1=" + StatusServo1 + "&SERVO_2=" + StatusServo2 + "&MOTOR_DIRECTION=" + StatusMotorDirection + "&MOTOR_PWM=" + StatusMotorPwm + "&statusONLY=1" + "&DOREBOOT=" + DoReboot + "&MAKE_SNAPSHOT=" + MakeSnapshot;' . "\n";
  
  if($status_make_snapshot > -1){
    print '    if(ButtonPressed == 0 && MakeSnapshot == 1){' . "\n";
    print '      DateTimer = new Date();' . "\n";
    print '      LinkCount = DateTimer.getTime();' . "\n";
    print '      snapshotSRC = "http://www.robospatium.de/IOT/snapshot/" + passwd + "_photo.jpg?" + LinkCount.toString();' . "\n";
    print '      checkImage(snapshotSRC, function(){snapshotOK(snapshotSRC);}, function(){snapshotNotFound();});' . "\n";
    print '    }' . "\n";
    print '    if(ButtonPressed == 0 && MakeSnapshot == 2){' . "\n";
    print '      document.Form01.ButtonMakeSnapshot.disabled = false;' . "\n";
    print '      MakeSnapshot = 0;' . "\n";  
    print '    }' . "\n";
  }
  print '    if(ButtonPressed == 0){' . "\n";
  print '      SnapshotCounter++;' . "\n";
  print '      RebootCount++;' . "\n";
  print '      if(SnapshotCounter > 10){' . "\n";
  print '        MakeSnapshot = 0;' . "\n";  
  print '      }' . "\n";
  print '      if(RebootCount == 2){' . "\n";
  print '        DoReboot = 0;' . "\n";  
  print '      }' . "\n";
  print '    }' . "\n";
  print '    //alert("Sent!");' . "\n";
  print '  }' . "\n";
  print '  else{' . "\n";
  print '    alert("No password!");' . "\n";
  if($no_matching_password == 1){
    print '    document.Form01.PasswordText.focus();' . "\n";
  }
  print '  }' . "\n";
  print '  ButtonPressed = 0;' . "\n";
  print '}' . "\n";

  print '</script>' . "\n";

  if($no_matching_password == 1){
    print "</head><body style=\"background-color:#000000; color:#FFFFFF;\">";
  }
  else{
    print "</head><body style=\"background-color:#000000; color:#FFFFFF;\" onload=\"setInterval(function () {SendCommand()}, 10000)\">";
  }
  print '  <h2>Status</h2>' . "\n";
  if($no_matching_password == 0){
    print '  <iframe src="http://agungdp.agri.web.id:3456/server.pl?statusONLY=1&passwd=' . $passwd . '"  scrolling="no" width="550" height="100"  frameborder="1" name="RasperryStatus">' . "\n";
  }
  else{
    print '  <iframe src="http://agungdp.agri.web.id:3456/server.pl?statusONLY=1"  scrolling="no" width="550" height="100"  frameborder="0" name="RasperryStatus">' . "\n";
  }
  print '    Your browser can not display embedded frames...' . "\n";
  print '  </iframe><br>' . "\n";
  print '  <h2>Control panel</h2>' . "\n";

  if($no_matching_password == 1){
    print "<strong>Your password is not correct!</strong><br>\n";
    print "Make sure your Raspberry Pi is connected to the Internet and<br>the script 'start-raspberry.pl' is running.<br>\n";
    print "Type the password as set in the script 'start-raspberry.pl'<br>and press 'Send PW' to connect with your Raspberry Pi.<br><br>\n";
  }

  print '    <form name="Form01" onsubmit="return false;" action="" >' . "\n";
  print '      <table align="left" border="1" cellpadding="3" cellspacing="0" width="550px">' . "\n";
  if($no_matching_password == 1){  
    print '        <tr>' . "\n";
    print '          <td colspan="2">' . "\n";
    print '            Password: <input name="PasswordText" type="text" size="15" maxlength="31" value = "" style="text-align:right" onkeydown="if (event.keyCode == 13) ButtonPWClicked()">' . "\n";
    print '            <input type="button" style="width:150px" name="ButtonPW" value="Send PW" onclick="ButtonPWClicked() ">' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  else{    
    print '        <tr>' . "\n";
    print '          <td colspan="2" align="center" style="background-color:#FFAAAA; color:#000000; font-family:serif,Times,serif; font-size:12px;">' . "\n";
    print '           Note that there is a delay of approximately 30s from click to GPIO action!' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  if($status_led_red > -1){
    print '        <tr>' . "\n";
    print '          <td>' . "\n";
    print '            RED LED' . "\n";
    print '          </td>' . "\n";
    print '          <td align="center">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedRedOFF" value="OFF" onclick="ButtonLedRedOFFClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedRedMinus" value="-10" onclick="ButtonLedRedMinusClicked()">' . "\n";
    print '            <input type="button" style="width:100px" name="ButtonLedRed" value="PWM = ' . $status_led_red . '" onclick="ButtonLedRedClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedRedPlus" value="+10" onclick="ButtonLedRedPlusClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedRedON" value="ON" onclick="ButtonLedRedONClicked()">' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  if($status_led_yellow > -1){
    print '        <tr>' . "\n";
    print '          <td>' . "\n";
    print '            YELLOW LED' . "\n";
    print '          </td>' . "\n";
    print '          <td align="center">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedYellowOFF" value="OFF" onclick="ButtonLedYellowOFFClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedYellowMinus" value="-10" onclick="ButtonLedYellowMinusClicked()">' . "\n";
    print '            <input type="button" style="width:100px" name="ButtonLedYellow" value="PWM = ' . $status_led_yellow . '" onclick="ButtonLedYellowClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedYellowPlus" value="+10" onclick="ButtonLedYellowPlusClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedYellowON" value="ON" onclick="ButtonLedYellowONClicked()">' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  if($status_led_green > -1){
    print '        <tr>' . "\n";
    print '          <td>' . "\n";
    print '            GREEN LED' . "\n";
    print '          </td>' . "\n";
    print '          <td align="center">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedGreenOFF" value="OFF" onclick="ButtonLedGreenOFFClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedGreenMinus" value="-10" onclick="ButtonLedGreenMinusClicked()">' . "\n";
    print '            <input type="button" style="width:100px" name="ButtonLedGreen" value="PWM = ' . $status_led_green . '" onclick="ButtonLedGreenClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedGreenPlus" value="+10" onclick="ButtonLedGreenPlusClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedGreenON" value="ON" onclick="ButtonLedGreenONClicked()">' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  if($status_led_white > -1){
    print '        <tr>' . "\n";
    print '          <td>' . "\n";
    print '            WHITE LED' . "\n";
    print '          </td>' . "\n";
    print '          <td align="center">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedWhiteOFF" value="OFF" onclick="ButtonLedWhiteOFFClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedWhiteMinus" value="-10" onclick="ButtonLedWhiteMinusClicked()">' . "\n";
    print '            <input type="button" style="width:100px" name="ButtonLedWhite" value="PWM = ' . $status_led_white . '" onclick="ButtonLedWhiteClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedWhitePlus" value="+10" onclick="ButtonLedWhitePlusClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonLedWhiteON" value="ON" onclick="ButtonLedWhiteONClicked()">' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  if($status_servo_1 > -1){
    print '        <tr>' . "\n";
    print '          <td>' . "\n";
    print '            SERVO 1' . "\n";
    print '          </td>' . "\n";
    print '          <td align="center">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonServo1OFF" value="L" onclick="ButtonServo1OFFClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonServo1Minus" value="-1" onclick="ButtonServo1MinusClicked()">' . "\n";
    print '            <input type="button" style="width:100px" name="ButtonServo1" value="PWM = ' . $status_servo_1 . '" onclick="ButtonServo1Clicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonServo1Plus" value="+1" onclick="ButtonServo1PlusClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonServo1ON" value="R" onclick="ButtonServo1ONClicked()">' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  if($status_servo_2 > -1){
    print '        <tr>' . "\n";
    print '          <td>' . "\n";
    print '            SERVO 2' . "\n";
    print '          </td>' . "\n";
    print '          <td align="center">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonServo2OFF" value="L" onclick="ButtonServo2OFFClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonServo2Minus" value="-1" onclick="ButtonServo2MinusClicked()">' . "\n";
    print '            <input type="button" style="width:100px" name="ButtonServo2" value="PWM = ' . $status_servo_2 . '" onclick="ButtonServo2Clicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonServo2Plus" value="+1" onclick="ButtonServo2PlusClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonServo2ON" value="R" onclick="ButtonServo2ONClicked()">' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  if($status_motor_pwm > -1){
    print '        <tr>' . "\n";
    print '          <td>' . "\n";
    print '            MOTOR PWM' . "\n";
    print '          </td>' . "\n";
    print '          <td align="center">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonMotorPwmOFF" value="OFF" onclick="ButtonMotorPwmOFFClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonMotorPwmMinus" value="-10" onclick="ButtonMotorPwmMinusClicked()">' . "\n";
    print '            <input type="button" style="width:100px" name="ButtonMotorPwm" value="PWM = ' . $status_motor_pwm . '" onclick="ButtonMotorPwmClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonMotorPwmPlus" value="+10" onclick="ButtonMotorPwmPlusClicked()">' . "\n";
    print '            <input type="button" style="width:50px" name="ButtonMotorPwmON" value="ON" onclick="ButtonMotorPwmONClicked()">' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  if($status_motor_direction > -1){
    print '        <tr>' . "\n";
    print '          <td>' . "\n";
    print '            MOTOR DIRECTION' . "\n";
    print '          </td>' . "\n";
    print '          <td align="center">' . "\n";
    print '            <input type="button" style="width:150px" name="ButtonMotorDirection" value="Direction = ' . $status_motor_direction . '" onclick="ButtonMotorDirectionClicked()">' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  if($status_make_snapshot > -1){
    print '        <tr>' . "\n";
    print '          <td align="center">' . "\n";
    print '            <input type="button" style="width:150px" name="ButtonMakeSnapshot" value="Make snapshot" onclick="ButtonMakeSnapshotClicked()">' . "\n";
    print '          </td>' . "\n";
    print '          <td align="center">' . "\n";
    print '            <img src="http://robospatium.de/IOT/snapshot/testpic.jpg" width="320" height="240" id="SnapshotID">' . "\n";
    print '          </td>' . "\n";
    print '        </tr>' . "\n";
  }
  print '        <tr>' . "\n";
  print '          <td colspan="2" align="center">' . "\n";
  print '            <input type="button" name="ButtonResend" value="Resend instruction set" onclick="SendCommand()">' . "\n";
  print '          </td>' . "\n";
  print '        </tr>' . "\n";
  print '        <tr>' . "\n";
  print '          <td colspan="2" align="center" style="background-color:#FFAAAA; color:#000000;">' . "\n";
  print '            <input type="button" name="ButtonReboot" value="Reboot Raspberry" onclick="ButtonRebootClicked()"><input type="button" name="ButtonShutdown" value="Shutdown Raspberry" onclick="ButtonShutdownClicked()">' . "\n";
  print '          </td>' . "\n";
  print '        </tr>' . "\n";
  print '      </table>' . "\n";
  print '    </form>' . "\n";
  print '    <br clear="all">' . "\n";

  print "</body></html>" . "\n";
}
exit (0);

sub CheckParameter{
  if(length($_[0]) > $_[2]){
    print "Parameter $_[1] '" . $_[0] . "'too long (max. $_[2] characters)";
    exit(1);
  }
  for($i = 0; $i < length($_[0]); $i++){
    if(index($charAsal, substr($_[0], $i, 1)) < 0){
      print "</head><body>";
      print("Wrong character in parameter $_[1]!");
      print "</body></html>";
      exit(1);
    }
  }
  
}