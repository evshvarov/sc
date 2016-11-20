/// [s]ource [c]ontrol plugin for InterSystems Caché (testing in v.2016.1) 
/// Just export or import to/from filesystem. Nothing more.
Class sc.plugin Extends %Studio.SourceControl.Base
{

/// Just sync.
/// <li>1 : Present dialog on check in</li>
/// <li>2 : Present dialog on check out</li>
/// <li>3 : Ask to add new item to source control</li>
/// <li>4 : Ask to remove deleted item from source control</li></ul>
Parameter Flags As STRING = 0000;

/// Workaround for error in %Studio.AbstractDocument:SaveStream()+16 
/// in Cache for Windows (x86-64) 2016.1 (Build 596U) Mon Nov 9 2015 21:12:55 EST
/// 
/// If the root node is set to 1 then calls to the source control hooks will keep track if the
/// source control hook modifies the document and if it does then it will defined
/// %SourceControl.Modified(docname)=1.
Property Modified As %String [ MultiDimensional ];

/// Import the file from the external format into Cache.
/// This is called before the actual load of data to give the chance
/// to load the item from an external format.
Method OnBeforeLoad(code As %String) As %Status
{
	s ..Modified = 0 ;workaround for error in %Studio.AbstractDocument:SaveStream()+16 
    Q ..on( "beforeload", code )
}

/// Called when Studio save something
Method OnAfterSave(code As %String, obj As %RegisteredObject = {$$$NULLOREF}) As %Status
{
    Q ..on( "aftersave" , code )
}

/// Called when Studio compile code 
/// and some parts of code may be changed
/// for example - storage scheme
Method OnAfterCompile(code As %String) As %Status
{
    Q ..on( "aftercompile", code ) ;only for additional export
}

/// Called when Studio delete code
Method OnAfterDelete(code As %String) As %Status
{
 	Q ..on( "afterdelete", code )
}

ClassMethod on(event, code)
{
	Q ##class(sc.classes).on( event, code )
}

ClassMethod install(ns = {$namespace}) As %Status
{
	#; v.2015 
	#; s sc = ##class(%Studio.SourceControl.Interface).SourceControlClassSet( $classname(), ns )
	
	#; workaround for 2012.2
	s ^%SYS("SourceControlClass",ns) = $classname()
	
	d ##class(sc.options).handlers( "CLS", "sc.classes" )
	d ##class(sc.options).handlers( "MAC", "sc.routines" ) 
	d ##class(sc.options).handlers( "INT", "sc.routines" )
	d ##class(sc.options).handlers( "INC", "sc.routines" )
	d ##class(sc.options).handlers( "DFI", "sc.dfi" )
	d ##class(sc.options).printer( "sc.printer" )
	Q 1
}

ClassMethod uninstall(ns = {$namespace}) As %Status
{
	#; v.2015
	#; s sc = ##class(%Studio.SourceControl.Interface).SourceControlClassSet( "", ns )
	
	#; workaround for 2012.2
	s ^%SYS("SourceControlClass",ns) = ""
	Q 1
}

}

