/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org � blog.papervision3d.org � osflash.org/papervision3d
 */

/*
 * Copyright 2006 (c) Carlos Ulloa Matesanz, noventaynueve.com.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

// __________________________________________________________________________ BITMAP MATERIAL

package org.papervision3d.materials
{
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.geom.Matrix;

import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.Papervision3D;
import org.papervision3d.core.draw.IFaceDrawer;
import org.papervision3d.core.geom.Face3D;
import flash.display.Graphics;
import org.papervision3d.core.geom.Vertex2D;
import flash.utils.Dictionary;
import org.papervision3d.objects.DisplayObject3D;

/**
* The BitmapMaterial class creates a texture from a BitmapData object.
*
* Materials collect data about how objects appear when rendered.
*
*/
public class BitmapMaterial extends MaterialObject3D implements IFaceDrawer
{
	/**
	 * Indicates if mip mapping is forced.
	 */
	static public var AUTO_MIP_MAPPING :Boolean = true;

	/**
	 * Levels of mip mapping to force.
	 */
	static public var MIP_MAP_DEPTH :Number = 8;

	// ______________________________________________________________________ TEXTURE

	/**
	* A texture object.
	*/
	public function get texture():*
	{
		return this._texture;
	}

	public function set texture( asset:* ):void
	{
		this.bitmap   = createBitmap( asset );
		this._texture = asset;
	}

	public var uvMatrices:Dictionary;
	
	
	// ______________________________________________________________________ NEW

	/**
	* The BitmapMaterial class creates a texture from a BitmapData object.
	*
	* @param	asset				A BitmapData object.
	* @param	initObject			[optional] - An object that contains additional properties with which to populate the newly created material.
	*/
	public function BitmapMaterial( asset :*, initObject :Object=null )
	{
		super( initObject );

		texture = asset;
		init();
	}
	
	private function init():void
	{
		uvMatrices = new Dictionary();
	}
	
	/**
	 *  drawFace3D
	 */
	override public function drawFace3D(instance:DisplayObject3D, face3D:Face3D, graphics:Graphics, v0:Vertex2D, v1:Vertex2D, v2:Vertex2D):int
	{
		if(bitmap){
			var map:Matrix = (uvMatrices[face3D] || transformUV(face3D, instance));
			
			var x0:Number = v0.x;
			var y0:Number = v0.y;
			var x1:Number = v1.x;
			var y1:Number = v1.y;
			var x2:Number = v2.x;
			var y2:Number = v2.y;
			
			_triMatrix.a = x1 - x0;
			_triMatrix.b = y1 - y0;
			_triMatrix.c = x2 - x0;
			_triMatrix.d = y2 - y0;
			_triMatrix.tx = x0;
			_triMatrix.ty = y0;
				
			_localMatrix.a = map.a;
			_localMatrix.b = map.b;
			_localMatrix.c = map.c;
			_localMatrix.d = map.d;
			_localMatrix.tx = map.tx;
			_localMatrix.ty = map.ty;
			_localMatrix.concat(_triMatrix);
			
			graphics.beginBitmapFill( bitmap, _localMatrix, true, smooth);
			graphics.moveTo( x0, y0 );
			graphics.lineTo( x1, y1 );
			graphics.lineTo( x2, y2 );
			graphics.lineTo( x0, y0 );
			graphics.endFill();
		}
		return 1;
	}
	
	/**
	* Applies the updated UV texture mapping values to the triangle. This is required to speed up rendering.
	*
	*/
	public function transformUV(face3D:Face3D, instance:DisplayObject3D=null):Matrix
	{
		if( ! face3D.uv )
		{
			Papervision3D.log( "MaterialObject3D: transformUV() uv not found!" );
		}
		else if( bitmap )
		{
			var uv :Array  = face3D.uv;

			var w  :Number = bitmap.width * maxU;
			var h  :Number = bitmap.height * maxV;

			var u0 :Number = w * uv[0].u;
			var v0 :Number = h * ( 1 - uv[0].v );
			var u1 :Number = w * uv[1].u;
			var v1 :Number = h * ( 1 - uv[1].v );
			var u2 :Number = w * uv[2].u;
			var v2 :Number = h * ( 1 - uv[2].v );

			// Fix perpendicular projections
			if( (u0 == u1 && v0 == v1) || (u0 == u2 && v0 == v2) )
			{
				u0 -= (u0 > 0.05)? 0.05 : -0.05;
				v0 -= (v0 > 0.07)? 0.07 : -0.07;
			}

			if( u2 == u1 && v2 == v1 )
			{
				u2 -= (u2 > 0.05)? 0.04 : -0.04;
				v2 -= (v2 > 0.06)? 0.06 : -0.06;
			}

			// Precalculate matrix & correct for mip mapping
			var at :Number = ( u1 - u0 );
			var bt :Number = ( v1 - v0 );
			var ct :Number = ( u2 - u0 );
			var dt :Number = ( v2 - v0 );

			var m :Matrix = new Matrix( at, bt, ct, dt, u0, v0 );
			m.invert();

			var mapping:Matrix = uvMatrices[face3D] || (uvMatrices[face3D] = m.clone() );
			mapping.a  = m.a;
			mapping.b  = m.b;
			mapping.c  = m.c;
			mapping.d  = m.d;
			mapping.tx = m.tx;
			mapping.ty = m.ty;
		}
		else Papervision3D.log( "MaterialObject3D: transformUV() material.bitmap not found!" );

		return mapping;
	}
	
