#!/usr/bin/perl -w
# Modul untuk perintah pada server, menghubungkan perintah pada halaman utama (interface pada web) ke perangkat raspi

use strict;
use CGI;

my $cgi = new CGI;

my $passwd = "";
my $led_red = "";
my $led_green = "";
my $led_yellow = "";
my $led_white = "";
my $servo_1 = "";
my $servo_2 = "";
my $switch_1 = "";
my $switch_2 = "";
my $transfer_file = "";
my $motor_direction = "";
my $motor_pwm = "";
my $upload_command = "";
my $make_snapshot = "";

$passwd = $cgi->param("passwd");
$led_red = $cgi->param("LED_RED");
$led_green = $cgi->param("LED_GREEN");
$led_yellow = $cgi->param("LED_YELLOW");
$led_white = $cgi->param("LED_WHITE");
$servo_1 = $cgi->param("SERVO_1");
$servo_2 = $cgi->param("SERVO_2");
$switch_1 = $cgi->param("SWITCH_1");
$switch_2 = $cgi->param("SWITCH_2");
$transfer_file = $cgi->param("TRANSFER_FILE");
$motor_direction = $cgi->param("MOTOR_DIRECTION");
$motor_pwm = $cgi->param("MOTOR_PWM");
$make_snapshot = $cgi->param("MAKE_SNAPSHOT");

$upload_command = $cgi->param("UPLOAD_COMMAND");

my $charAsal = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_";
my $i = 0;
my $system_command = "";

my $file_name = "";
my $command_received = "";
my $return_line = "";
my $matching_file="";

print $cgi->header(-type => 'text/html');

&CheckParameter($passwd, "passwd", 100);

if($upload_command eq "snapshot"){
  my $fname = "snapshot/" . $passwd . "_photo.jpg";
  open DAT,'>'.$fname or die 'Error processing file: ',$!;

  binmode $transfer_file;
  binmode DAT;

  my $data;
  my $file_size = 0;
  while((read $transfer_file,$data,1024) && $file_size < 2000000){
    print DAT $data;
    $file_size += 1024;
  }
  close DAT;
  if( $file_size > 2000000){
    print "<html><head></head><body>File too large</body></html>";
  }
  else{
   print "<html><head></head><body>OK</body></html>";
 }
  exit(0);
}

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

if(length($passwd)<1){
  print("No password transmitted!");
  exit(1);
}

if ( !(-d "snapshot") ) {
  system("mkdir snapshot");
}

if ( !(-d "command") ) {
  system("mkdir command");
}

if ( !(-d "status") ) {
  system("mkdir status");
}

opendir(DIR, "command") || die "Can not find directory 'files'!\n";
while (my $file = readdir(DIR)){
  if(index($file, $passwd . "_") > -1){
    $command_received = substr($file, index($file, "_") + 1, length($file));
    $matching_file = $file;
  }
}
closedir(DIR);

$file_name = $passwd . "_" . $led_red . "_" . $led_green . "_" . $led_yellow . "_" . $led_white . "_" . $switch_1 . "_" . $switch_2 . "_" . $servo_1 . "_" . $servo_2 . "_" . $motor_direction . "_" . $motor_pwm . "_" . $make_snapshot;

$system_command = "rm status/" . $passwd . "_* -f";
system($system_command);

open(FILEOUT, "> status/" . $file_name) || die("Can not open status file!");
  print FILEOUT "";
close(FILEOUT);

$return_line = $command_received;

print $return_line . "_OK";

$system_command = "rm command/" . $matching_file . " -f";
system($system_command);

exit(0);

sub CheckParameter{
  if(length($_[0]) > $_[2]){
    print "Parameter $_[1] '" . $_[0] . "'too long (max. $_[2] characters)";
    exit(1);
  }
  for($i = 0; $i < length($_[0]); $i++){
    if(index($charAsal, substr($_[0], $i, 1)) < 0){
      print "</head><body>";
      print("Wrong character '" . substr($_[0], $i, 1) . "' in parameter $_[1]: '" . $_[0] . "'!");
      print "</body></html>";
      exit(1);
    }
  }
  
}

