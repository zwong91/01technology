/*
 Copyright aswing.org, see the LICENCE.txt.
*/

package org.aswing.table.sorter{

import org.aswing.ASColor;
import org.aswing.Component;
import org.aswing.geom.*;
import org.aswing.graphics.*;
import org.aswing.Icon;
import flash.geom.Point;
import flash.display.DisplayObject;
import flash.display.Shape;

/**
 * @author iiley
 */
public class Arrow implements Icon{
	
	private var shape:Shape;
	private var width:int;
	private var arrow:Number;
	
	public function Arrow(descending:Boolean, size:int){
		shape = new Shape();
		arrow = descending ? Math.PI/2 : -Math.PI/2;
		this.width = size;
	}
	
	public function getIconWidth(c:Component) : int {
		return width;
	}

	public function getIconHeight(c:Component) : int {
		return width;
	}

	public function updateIcon(com:Component, g:Graphics2D, x:int, y:int):void{
		shape.graphics.clear();
		g = new Graphics2D(shape.graphics);
		var center:Point = new Point(x, com.getHeight()/2);
		var w:Number = width;
		var ps1:Array = new Array();
		ps1.push(nextPoint(center, 0 + arrow, w/3*2));
		ps1.push(nextPoint(center, Math.PI*2/3 + arrow, w/3*2));
		ps1.push(nextPoint(center, Math.PI*4/3 + arrow, w/3*2));
		
		w--;
		var ps2:Array = new Array();
		ps2.push(nextPoint(center, 0 + arrow, w/3*2));
		ps2.push(nextPoint(center, Math.PI*2/3 + arrow, w/3*2));
		ps2.push(nextPoint(center, Math.PI*4/3 + arrow, w/3*2));		
		
		g.fillPolygon(new SolidBrush(ASColor.BLACK), ps1);
		g.fillPolygon(new SolidBrush(ASColor.GRAY.brighter()), ps2);		
	}
	
	protected function nextPoint(p:Point, dir:Number, dis:Number):Point{
		return new Point(p.x+Math.cos(dir)*dis, p.y+Math.sin(dir)*dis)
	}
	
	public function getDisplay(c:Component):DisplayObject{
		return shape;
	}
}
}