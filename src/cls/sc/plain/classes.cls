/// export classes as plain text
Class sc.plain.classes Extends sc.classes
{

/// file mask for import 
ClassMethod filemask()
{
	Q "*.cls"
}

/// convert code name to file name, packages translate as directories
Method filename()
{
	
	s name = ..name, namelen = $l( name, "." ), hasPackage = ( namelen > 1 )  
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
	s file = name _ "."_ ext
	Q ##class(%File).NormalizeFilename( file, dir )
}

Method export(filename = {..filename()}) As %Status
{
	s file = ##class(%Stream.FileCharacter).%New()
	s file.TranslateTable = "UTF8"
	s file.Filename = filename
	s sc = ##class(%Compiler.UDL.TextServices).GetTextAsStream( , ..name, .file ) 
	
	Q file.%Save()
}

Method import(filename) As %Status
{
	s file = ##class(%Stream.FileCharacter).%New()
	s file.TranslateTable = "UTF8"
	s filename=$tr(filename,"\","/")
	s file.Filename = filename
	
	s code = ..codename( filename )
	s sc = ##class(%Compiler.UDL.TextServices).SetTextFromStream( , code, file )
	//s:sc ..code = code
	s ..code=code
	Q sc
}

/// Backward translation from filename to codename
Method codename(filename = "")
{
	Q:..code'="" ..code
	s:filename="" filename=..filename()
	Q ..getCodeName(filename, ..workdir())
}

ClassMethod getCodeName(filename, workdir)
{
	s subpath = $p(filename, workdir, 2)
	s codename = $tr(subpath,"/",".")
	s:$e(codename)="." $e(codename)=""
	Q codename
}

}

