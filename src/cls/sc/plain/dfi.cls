/// change codename to filename rule
Class sc.plain.dfi Extends sc.dfi
{

/// file mask for import 
ClassMethod filemask()
{
	Q "*.dfi"
}

/// convert code name to file name, packages translate as directories
/// DFI example: BI-TechnologyTopicAnalyticsViews.pivot.DFI
/// where 'pivot.DFI' - type and extensions
/// TechnologyTopicAnalyticsViews - name of DFI
/// BI - virtual folder
Method filename()
{
	s name = ..name
	s namelen = $l( name, "-" )
	s hasPackage = ( namelen > 0 )  ;2 - name and type 
	s ext = ..ext
		
	s dir = ..workdir(), path = ""
	
	if ( hasPackage ) { ;has virtual folder
		
		s packages = $p( name, "-", 1, namelen -1 ) ;2 - name and type
		s dm = "/" ; $$$IsWINDOWS
		s path = $tr( packages, "-", dm ) ; NOTE - need filename check!	
		
		if ( packages'="" ) { 
			s dir = dir _ dm _ path
		}
		
		s name = $p( name, "-", namelen, namelen  )
		
	}
	
	s sc = ##class(%File).CreateDirectoryChain( dir ) ;need for (%File).NormalizeFilename
	s file = name _ "."_ ext 
	q dir_"/"_file
	//Q ##class(%File).NormalizeFilename( file, dir )
}

}

