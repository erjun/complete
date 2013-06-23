var http = require('http')
  , fs = require('fs')
  , jsonDir = fs.readdirSync('../json')

module.exports = function(app){
    // 首页
    app.get('/',function(req,res){
        res.render('index',{ 'title':'json Files','jsonDir':jsonDir})
    })

    // 详情页
    jsonDir.forEach(function(file){
        // 列出
        app.get('/' + file, function(req,res){
            var fileContent = fs.readFileSync('../json/' + file, "utf8")
              , list = JSON.parse(fileContent)
            res.render('d',{
                'title':file
              , 'list':list
            })
        })
        // 修改提交
        app.post('/' + file, function(req,res){
            var obj = {}
              , val = {}
              , newList = ""

            console.log(req.body.val)
            //obj[req.body.key] = val
            //newList = JSON.stringify(obj)

            //fs.writeFile('../json/' + file,newList,function(err){ })
            res.redirect('/' + file)
        })
    })
};
