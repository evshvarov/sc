/// Output messages 
Class sc.printer Extends %RegisteredObject
{

/// 1 - main, 2 - warning, 3 - trace
Parameter LOG = 1;

Property device [ InitialExpression = {$io} ];

/// test
/// This callback method is invoked by the <METHOD>%New</METHOD> method to 
/// provide notification that a new instance of an object is being created.
Method %OnNew(device = {$io}) As %Status [ Private, ServerOnly = 1 ]
{
	s ..device = device 
	Q 1
}

ClassMethod new() As printer
{
	s printer = ..%New($io) 
	s custom = ##class(options).printer()
	Q:custom="" printer
	try {
		s printer = $classmethod( custom, "%New",$io)
	} catch {
		s printer = ..%New($io)
	}
	Q printer
}

Method w(msg, sc = "")
{
	s io = $io	
	use ..device w !,"** ", msg w:sc'="" " ", $S(+sc=1: "Ok!", 1:"FAIL Status: "_$System.Status.GetErrorText(sc))
	use io
}

Method error(msg)
{
	d ..w(msg)
}

Method warn(msg)
{
	d:(..#LOG>=2) ..w(msg)
}

Method trace(msg)
{
	d:(..#LOG>=3) ..w(msg)
}

}

