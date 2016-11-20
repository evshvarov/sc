Class sc.plain.inc Extends sc.plain.routines
{

Method workdir()
{
	
	Q ##class(sc.options).get("workdirINC")
}

Method ignore() As %Boolean
{
	
	quit:##super() $$$YES
	quit:(..ext'="INC") $$$YES
	quit $$$NO
}

ClassMethod filemask()
{
	Q "*.INC"
}

}

