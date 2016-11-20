Class sc.general [ Abstract ]
{

Parameter Workdir As %String = "C:/testsc";

Parameter exportMode = "UDL";

ClassMethod setFileStructure(workdir)
{
	  set:'$d(workdir) workdir=..#Workdir
	  set workdir=##class(sc.options).workdir(workdir)_"/src/"
	  d ##class(sc.options).set("workdirCLS",workdir_"cls/")
	  d ##class(sc.options).set("workdirMAC",workdir_"mac/")
	  d ##class(sc.options).set("workdirINC",workdir_"inc/")
	  d ##class(sc.options).set("workdirINT",workdir_"int/")
	  d ##class(sc.options).set("workdirDFI",workdir_"dfi/")
}

ClassMethod exportAll() As %Status
{
	d ##class(sc.plain.int).exportAll()
	d ##class(sc.plain.inc).exportAll()
	d ##class(sc.plain.mac).exportAll()
	d ##class(sc.plain.classes).exportAll()
	d ##class(sc.plain.dfi).exportAll()
}

ClassMethod importAll() As %Status
{
	d ##class(sc.plain.int).importAll()
	d ##class(sc.plain.inc).importAll()
	d ##class(sc.plain.mac).importAll()
	d ##class(sc.plain.classes).importAll()
	d ##class(sc.plain.dfi).importAll()
	
	d ##class(sc.routines).importAll()
	d ##class(sc.classes).importAll()
	d ##class(sc.dfi).importAll()
}

}

