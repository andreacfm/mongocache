<cfparam name="URL.output" default="extjs">
<cfscript>	
 testSuite = createObject("component","mxunit.framework.TestSuite").TestSuite();
 testSuite.addAll("test.test_mongo_cache");
 testSuite.addAll("test.test_db_cache");
 results = testSuite.run();
</cfscript>
<cfoutput>#results.getResultsOutput(URL.output)#</cfoutput>
