/// Change options for plain handlers (export/import in udl format)
Class sc.plain.plugin Extends sc.plugin
{

ClassMethod install() As %Status
{
	
	d ##super()
	
	#define handlers( %ext, %handler ) d ##class(sc.options).handlers( %ext, %handler )
	
	$$$handlers("CLS", "sc.plain.classes")
	$$$handlers("MAC", "sc.plain.routines")	
	$$$handlers("INT", "sc.plain.routines")	
	$$$handlers("INC", "sc.plain.routines")	
	$$$handlers("DFI", "sc.dfi")	
	d ##class(sc.options).printer("sc.printer")
	
	Quit 1
}

}

