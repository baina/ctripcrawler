var crypto = require('crypto');

var Safe = function(){
};

exports.Safe = Safe;

Safe.prototype.MD5 = function(str){
	var md5sum = crypto.createHash('md5');
    md5sum.update(str);
    str = md5sum.digest('hex');
    return str;
};