	// ______________________________________________________________________ TO STRING

	/**
	* Returns a string value representing the material properties in the specified BitmapMaterial object.
	*
	* @return	A string.
	*/
	public override function toString(): String
	{
		return 'Texture:' + this.texture + ' lineColor:' + this.lineColor + ' lineAlpha:' + this.lineAlpha;
	}


	// ______________________________________________________________________ CREATE BITMAP

	protected function createBitmap( asset:* ):BitmapData
	{
		return correctBitmap( asset, false );
	}
	//god
	public function destroyBitmap():void
	{
		if(this.bitmap)
		{
			this.bitmap.dispose();
			this.bitmap = null;
		}
	}

	// ______________________________________________________________________ CORRECT BITMAP FOR MIP MAPPING

	public function correctBitmap( bitmap :BitmapData, dispose :Boolean ):BitmapData
	{
		var okBitmap :BitmapData;

		var levels :Number = 1 << MIP_MAP_DEPTH;
		var width  :Number = levels * Math.ceil( bitmap.width  / levels );
		var height :Number = levels * Math.ceil( bitmap.height / levels );

		// Check for BitmapData maximum size
		var ok:Boolean = true;

		if( width  > 2880 )
		{
			width  = bitmap.width;
			ok = false;
		}

		if( height > 2880 )
		{
			height = bitmap.height;
			ok = false;
		}
		
		if( ! ok ) Papervision3D.log( "Material " + this.name + ": Texture too big for mip mapping. Resizing recommended for better performance and quality." );

		// Create new bitmap?
		if( AUTO_MIP_MAPPING && bitmap && ( bitmap.width % levels !=0  ||  bitmap.height % levels != 0 ) )
		{

			this.maxU = bitmap.width / width;
			this.maxV = bitmap.height / height;

			okBitmap = new BitmapData( width, height, bitmap.transparent, 0x00000000 );

			okBitmap.draw( bitmap );
			
			extendBitmapEdges( okBitmap, bitmap.width, bitmap.height );
			
			// Dispose bitmap if needed
			if( dispose ) bitmap.dispose();
		}
		else
		{
			this.maxU = this.maxV = 1;

			okBitmap = bitmap;
		}

		return okBitmap;
	}

	protected function extendBitmapEdges( bmp:BitmapData, originalWidth:Number, originalHeight:Number ):void
	{
		var srcRect  :Rectangle = new Rectangle();
		var dstPoint :Point = new Point();
		var i        :int;

		// Check width
		if( bmp.width > originalWidth )
		{
			// Extend width
			srcRect.x      = originalWidth-1;
			srcRect.y      = 0;
			srcRect.width  = 1;
			srcRect.height = originalHeight;
			dstPoint.y     = 0;
			
			for( i = originalWidth; i < bmp.width; i++ )
			{
				dstPoint.x = i;
				bmp.copyPixels( bmp, srcRect, dstPoint );
			}
		}

		// Check height
		if( bmp.height > originalHeight )
		{
			// Extend height
			srcRect.x      = 0;
			srcRect.y      = originalHeight-1;
			srcRect.width  = bmp.width;
			srcRect.height = 1;
			dstPoint.x     = 0;

			for( i = originalHeight; i < bmp.height; i++ )
			{
				dstPoint.y = i;
				bmp.copyPixels( bmp, srcRect, dstPoint );
			}
		}
	}

	// ______________________________________________________________________

	/**
	* Copies the properties of a material.
	*
	* @param	material	Material to copy from.
	*/
	override public function copy( material :MaterialObject3D ):void
	{
		super.copy( material );

		this.maxU = material.maxU;
		this.maxV = material.maxV;
	}

	/**
	* Creates a copy of the material.
	*
	* @return	A newly created material that contains the same properties.
	*/
	override public function clone():MaterialObject3D
	{
		var cloned:MaterialObject3D = super.clone();

		cloned.maxU = this.maxU;
		cloned.maxV = this.maxV;

		return cloned;
	}

	// ______________________________________________________________________ PRIVATE VAR

	protected var _texture :*;
	protected static var _triMatrix:Matrix = new Matrix()
	protected static var _localMatrix:Matrix = new Matrix();
}
}