# insert query and cache forever <br/>
# no tags <br>/
# should be cache from second call <br/>

<cfset res = application.dbCache.doQuery('realistiq','select * from tags',0)>
<cfdump var="#res#"/>
