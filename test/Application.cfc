component{

    public function onApplicationStart(){
        application.dbCache = createObject("component","com.realistiq.Db").init('localhost:27017');
    }

    public function onRequestStart(){
        if(structKeyExists(url,'reinit')){
            onApplicationStart();
        }
    }
}