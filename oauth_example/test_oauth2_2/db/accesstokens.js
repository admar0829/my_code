var tokens = {};


exports.find = function(key, done) {
  var token = tokens[key];
  return done(null, token);
};

exports.save = function(token, userID, clientID, done) {
  console.log ("--------" + token);
  tokens[token] = { userID: userID, clientID: clientID };
  return done(null);
};
