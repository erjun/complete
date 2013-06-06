var http = require('http');
var fs = require('fs');
var file = fs.readFileSync('../json/css.json', "utf8");
var list = JSON.parse(file)
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'css',list:list });
};
