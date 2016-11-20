/// routin (*.inc, *.int, *.mac ) as plain text
Class sc.plain.routines Extends sc.plain.classes
{

/// file mask for import 
ClassMethod filemask()
{
	Q "*.MAC;*.INT;*.INC"
}

Method import(filename) As %Status
{
	s file = ##class(%Stream.FileCharacter).%New()
	s file.TranslateTable = "UTF8"
	s filename=$TR(filename,"\","/")
	s file.Filename = filename
	
	s code = ..codename( filename )
	
	if ##class(%Routine).Exists( code ) {
       s routine = ##class(%Routine).%OpenId( code )
    } else {
       s routine = ##class(%Routine).%New( code )
    }
    d routine.Clear() 
    s sc = routine.CopyFromAndSave( file )
    s:sc ..code = code
    Q sc
}

Method export(filename = {..filename()}) As %Status
{
	s file = ##class(%Stream.FileCharacter).%New()
	s file.TranslateTable = "UTF8"
	s file.Filename = filename
	s routine = ##class(%Routine).%OpenId( ..code )
	quit file.CopyFromAndSave( routine )
}

ClassMethod exportAll() As %Status
{

 //	quit ##class(sc.routines).exportAll()
 	s rs = ##class(%Routine).RoutineListFunc() 
	s sc = $$$OK, printer = ##class(sc.printer).new()
	s handler = ..%New( "", "exportAll",  printer )
	while ( rs.%Next() ) {
		
		s handler.code = rs.Name
		
		if ( handler.ignore() ) {
			continue	
		}
		s sc = handler.export()
		Q:'sc
		
		d printer.w( handler.code_" -> "_handler.filename(), sc)
		
		
	}
	
	Q sc
}

}

