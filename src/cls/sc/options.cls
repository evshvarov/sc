/// options for sc.plugin
Class sc.options [ Abstract ]
{

ClassMethod storage()
{
	Q "^sc"
}

/// get settings
ClassMethod get(key, default = "")
{
	s storage = ..storage(), key = $g(key)
	Q:key="" $g(@storage, default)
	Q $g(@storage@(key), default)
}

/// save settings - return settings value after save
ClassMethod set(key, val)
{
	s key = $g(key), val = $g(val)
	s storage = ..storage()
	if key = "" { 
		s @storage = val
	} else {
		s @storage@(key) = val
	}
	Q ..get(key)
}

/// set or get working directory
/// by default - current namespace database directory
ClassMethod workdir(workdir)
{
	if $d( workdir ){
		set workdir=$tr(workdir,"\","/")
		if $E(workdir,*)="/" set workdir=$P(workdir,"/",1,*-1)
		Q ..set( "", workdir )			
	}
	s workdir=$tr($zu(12,""),"\","/")
	Q ..get( "", workdir )
}

/// get or set handlers for event
/// <var>handlers</var> - comma-separated value, for example:
/// ("aftercompile") = "sc.handler,test.sctestrunner"
ClassMethod handlers(ext, handlers)
{
	Q:'$d(ext) ""
	
	s storage = ..storage(), key = "ext"
	
	s:$d( handlers ) @storage@( key, ext ) = handlers ;set mode
	
	s handlers = $g( @storage@( key, ext ) ) ;get mode
	
	Q handlers
}

/// get or set classname for printer
ClassMethod printer(printer)
{
	s storage = ..storage(), key = "printer"
	s:$d(printer) @storage@(key) = printer
	Q $g(@storage@(key))
}

ClassMethod init() As %Status
{
	d ..workdir( ..workdir() )
	d ..handlers( "CLS", "sc.classes" )
	d ..handlers( "MAC", "sc.routines" ) 
	d ..handlers( "INT", "sc.routines" )
	d ..handlers( "INC", "sc.routines" )
	d ..handlers( "DFI", "sc.dfi" )
	d ..printer( "sc.printer" )
	Q 1
}

ClassMethod dump()
{
	s storage = ..storage()
	zw @storage
}

}

