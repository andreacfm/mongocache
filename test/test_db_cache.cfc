component extends="mxunit.framework.TestCase"{

    include "settings.cfm";

	public void function setUp(){
		_db = createObject("com.realistiq.Db").init("localhost:27017");
	}

	public void function tearDown(){
 	}

    public void function test_no_expire(){
        var res = _db.doQuery(dsn,sql);
        //first is not in cache
        assertTrue(!res.result.cached);
        var res2 = _db.doQuery(dsn,sql);
        //now must be cached
        assertTrue(res2.result.cached);

    }

    public void function test_expire(){
        var res = _db.doQuery(dsn,sql,2);
        //first is not in cache
        assertTrue(!res.result.cached);
        var res2 = _db.doQuery(dsn,sql);
        //now must be cached
        assertTrue(res2.result.cached);

        sleep(4000);
        var res3 = _db.doQuery(dsn,sql);
        assertTrue(!res3.result.cached);

    }

    public void function test_clear_tags(){

        var res = _db.doQuery(dsn,sql,0,'one,two');
        //first is not in cache
        assertTrue(!res.result.cached);
        var res2 = _db.doQuery(dsn,sql);
        //now must be cached
        assertTrue(res2.result.cached);


        _db.clearTags('one');
        var res3 = _db.doQuery(dsn,sql);
        assertTrue(!res3.result.cached);

    }

}
