/**
 * @author John Grden
 */
package org.blitzagency.xray.logger
{
	import org.blitzagency.xray.logger.Log;
	public interface Logger 
	{	
		function setLevel(p_level:Number = 0):void;
		function debug(obj:Log):void;
		function info(obj:Log):void;
		function warn(obj:Log):void;
		function error(obj:Log):void;
		function fatal(obj:Log):void;
		function log(message:String, dump:Object, caller:String, classPackage:String, level:Number):void;
		
	}
}