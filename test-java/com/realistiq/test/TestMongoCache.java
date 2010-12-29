package com.realistiq.test;

import com.mongodb.*;
import com.realistiq.cache.MongoCache;
import org.junit.*;
import junit.framework.JUnit4TestAdapter;
import org.omg.CORBA.portable.Streamable;

import java.io.IOException;
import java.util.ArrayList;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

public class TestMongoCache {

    private MongoCache _mc;
    private String host = "localhost:27017";
    private String db = "realistiq_db";
    private String coll = "realistiq_collection";

    @Before
    public void setUp() {
        _mc = new MongoCache(host,db,coll);
    }

    @After
    public void tearDown() {
        _mc.flush();
    }

    @Test
    public void testInit() {

        try{
            _mc.get_mongo().getDatabaseNames();
        }catch (Exception e){
            fail("Mongo is not connected");
        }

    }

    @Test
    public void test_put_a_simple_string(){

        String key = "mykey";
        String value = "Andrea";
        int lifespan = 0;

        //put
        _mc.put(key,value,lifespan,new ArrayList());

        // read from underline mongo instance
        BasicDBObject q = new BasicDBObject("key",key);
        DBCollection coll = _mc.get_coll();
        DBObject obj = coll.findOne(q);

        assertTrue(obj.get("key").equals(key));

    }

    @Test
    public void test_clear_expired(){

        DBCollection coll = _mc.get_coll();

        String key1 = "one";
        String value1 = "value one";
        int lifespan1 = 0;    // never expire

        //put object 1
        _mc.put(key1,value1,lifespan1,new ArrayList());

        String key2 = "two";
        String value2 = "value two";
        int lifespan2 = 1;

        //put object 2
        _mc.put(key2,value2,lifespan2,new ArrayList());

        String key3 = "three";
        String value3 = "value three";
        int lifespan3 = 60;  // expire in 60 sec

        //put object 3
        _mc.put(key3,value3,lifespan3,new ArrayList());

        //sleep one sec
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        //clear expired
        _mc.clearExpired();

        // read from underline mongo instance object 1 must be still alive
        BasicDBObject q = new BasicDBObject("key",key1);
        DBCursor cur = coll.find(q);
        System.out.println(cur.size());
        assertTrue(cur.size() == 1);

        //object 2 should be gone
        BasicDBObject q2 = new BasicDBObject("key",key2);
        DBCursor cur2 = coll.find(q2);
        System.out.println(cur2.size());
        assertTrue(cur2.size() == 0);

        //object 3 should be here
        BasicDBObject q3 = new BasicDBObject("key",key3);
        DBCursor cur3 = coll.find(q3);
        System.out.println(cur3.size());
        assertTrue(cur3.size() == 1);

    }

    @Test
    public void test_get(){

        String key = "mykey";
        String value = "Andrea";
        int lifespan = 0;
        String res = "";

        //put
        _mc.put(key,value,lifespan,new ArrayList());

        try {
            res = _mc.get(key);
        } catch (IOException e) {
            e.printStackTrace();
        }

        assertTrue(res.equals(value));
    }


    @Test
    public void test_get_must_fail_end_throw_exception(){

        try {
            _mc.get("key");
            fail("Key does not exists. get method should raise an exception");
        } catch (IOException e) {

        }

    }

    @Test
    public void test_exists(){

        _mc.put("mykey","andrea");

        assertTrue(_mc.exists("mykey"));
        assertTrue(!_mc.exists("another_key"));

    }

    @Test
    public void test_clear_tags(){

        ArrayList tags = new ArrayList();
        tags.add("one");
        tags.add("two");
        tags.add("three");

        _mc.put("mykey","value",0,tags);

        // inserted ?
        assertTrue(_mc.exists("mykey"));

        //clear by wrong tags
        _mc.clearTags("four,five");

        // still exists ?
        assertTrue(_mc.exists("mykey"));

        //clear
        _mc.clearTags("one,two");

        // should be gone
        assertTrue(!_mc.exists("mykey"));

    }

}
