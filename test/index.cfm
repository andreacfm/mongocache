<cfset dbLib = createObject("component","com.realistiq.db")>

<cftimer label="db.cfc">
	<cfloop from="1" to="10" index="i">
		<cfset retVal = dbLib.doQuery("iq_cb_premier_realty","Select Top 10 * FROM Residential",CreateTimespan(0,0,0,30),"Residential")>

		<cfif retVal.Status EQ 1>
			<cfthrow message="#retVal.Message#" detail="#retVal.Detail#">
		</cfif>
	</cfloop>
</cftimer>

<cfset dblib.doClear("iq_cb_premier_realty","residential")>