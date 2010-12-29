<cfsetting showdebugoutput="false">
<h1>Fast test</h1>

<cfset start = getTickCount()>
<cfloop from="1" to="1000" index="i">
    <cfset res = application.dbCache.doQuery('realistiq','select * from tags',0)>
</cfloop>
<cfset end = getTickCount()>

<cfset time = end -start >
<cfoutput>#time#</cfoutput>

