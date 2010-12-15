component extends="mxunit.framework.TestCase"{


	public void function setUp(){
		_mc = createObject("com.realistiq.cache.MongoCache").init("localhost:27017");
	}

	public void function tearDown(){
        _mc.flush();
	}

    public void function test_cache_put_string(){
        var str =  'Andrea';
        _mc.cachePut('key',str);
        var res = _mc.cacheGet('key');
        assertTrue(res eq str);
    }

    public void function test_cache_put_struct(){
        var str =  {name = 'Andrea'};
        _mc.cachePut('key',str);
        var res = _mc.cacheGet('key');
        assertTrue(res.name eq str.name);
    }

    public void function test_cache_exists(){
        var str =  {name = 'Andrea'};
        _mc.cachePut('key',str);
        assertTrue(_mc.cacheExists('key'));
        assertTrue(not _mc.cacheExists('do_not_exists'));

    }

    public void function test_cache_expire(){
        var str =  {name = 'Andrea'};
        _mc.cachePut('key',str,2);
        assertTrue(_mc.cacheExists('key'));
        sleep(4000);
        assertTrue(not _mc.cacheExists('key'));

    }

    public void function test_clear_tags(){

        _mc.cachePut('key1','value1',0,'one,two');
        _mc.cachePut('key2','value1',0,'three,four');

        assertTrue(_mc.cacheExists('key1'));
        assertTrue(_mc.cacheExists('key2'));

        _mc.clearTags('four');
        assertTrue(_mc.cacheExists('key1'));
        assertTrue(not _mc.cacheExists('key2'));

        _mc.cachePut('key3','value1',0,'one,two');
        _mc.cachePut('key4','value1',0,'three,four');

        assertTrue(_mc.cacheExists('key3'));
        assertTrue(_mc.cacheExists('key4'));

        _mc.clearTags('one,four');
        assertTrue(not _mc.cacheExists('key3'));
        assertTrue(not _mc.cacheExists('key4'));

    }

}
