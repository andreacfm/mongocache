component{

    import path "com.realistiq.cache.*";

    public MongoCache function getInstance(){
        if(not structKeyExists(application,'com_realistiq_cache_mongocache')){
            _init(argumentCollection=arguments);
        }
        return application.[com_realistiq_cache_mongocache];
    }

    private void function init(String addresses){
        var driver = createObject('java'.'com.realistiq.cache.MongoCache').init(arguments.addresses);
        application.[com_realistiq_cache_mongocache] = driver;
    }

}