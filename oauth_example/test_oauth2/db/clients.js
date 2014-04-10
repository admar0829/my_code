var clients = [
    { id: '1', name: 'Yuwei', clientId: 'yx49304', clientSecret: 'Citibank2014' },
    { id: '2', name: 'Kevin', clientId: 'kevin', clientSecret: 'Citibank2014' }
];


exports.find = function(id, done) {
  for (var i = 0, len = clients.length; i < len; i++) {
    var client = clients[i];
    if (client.id === id) {
      return done(null, client);
    }
  }
  return done(null, null);
};

exports.findByClientId = function(clientId, done) {
  for (var i = 0, len = clients.length; i < len; i++) {
    var client = clients[i];
    if (client.clientId === clientId) {
      return done(null, client);
    }
  }
  return done(null, null);
};
