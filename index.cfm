<html>
	<head>
		<style >
			h1 {
			text-align: center;
		}
		</style>
	</head>
	<body onload="constructor()">
		<h1>Quick To Do List!</h1>
		
		<table id="inputtable" align="center" >
			<tr>
				<td>Task: </td><td><input type="text" name="task" id="task"></td>
			</tr>
			<tr>
				<td><button type="button" id="submit">Submit</button></td>
			</tr>
		</table>
		
		<table id="currentList" align="center">
			<tr>
				<th>Task Detail</th>
				<th>Done</th>
			</tr>
		</table>
	</body>
</html>

<script>
	function constructor(){
	//	constructor_cfml();
	}
	
	document.getElementById("submit").onclick = function(){
		addNewListItem();
	}
	
	
	function handleClick(rowId, done_cb){
		
		if (done_cb.checked){
			updateListItem (rowId, 1);
		} else{
			updateListItem (rowId, 0);
		}
		
	}
	
	function handleRemove(rowId){
		removeListItem(rowId);
		setTimeout("location.reload(true)", 10);
    	
	}
</script>


<cfclient>
	<cfset variables.dsn = "toDoListDB">
	<cfset variables.nextRowId = 0>
	
	<!--- create table --->
	<cfquery datasource="#variables.dsn#">
		create table if not exists toDoList (
			id integer primary key,
			task text,
			completed tinyint(1)
		)
	</cfquery>

	<!--- Get the to do items from the table --->
	<cfquery datasource="#variables.dsn#" name="toDo">
		select * from toDoList
	</cfquery>
	
	<cfloop query="toDo">
	<cfset addListItem(id,task,completed)>
    </cfloop>
    
    
    <cffunction name="removeListItem" >
    	<cfargument name="rowId" >
    	
    	<cfquery name="removeQuery" datasource="#variables.dsn#">
    		delete from toDoList where id=#rowId#
    	</cfquery>
    	
    	
    </cffunction>
    
    <cffunction name="updateListItem" >
    	<cfargument name="rowId" >
    	<cfargument name="done_cb_val" >
    	
    	<cfset var newstatus = Number(done_cb_val)>
    	
    	<cfquery name="update_query" datasource="#variables.dsn#">
    	   update toDoList set 	completed=#newstatus# where id=#rowId#
    	</cfquery>
    	
    	
    	
    </cffunction>
    
    <cffunction name="addListItem">
    	<cfargument name="rowId" >
    	<cfargument name="task" >
    	<cfargument name="completed" >
    	
    	<cfif completed eq 1>
    		<cfoutput>
    		<cfsavecontent variable="listItemHTML" >
    			<tr>
    				<td>#task#</td>
    				<td><label><input type="checkbox" name="done" id="done_cb" onClick="handleClick(#rowId#,this)" checked/></label></td>
    				<td><button type="button" id="remove" onclick="handleRemove(#rowId#)">Remove</button></td>	
    			</tr>
    		</cfsavecontent>
    	    </cfoutput>
    	<cfelse>
    	  <cfoutput>
    		<cfsavecontent variable="listItemHTML">
    			<tr>
    				<td>#task#</td>
    				<td><label><input type="checkbox" name="done" id="done_cb" onClick="handleClick(#rowId#,this)" /></label></td>
    				<td><button type="button" id="remove" onclick="handleRemove(#rowId#)">Remove</button></td>
    			</tr>
    		</cfsavecontent>
    	  </cfoutput>
    	</cfif> 
    	
    	
    	
    	<cfset document.getElementById("currentList").innerHTML += listItemHTML>
    </cffunction>
    
    <cffunction name="addNewListItem">
    	<cfset var newTask = document.getElementById("task").value>
    	<cfset var iscompleted = Number(0)>
    	
    	<cfquery datasource="#variables.dsn#" name="insert_query">
    		insert into toDoList (task,completed) values(
    			<cfqueryparam cfsqltype="cf_sql_varchar" value="#newTask#">,
    			<cfqueryparam cfsqltype="cf_sql_numeric" value="#iscompleted#">
    		)
    	</cfquery>
    	
    	<cfquery datasource="#variables.dsn#" name="lastRowId" maxrows="1">
    		select MAX(id) as finalid from toDoList
    	</cfquery>
    	
    	<cfloop query="lastRowId">
    		<cfset var lastId = finalid>
    	</cfloop>

    	
    	<cfset addListItem(lastId,newTask,iscompleted)>
    </cffunction>
    
</cfclient>