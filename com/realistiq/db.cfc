<cfcomponent output="no">

	<cffunction name="doQuery" access="public" returntype="any">
		<cfargument name="datasource" required="true" type="string">
		<cfargument name="sql" required="true" type="string">		
		<cfargument name="cachedwithin" required="false" type="numeric" default="-1">
		<cfargument name="tablelist" required="false" type="string" default="">
		<cfargument name="blockfactor" required="false" type="numeric" default="0">

		<cfset var LOCAL = {}>

		<cfset LOCAL.retVal = {}>
		<cfset LOCAL.retVal.Status = 0>
		<cfset LOCAL.retVal.Message = "Process complete.">
		<cfset LOCAL.retVal.Detail = "">
		<cfset LOCAL.retVal.Content = {}>

		<cftry>
			<cfset LOCAL.key = Hash(ARGUMENTS.sql)>
			<cfset LOCAL.collection = LCase(ARGUMENTS.datasource)>

			<cftrace category="doQuery" text="Before _cacheGet()">

			<cfset LOCAL.getCacheStart = GetTickCount()>
			<cfset LOCAL.recordSet = _cacheGet(LOCAL.key, LOCAL.collection)>
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

				<cfif ARGUMENTS.cachedWithin NEQ -1>
					<cfset _cachePut(LOCAL.key, LOCAL.recordSet, ARGUMENTS.cachedWithin, LOCAL.collection, ARGUMENTS.tableList)>
				</cfif>
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

	<cffunction name="doClear" access="public" returntype="void">
		<cfargument name="Datasource" type="string" required="true">
		<cfargument name="Tables" type="string" required="yes">

		<cfset var LOCAL = {}>

		<cfset LOCAL.Collection = LCase(ARGUMENTS.Datasource)>

		<cfif ARGUMENTS.Tables CONTAINS ",">
			<cfset _getMongo().remove({ "tables" : { "$in" : ListToArray(LCase(ARGUMENTS.Tables)) } }, LOCAL.Collection)>
		<cfelse>
			<cfif ARGUMENTS.Tables NEQ "">
				<cfset _getMongo().remove({ "tables" : LCase(ARGUMENTS.Tables) }, LOCAL.Collection)>
			<cfelse>
				<cfset _getMongo().remove({}, LOCAL.Collection)>
			</cfif>
		</cfif>

		<cfreturn>
	</cffunction>

	<cffunction name="_getMongo" access="private" returntype="any">
		<cfif NOT StructKeyExists(APPLICATION,"mongo")>
			<cfset LOCAL.dbName = "query_cache">
			<cfset LOCAL.javaloaderFactory = createObject('component','global.components.cfmongodb.core.JavaloaderFactory').init()>
			<cfset LOCAL.mongoConfig = createObject('component','global.components.cfmongodb.core.MongoConfig').init(dbName=LOCAL.dbName, mongoFactory=LOCAL.javaloaderFactory)>
			<cfset APPLICATION.mongo = createObject('component','global.components.cfmongodb.core.Mongo').init(LOCAL.mongoConfig)>
		</cfif>

		<cfreturn APPLICATION.mongo>
	</cffunction>

	<cffunction name="_formatDate" access="private" returntype="string">
		<cfargument name="Date" type="date" required="yes">
	
		<cfreturn DateFormat(ARGUMENTS.Date,"yyyymmdd") & TimeFormat(ARGUMENTS.Date,"hhmmss")>
	</cffunction>
	
	<cffunction name="_cacheGet" access="private" returntype="any">
		<cfargument name="Key" type="string" required="yes">
		<cfargument name="Collection" type="string" required="yes">

		<cfset var LOCAL = {}>

		<cfset tStart = getTickCount()>
		<cftrace category="_cacheGet" text="Before Expire">
		<cfset _cacheExpire(ARGUMENTS.Collection)>
		<cftrace category="cacheGet" text="After Expire #getTickCount() - tStart#">
	
		<cfset tStart = getTickCount()>
		<cftrace category="_cacheGet" text="Before search">
		<cfset LOCAL.results = _getMongo().query(ARGUMENTS.Collection).$eq("key",ARGUMENTS.Key).search()>
		<cftrace category="_cacheGet" text="After search #getTickCount() - tStart#">
	
		<cfset tStart = getTickCount()>
		<cftrace category="_cacheGet" text="Before array">
		<cfset LOCAL.aResults = LOCAL.results.asArray()>
		<cftrace category="_cacheGet" text="After array #getTickCount() - tStart#">

		<cfif ArrayLen(LOCAL.aResults) EQ 1>
			<cfreturn DESerializeJSON(LOCAL.aResults[1].data, false)>
		</cfif>

		<cfreturn "">
	</cffunction>
	
	<cffunction name="_cachePut" access="private" returntype="void">
		<cfargument name="Key" type="string" required="yes">
		<cfargument name="Data" type="any" required="yes">
		<cfargument name="CachedWithin" type="any" required="yes">
		<cfargument name="Collection" type="string" required="yes">
		<cfargument name="Tables" type="string" required="yes">
	
		<cfset var LOCAL = {}>
	
		<cfset LOCAL.ts = Now()>
	
		<cfif IsQuery(ARGUMENTS.Data) || IsStruct(ARGUMENTS.Data) || IsArray(ARGUMENTS.Data)>
			<cfset ARGUMENTS.Data = SerializeJSON(ARGUMENTS.Data, false)>
		</cfif>
	
		<cfset LOCAL.doc = {}>
		<cfset LOCAL.doc['key'] = ARGUMENTS.Key>
		<cfset LOCAL.doc['timestamp'] = _formatDate(ts)>
		<cfset LOCAL.doc['expires'] = _formatDate(ts + ARGUMENTS.CachedWithin)>
	
		<cfif ARGUMENTS.Tables NEQ "">
			<cfset LOCAL.doc['tables'] = ListToArray(LCase(ARGUMENTS.Tables))>
		<cfelse>
			<cfset LOCAL.doc['tables'] = "">
		</cfif>
	
		<cfset LOCAL.doc['data'] = ARGUMENTS.Data>
	
		<cfset _getMongo().save(LOCAL.doc, ARGUMENTS.Collection)>
		<cfset _cacheExpire(ARGUMENTS.Collection)>
	
		<cfreturn>
	</cffunction>

	<cffunction name="_cacheExpire" access="private" returntype="void">
		<cfargument name="Collection" type="string" required="yes">
	
		<cfset var LOCAL = {}>
	
		<cfset _getMongo().remove({ "expires" : { "$lt" : _formatDate(Now()) } }, ARGUMENTS.Collection)>
		
		<cfreturn>
	</cffunction>
</cfcomponent>