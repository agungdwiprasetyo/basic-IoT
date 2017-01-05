var Perl = require('./perl').spawnPerlCGI;
var express = require('express')
      ,http = require('http')
       ,url = require('url')
      ,path = require('path');
var app = express();

var scriptInterface = path.join(__dirname, '/script/interface.pl');
var scriptService = path.join(__dirname, '/script/server.pl');

app.set('port', process.env.PORT || 3456);

app.get('/', function(req, res){
  var perl = new Perl(scriptInterface, req, null, function(err,data){
    if(err){
      console.log(err);
    }
    res.header(perl.getHeader());
    res.write(data);
    res.end();
    });                    
});

app.get('/service', function(req, res){
  var perl = new Perl(scriptService, req, null, function(err,data){
    if(err){
      console.log(err);
    }
    res.header(perl.getHeader());
    res.write(data);
    res.end();
    });                    
});

app.post('/data', function(req, res){
  var perl = new Perl(scriptInterface, req, null, function(err,data){
    if(err){              
      console.log(err);
    }                
    res.header(perl.getHeader());
    res.write(data);
    res.end();
  });
});
 
http.createServer(app).listen(app.get('port'), function(){
  console.log("Server listening on port " + app.get('port'));
});
