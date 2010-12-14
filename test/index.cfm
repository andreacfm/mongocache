<cfset dbCache = createObject("component","com.realistiq.Db").init('localhost:27017')>

<!---insert query and cache forever no tags--->
<cfset dbCache.doQuery('realistiq','select * from tags',0)>

