var express = require('express');
var app = express.createServer();

app.configure(function(){
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.get('/', function(req, res){
    res.sendfile('index_dev.html');
  });
  app.listen(80);
});

app.configure('production', function(){
  app.get('/', function(req, res){
    res.sendfile('index.html');
  });
  app.listen(8080);
});
