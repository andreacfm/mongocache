component{

    import "com.realistiq.cache.*";

    public com.realistiq.cache.MongoCache function init(String addresses){
        variables.driver = createObject('java','com.realistiq.cache.MongoCache').init(arguments.addresses);
        return this;
    }

    public any function cacheGet(String key){
        var result = variables.driver.get(key);
        return  deserializeJSON(result,false);
    }

    public boolean function cacheExists(String key){
        return variables.driver.exists(key);
    }

    public void function cachePut(String key, Any data, Numeric lifespan=0, String tags=""){
        var tagsArray = listToArray(tags);
        var json = serializeJSON(data,true);
        variables.driver.put(key,json,lifespan,tagsArray);
    }

    public void function clearTags(String tags){
        variables.driver.clearTags(tags);
    }

    public void function flush(){
        variables.driver.flush();
    }

}