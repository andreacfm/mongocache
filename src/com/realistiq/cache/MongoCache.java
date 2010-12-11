package com.realistiq.cache;

import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.Mongo;
import com.mongodb.ServerAddress;

import java.io.IOException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;

public class MongoCache {

    private Mongo _mongo;
    private String DB_NAME = "com_realistiq_cache_db";
    private String COLL_NAME = "com_realistiq_cache_collection";
    private DB _db;
    private DBCollection _coll;

    public void init(String addresses){

        List<ServerAddress> addr = new ArrayList<ServerAddress>();
        String[] hosts = addresses.split("\\n");

        for(int i=0; i < hosts.length; i++){
            try {
                addr.add(new ServerAddress(hosts[i]));
            } catch (UnknownHostException e) {
                e.printStackTrace();
            }
        }

        _mongo = new Mongo(addr);
        _db = _mongo.getDB(DB_NAME);
        _coll = _db.getCollection(COLL_NAME);

        // drop the collection on startup
        _coll.drop();

    }

    public void put(String key,String value,int expires){

        /*
        make an upsert to store the object
        add expires metadata  {key,value,expires}
         */
    }

    public String get(String key) throws IOException{

        /*
        clear by expires time _clearExpired()
        get the value by key
        if nto found throw exception

         */
       return null;

    }

    public String clear(String pattern){

        /*
        clear by matching the pattern that is list and need to be splitted

         */
        return null;
    }



    private void _clearExpired(){

    }
}
