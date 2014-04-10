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

server.grant(oauth2orize.grant.code(function(client, redirectURI, user, ares, done) {
  var code = utils.uid(16)
  console.log("1");
  db.authorizationCodes.save(code, client.id, redirectURI, user.id, function(err) {
    if (err) { return done(err); }
    done(null, code);
  });
}));


server.exchange(oauth2orize.exchange.code(function(client, code, redirectURI, done) {
  console.log("3");
  db.authorizationCodes.find(code, function(err, authCode) {
    if (err) { return done(err); }
    if (client.id !== authCode.clientID) { return done(null, false); }
    if (redirectURI !== authCode.redirectURI) { return done(null, false); }
    
    var token = utils.uid(256)
    db.accessTokens.save(token, authCode.userID, authCode.clientID, function(err) {
      if (err) { return done(err); }
      done(null, token);
    });
  });
}));


server.grant(oauth2orize.grant.token(function(client, user, ares, done) {
    var token = utils.uid(256);
	console.log("2");
    db.accessTokens.save(token, user.id, client.clientId, function(err) {
        if (err) { return done(err); }
        done(null, token);
    });
}));

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

exports.authorization = [
  //login.ensureLoggedIn(),
  server.authorization(function(clientID, redirectURI, done) {
	  console.log(clientID);
	  console.log(redirectURI);
    db.clients.findByClientId(clientID, function(err, client) {
      if (err) { return done(err); }
      // WARNING: For security purposes, it is highly advisable to check that
      //          redirectURI provided by the client matches one registered with
      //          the server.  For simplicity, this example does not.  You have
      //          been warned.
	  console.log("authorization")
      return done(null, client, redirectURI);
    });
  }),
  //*here need to send the transactionID to transactionLoader.
  function(req, res) {
  	  var url = '/dialog/authorize/decision?transaction_id=' + req.oauth2.transactionID
  	  res.redirect(url);
  }
  //or if we dont want to use the transaction loader, uncomment this and comment above function.
	//   server.decision({loadTransaction: false}, function(req, done) {
	// console.log("decision");
	// console.log(req.oauth2);
	// return done(null, {allow: true})
	//   })
]

exports.decision = [
  //login.ensureLoggedIn(),
  server.decision(function(req, done) {
	  console.log("============");
	  console.log(req.oauth2);
	  console.log("============");
	  return done(null, {allow: true});
  })
]

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

exports.login = passport.authenticate('local', { successReturnToOrRedirect: '/', failureRedirect: '/message' });


exports.message = function(req, res) {
	res.send('Please login again...');
};

exports.index = function(req, res) {
  res.send('OAuth 2.0 Server');
};