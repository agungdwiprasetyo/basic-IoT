# Modul IoT sederhana untuk Raspberry Pi
Perangkat yang terhubung pada Raspberry Pi: 4 buah LED, 2 buah servo, motor DC, dan sebuah kamera

## Instalasi
Instal library wiringPi pada perangkat Raspberry (dalam bahasa C) untuk menggunakan pin GPIO pada Raspberry Pi:
```sh
$ cd /home/pi
$ git clone git://git.drogon.net/wiringPi
$ cd wiringPi
$ ./build
```

Untuk menjalankan script Perl pada Raspberry Pi (jika belum ada)
```
$ sudo apt-get update
$ sudo apt-get install libwww-perl
```

Webserver menggunakan NodeJS (konfigurasi pada direktori ```/server```)

Jika konfigurasi pada server NodeJS sudah siap, jalankan script perl dengan mengetikkan ```./start-raspberry.pl``` pada Terminal di perangkat Raspberry Pi, lalu buka url ```localhost:3456/``` untuk membuka interface web pada server.