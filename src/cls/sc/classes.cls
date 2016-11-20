/// export/import *.cls documents into/from xml files ( *.CLS.xml )
Class sc.classes Extends %RegisteredObject
{

Property event;

/// document name ( with extension )
/// for example: package.class.CLS
Property code;

Method codeSet(code) As %Status
{
	
	s i%code = code
	s i%name = ..nameExtract( code ) 
	s i%ext = ..extExtract( code )
	Q 1
}

Property name [ ReadOnly ];

Property ext [ ReadOnly ];

Property printer As sc.printer [ InitialExpression = {##class(sc.printer).new()} ];

/// This callback method is invoked by the <METHOD>%New</METHOD> method to 
/// provide notification that a new instance of an object is being created.
Method %OnNew(code, event, printer As sc.printer = {##class(sc.printer).new()}) As %Status [ Private, ServerOnly = 1 ]
{
	
	s ..code = code, ..event = event, ..printer = printer
	Quit $$$OK
}

/// Read settings and run event handlers
ClassMethod on(event, code) As %Status
{
	s ext = ..extExtract( code )
	s list = ##class(sc.options).handlers( ext ) ;handlers list for event
	
	s printer = ##class(sc.printer).new() ;read settings or return default
	
	if ( list = "" ) {
		
		s msg = event _ "( " _ code _" ). Warning: handlers for '"_ext_"' not set!"
		d printer.warn( msg )
		Q 1
		
	} 
	
	s list = $ListFromString( list )
	
	s sc = $$$OK, ptr=0, class = ""
	while $LISTNEXT( list, ptr, class )  { 
		
		s handler = $classmethod( class, "%New", code, event, printer )
		
		if '$IsObject( handler ) {
			d printer.error( "Error! Can't create handler " _ handler )
			continue  
		}
		
		s sch = handler.handle()
		
		do $system.Status.AppendStatus( sc, sch )
		
	}
	
	Quit sc
}

Method handle() As %Status
{
 
 	d ..printer.trace( ..event_"( "_..code _ " )" )
 	
 	Q:..ignore() 1 
	
	s filename = ..filename()
	
	if ..event = "afterdelete" {
		s sc = ..fileDelete( filename )
		d ..printer.w( "Delete " _ filename, sc )
		Q sc
	}
	
	#; change events  - beforeload, aftersave, aftercompile
	s tsFile = ..tsFile( filename ), tsCode = ..tsCode() ;ts - timeStamp
	
	d ..printer.trace( "tsFile: " _ tsFile _" ( " _ filename _ " ) " )
	d ..printer.trace( "tsCode: " _ tsCode )
	
	if ( tsCode = tsFile ) {
		Q 1 ;nothing to sync	
	}
	
	#define ok(%sc) $S( +%sc = 1: "Ok!", 1: "Fail ;(" )
	
	if ( tsCode ] tsFile ) { ;export
		
		s sc = ..export( filename ) 
		d ..printer.w( ..code _" -> " _ filename _" " _ $$$ok(sc) )
		Q sc	
	}
	
	if (( tsFile ] tsCode ) && ( ..event '= "aftercompile" )) { ;import
		
		s sc = ..import( filename ) ; file newer - import from file
		d ..printer.w( filename _" -> " _ ..code _" " _ $$$ok(sc) )
		Q sc
		
	}
	
	Q $$$OK
}

/// Base directory for export
Method workdir() [ ProcedureBlock = 0 ]
{
 //Q ##class(sc.options).workdir()
 	Q ##class(sc.options).get("workdirCLS")
}

/// handler can delete file
ClassMethod fileDelete(file) As %Status
{
	set sc = ##class(%File).Delete( file )
	Quit sc
}

/// convert code name to file name, packages translate as directories
Method filename()
{
	
	s name = ..name
	s namelen = $l( name, "." )
	s hasPackage = ( namelen > 1 )  
	s ext = ..ext
		
	s dir = ..workdir(), path = ""
		
	if ( hasPackage ) { ;myPackage.myClass.CLS or test.MAC
		
		s packages = $p( name, ".", 1, namelen - 1 )
		s dm = "/" ; $$$IsWINDOWS
		s path = $tr( packages, ".", dm )
		
		s:packages'="" dir = dir _ dm _ path
		
		s name = $p( name, ".", namelen  )
		
	}
	
	s sc = ##class(%File).CreateDirectoryChain( dir ) ;need for (%File).NormalizeFilename
	s file = name _ "."_ ext _ ".xml"
	Q ##class(%File).NormalizeFilename( file, dir )
}

/// file mask for import 
ClassMethod filemask()
{
	Q "*.cls.xml"
}

/// return true for ignore code
Method ignore() As %Boolean
{
	Q:$e(..code)="%" 1 ;ignore system classes
	Q:##class(%RoutineMgr).IsGenerated( ..code ) 1 ;ignore generated classes (from csp.page)
	Q:##class(%RoutineMgr).IsClassGenerated( ..name ) 1 ;ignore generated classes (from csp.page)
	Q:##class(%RoutineMgr).IsMapped(..code) 1 ; ignore mapped classes
	Q:$p(..code,".")="INFORMATION" 1  ;ignore SQL-STANDART classes 
	Q 0
}

/// After export tsFile > tsCode
Method export(filename = {..filename()}) As %Status
{
	s sc = $system.OBJ.Export( ..code, filename, "-d/diffexport" )
	Q sc
}

Method import(filename, flags = "ck-d") As %Status
{
	
	s sc = $system.OBJ.Load( filename, flags, .err, .list )
	s:sc ..code = list
	Q sc
}

/// return file timestamp 
ClassMethod tsFile(file) [ ProcedureBlock = 0 ]
{
	Quit:'##class(%File).Exists( file ) ""
    Quit $zdatetime( ##class(%File).GetFileDateModified( file ), 3 )
}

/// Return %TimeStamp of class  
Method tsCode() As %TimeStamp
{
	
	s cls = ..name 
	s sql = "Select TimeChanged From %Dictionary.ClassDefinition Where ID = ? "
	s rs = ##class(%SQL.Statement).%ExecDirect( , sql, cls)
	s tsh = "" s:rs.%Next() tsh = rs.%GetData(1)
	s ts = $zdt( tsh, 3)
	Q ts
}

ClassMethod nameExtract(code)
{
	Q $p( code, ".", 1, $l( code, "." ) - 1 )
}

ClassMethod extExtract(code)
{
	Q $$$LOWER($p( code, ".", $l( code, "." ) ))
}

/// Initial export classes and routines
ClassMethod exportAll() As %Status
{
	
	s printer = ##class(sc.printer).new()
	s handler = ..%New( "", "exportAll", printer )
    
    #; SummaryFunc - method generated by Caché for query "Summary"
    s rs=##class(%Dictionary.ClassDefinition).SummaryFunc()
	
	s sc = $$$OK
    while rs.%Next() { 
       
      s handler.code = rs.Name _ ".cls"
      if ( handler.ignore() ) {
	  	continue     
	  }
      
      s sc = handler.export() Q:'sc
      
      d printer.w( handler.code _ " -> " _ handler.filename(), sc )
      
    }
	
	Q sc
}

ClassMethod importAll() As %Status
{
	s mask = ..filemask(), workdir = ##class(sc.options).get("workdirCLS")
	s printer = ##class(sc.printer).new()
	s sc =  ..importDir( workdir, mask, printer, .loaded )
	Q $system.OBJ.CompileList( .loaded, "ckbr-d/multicompile" )
}

ClassMethod importDir(dir, mask, printer As sc.printer, ByRef loaded = "") As %Status
{
	s subdir = "", sc = 1  
	
	s rs = ##class(%File).FileSetFunc( dir, mask, , 1 )
	
	while rs.%Next() {
		
		if ( rs.Type = "D" ){
			s subdir( $i( subdir ) ) = rs.Name
			continue 
		}
		s handler = ..%New( "", "importAll", printer )
		s sc = handler.import( rs.Name, "k-d" ) ;"k-d" - load only
		d printer.w( rs.Name _ " -> " _ handler.code , sc )
		
		//if ( 'sc ) Quit 
		
		if sc s loaded( handler.code )="" ;save name of loaded document
				
	}
	
	Q:'sc sc
	
	s i = "" for { s i = $o( subdir(i), 1, sub ) Q:i=""
		s sc = ..importDir( sub, mask, printer, .loaded ) Q:'sc
	}
	Q:'sc sc 
		
	Q sc
}

}

