Class sc.plain.int Extends sc.plain.routines
{

Method workdir()
{
	
	Q ##class(sc.options).get("workdirINT")
}

Method ignore() As %Boolean
{
	
	quit:##super() $$$YES
	quit:(..ext'="INT") $$$YES
	quit $$$NO
}

ClassMethod filemask()
{
	Q "*.INT"
}

}

