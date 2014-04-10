var express = require('express');
var passport = require('passport');
var util = require('util');
var oauth2 = require('./oauth2');

var app = express();
app.use(express.cookieParser());
app.use(express.bodyParser());

app.use(passport.initialize());
app.use(passport.session());
app.use(app.router);

require('./auth');

app.post('/oauth/token', oauth2.token);

app.get('/api/clientinfo', oauth2.info);

app.listen(3000);
console.log("Now listening port 3000.........");