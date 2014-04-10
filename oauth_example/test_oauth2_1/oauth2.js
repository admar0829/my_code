var oauth2orize = require('oauth2orize');
var passport = require('passport');
var db = require('./db');
var url = require('url');
var utils = require('./utils');
var crypto = require('crypto');

var server = oauth2orize.createServer();

server.serializeClient(function(client, done) {
  return done(null, client.id);
});

server.deserializeClient(function(id, done) {
  db.clients.find(id, function(err, client) {
    if (err) { return done(err); }
    return done(null, client);
  });
});

server.exchange(oauth2orize.exchange.clientCredentials(function(client, scope, done) {
	db.clients.findByClientId(client.clientId, function(err, localClient) {
		if (err) {
			return done(err);
		}
		if (localClient === null) {
			return done(null, false);
		}
		if (localClient.clientSecret !== client.clientSecret) {
			return done(null, false);
		}
		var token = utils.uid(256);
		db.accessTokens.save(token, null, client.clientId, function(err) {
			if (err) {
				return done(err);
			}
			done(null, token);
		});
	});
}));

var issueToken = function(req, done) {
	console.log(crypto.getCiphers());
	//var client = req.user;
	var clientId = req.get('clientId');
	var clientSecret = req.get('clientSecret');
	db.clients.findByClientId(clientId, function(err, localClient) {
		if (err) {
			return done(err);
		}
		if (localClient === null) {
			return done(null, false);
		}
		if (localClient.clientSecret !== clientSecret) {
			return done(null, false);
		}
		console.log(req.get('resource'));
		var resource = req.get('resource');
		var host = url.parse(resource).host;
		var original;
		var keychain;
		// find host name register with auth server, if exist, get the keychain of the host;
		if (host === "localhost:3001") {
			original = {"host": host, "permission": "YES"};
			keychain = 'keychain';
			//console.log(original);
		    var cipher = crypto.createCipher('aes-256-cbc', keychain);
			var token = cipher.update(JSON.stringify(original), 'utf8', 'base64');
			token = token + cipher.final('base64');
			
			//var token = new Buffer(JSON.stringify(original)).toString('base64');
			db.accessTokens.save(token, null, clientId, function(err) {
				if (err) {
					return done(err);
				}
				return done(null, token);
			});
		} else {
			//original = {"host": host, "permission": "NO"};
			return done(null, null);
		}
	});	
}

exports.token = [
//passport.authenticate('basic', { session : false }),
function(req, res) {
	issueToken (req, function(err, token) {
		if (!err && token) {
			res.json({"access_token": token});
		} else {
			res.send("unauthorised");
		}
	});
}
]

// exports.token = [
// passport.authenticate('basic', { session: false}),
// server.token(),
// server.errorHandler()
// ]


exports.info = [
    passport.authenticate('bearer', { session: false }),
    function(req, res) {
        res.json({ client_id: req.user.clientId, name: req.user.name, message: "Hello world!" })
    }
]