DBQuery.prototype._prettyShell = true;

var colsizes = function() {
    db.getCollectionNames().forEach(function(c) {
        stat=db.getCollection(c).stats();
        print(c, stat.size);
    });
};

