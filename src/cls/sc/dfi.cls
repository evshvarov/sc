/// Work with *.dfi documents
/// %DeepSee.UserLibrary.FolderItem
Class sc.dfi Extends sc.classes
{

ClassMethod importAll() As %Status
{
	s mask = ..filemask(), workdir = ##class(sc.options).get("workdirDFI")
	s printer = ##class(sc.printer).new()
	s sc =  ..importDir( workdir, mask, printer, .loaded )
	Q $system.OBJ.CompileList( .loaded, "ckbr-d/multicompile" )
}

Method workdir() [ ProcedureBlock = 0 ]
{
 //Q ##class(sc.options).workdir()
 	Q ##class(sc.options).get("workdirDFI")
}

Method codeSet(code) As %Status
{
	s sc = ##super(code)
	s sc = sc && ..getData( code, .data )
	if ( sc ) {
	 	s i%id = $g(data("id"))
		s i%fullName = $g(data("fullName"))
	}
	Q 1
}

Property id [ ReadOnly ];

Property fullName [ ReadOnly ];

/// collect information about dfi document
ClassMethod getData(code, ByRef data) As %Status
{
	s sql = "Select ID, fullName From %DeepSee_UserLibrary.FolderItem Where documentName = ?"
	s rs = ##class(%SQL.Statement).%ExecDirect( , sql, code )
	s ( id, fullName ) = "" 
	if ( rs.%Next() ) {
		s data("id") = rs.ID
		s data("fullName") = rs.fullName
	}	
	Q 1
}

/// return local timestamp of DFI document
Method tsCode() As %TimeStamp
{
	s utcTS = ##class(%DeepSee.UserLibrary.FolderItem).timeModifiedGetStored( ..id ) ;UTC timestamp
	s utc = $zdth(utcTS,3,,3) ;utc logical
	s local = $zdth(utc,-3) ; utc to local 
	s ts = $zdt(local,3,,0) ; local timestamp
	Q ts
}

Method import(filename) As %Status
{
	s replace = 1, verbose = 0, killAll = 0, forceName = "", loaded = ""
	s sc = ##class(%DeepSee.UserLibrary.Utils).%Import( filename, replace, verbose, killAll, forceName, .loaded )
	if ( sc ) {
		s ..code = loaded( 1 ) _ ".DFI"
	}
	Q sc
}

Method export(filename = {..filename()}) As %Status
{
	Q ##class(%DeepSee.UserLibrary.Utils).%Export( ..fullName, filename, 0 )
}

/// convert code name to file name, packages translate as directories
/// DFI example: BI-TechnologyTopicAnalyticsViews.pivot.DFI
/// where 'pivot.DFI' - type and extensions
/// TechnologyTopicAnalyticsViews - name of DFI
/// BI - virtual folder
Method filename()
{
	s name = ..name
	s namelen = $l( name, "." )
	s hasPackage = ( namelen > 2 )  ;2 - name and type 
	s ext = ..ext
		
	s dir = ..workdir(), path = ""
	
	if ( hasPackage ) { ;has virtual folder
		
		s packages = $p( name, ".", 1, namelen - 2 ) ;2 - name and type
		s dm = "\" ; $$$IsWINDOWS
		s path = $tr( packages, ".", dm ) ; NOTE - need filename checking!	
		
		if ( packages'="" ) { 
			s dir = dir _ dm _ path
		}
		
		s name = $p( name, ".", namelen-1, namelen  )
		
	}
	
	s sc = ##class(%File).CreateDirectoryChain( dir ) ;need for (%File).NormalizeFilename
	s file = name _ "."_ ext _ ".xml"
	
	Q ##class(%File).NormalizeFilename( file, dir )
}

/// file mask for import 
ClassMethod filemask()
{
	Q "*.DFI.xml"
}

/// Initial export classes and routines
ClassMethod exportAll() As %Status
{
	
	s printer = ##class(sc.printer).new()
	s handler = ..%New( "", "exportAll", printer )
    
    s sql = "Select documentName From %DeepSee_UserLibrary.FolderItem"
    s rs = ##class(%SQL.Statement).%ExecDirect(,sql)
    
	s sc = $$$OK
    while rs.%Next() { 
       
      s handler.code = rs.documentName
      if ( handler.ignore() ) {
	  	continue     
	  }
      
      s sc = handler.export() Q:'sc
      
      d printer.w( handler.code _ " -> " _ handler.filename(), sc )
      
    }
	
	Q sc
}

/// return 1 for ignore code
Method ignore() As %Boolean
{
	Q 0
}

}

