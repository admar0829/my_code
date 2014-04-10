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

server.exchange(oauth2orize.exchange.password(function(client, username, password, scope, done) {
    //Validate the client
    db.clients.findByClientId(client.clientId, function(err, localClient) {
        if (err) { return done(err); }
        if(localClient === null) {
            return done(null, false);
        }
        if(localClient.clientSecret !== client.clientSecret) {
            return done(null, false);
        }
        //Validate the user
        db.users.findByUsername(username, function(err, user) {
            if (err) { return done(err); }
            if(user === null) {
                return done(null, false);
            }
            if(password !== user.password) {
                return done(null, false);
            }
            //Everything validated, return the token
            var token = utils.uid(256);
			db.accessTokens.save(token, user.id, client.clientId, function(err) {
                if (err) { return done(err); }
                done(null, token);
            });
        });
    });
}));

server.exchange(oauth2orize.exchange.clientCredentials(function(client, scope, done) {
	//Validate the client
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

exports.token = [
passport.authenticate('basic', { session: false}),
server.token(),
server.errorHandler()
]

//Both resource owner password credential and client credential grant types involving authenticating the clientid/password, get client's information here.
exports.clientInfo = [
    passport.authenticate('bearer', { session: false }),
    function(req, res) {
        res.json({ client_id: req.user.clientId, name: req.user.name, scope: req.authInfo.scope, message: "Hello world!" })
    }
]

exports.userInfo = [
  passport.authenticate('bearer', { session: false }),
  function(req, res) {
    // req.authInfo is set using the `info` argument supplied by
    // `BearerStrategy`.  It is typically used to indicate scope of the token,
    // and used in access control checks.  For illustrative purposes, this
    // example simply returns the scope in the response.
    res.json({ user_id: req.user.id, name: req.user.name, scope: req.authInfo.scope })
  }
]