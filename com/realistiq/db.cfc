<cfcomponent output="no" extends="com.realistiq.cache.MongoCache">

	<cffunction name="doQuery" access="public" returntype="any">
		<cfargument name="datasource" required="true" type="string">
		<cfargument name="sql" required="true" type="string">		
		<cfargument name="lifespan" required="false" type="numeric" default="0">
		<cfargument name="tablelist" required="false" type="string" default="">
		<cfargument name="blockfactor" required="false" type="numeric" default="0">

		<cfset var LOCAL = {}>
		<cfset var LOCAL.recordset = "">

		<cfset LOCAL.retVal = {}>
		<cfset LOCAL.retVal.Status = 0>
		<cfset LOCAL.retVal.Message = "Process complete.">
		<cfset LOCAL.retVal.Detail = "">
		<cfset LOCAL.retVal.Content = {}>

		<cftry>
			<cfset LOCAL.key = Hash(ARGUMENTS.sql)>

			<cftrace category="doQuery" text="Before _cacheGet()">
			<cfset LOCAL.getCacheStart = GetTickCount()>
			<cfif this.cacheExists(LOCAL.key)>
			    <cfset LOCAL.recordSet = this.cacheGet(LOCAL.key)>
			</cfif>
			<cfset LOCAL.getCacheEnd = GetTickCount()>

			<cftrace category="doQuery" text="After _cacheGet() (#LOCAL.getCacheEnd - LOCAL.getCacheStart# ms)">

			<cfif NOT IsSimpleValue(LOCAL.recordSet)>
				<cftrace category="doQuery" text="Cached">

				<cfset LOCAL.result = {}>
				<cfset LOCAL.result.cached = true>
				<cfset LOCAL.result.key = LOCAL.key>
				<cfset LOCAL.result.columnlist = LOCAL.recordSet.columnlist>
				<cfset LOCAL.result.executiontime = LOCAL.getCacheEnd - LOCAL.getCacheStart>
				<cfset LOCAL.result.sql = ARGUMENTS.sql>
			<cfelse>
				<cftrace category="doQuery" text="Not Cached">

				<cfquery name="LOCAL.recordset" datasource="#ARGUMENTS.datasource#" result="LOCAL.result" blockfactor="#ARGUMENTS.blockfactor#">
					#PreserveSingleQuotes(ARGUMENTS.sql)#
				</cfquery>

				<cfset LOCAL.result.key = LOCAL.key>
				<cfset this.cachePut(LOCAL.key,LOCAL.recordSet, ARGUMENTS.lifespan, ARGUMENTS.tableList)>
			</cfif>

			<cfset LOCAL.retVal.recordSet = LOCAL.recordSet>
			<cfset LOCAL.retVal.result = LOCAL.result>

			<cfcatch type="any">
				<cfsavecontent variable="tmpCFDump">
					<cfdump var="#CFCatch#">
				</cfsavecontent>

				<cfset LOCAL.retVal.Status = 1>
				<cfset LOCAL.retVal.Message = CFCatch.Message>
				<cfset LOCAL.retVal.Detail = CFCatch.Detail>
				<cfset LOCAL.retVal.Content = tmpCFDump>
			</cfcatch>
		</cftry>

		<cfreturn LOCAL.retVal>
	</cffunction>


</cfcomponent>