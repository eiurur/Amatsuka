(function() {
  var my, path;

  path = require('path');

  my = require(path.resolve('build', 'lib', 'my')).my;

  module.exports = function(app) {
    return app.post('/api/download', function(req, res) {
      console.log("\n========> download, " + req.body.url + "\n");
      return my.loadBase64Data(req.body.url).then(function(base64Data) {
        console.log('base64toBlob', base64Data.length);
        return res.json({
          base64Data: base64Data
        });
      });
    });
  };

}).call(this);
