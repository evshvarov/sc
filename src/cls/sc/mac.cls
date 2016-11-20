Class sc.mac Extends sc.routines
{

Method workdir()
{
	
	Q ##class(sc.options).get("workdirMAC")
}

Method ignore() As %Boolean
{
	
	quit:##super() $$$YES
	quit:(..ext'="MAC") $$$YES
	quit $$$NO
}

ClassMethod filemask()
{
	Q "*.MAC.xml"
}

}

