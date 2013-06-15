var http = require('http')
  , fs = require('fs')
  , jsonDir = fs.readdirSync('../json')

module.exports = function(app){
    app.get('/',function(req,res){
        res.render('index',{ 'title':'json Files','jsonDir':jsonDir})
    })

    jsonDir.forEach(function(file){
        app.get('/' + file, function(req,res){
            var fileContent = fs.readFileSync('../json/' + file, "utf8")
              , list = JSON.parse(fileContent)
            res.render('d',{
                'title':file
              , 'list':list
            })
        })
        app.post('/' + file, function(req,res){
            var obj = {}
              , val = {}
              , newList = ""

            val.val = req.body.val.split(',') || ""
            val.doc = req.body.doc
            obj[req.body.key] = val
            newList = JSON.stringify(obj)

            console.log(req.body.val)
            //fs.writeFile('../json/' + file,newList,function(err){ })
            res.redirect('/' + file)
        })
    })
};
