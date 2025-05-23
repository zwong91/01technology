/*
 Copyright aswing.org, see the LICENCE.txt.
*/

package org.aswing{

import org.aswing.geom.IntPoint;
import org.aswing.event.*;

/**
 * Default list cell, render item value.toString() text.
 * @author iiley
 */
public class DefaultListCell extends AbstractListCell{
	
	private var jlabel:JLabel;
			
	private static var sharedToolTip:JSharedToolTip;
	
	public function DefaultListCell(){
		super();
		if(sharedToolTip == null){
			sharedToolTip = new JSharedToolTip();
			sharedToolTip.setOffsetsRelatedToMouse(false);
			sharedToolTip.setOffsets(new IntPoint(0, 0));
		}
	}
	
	override public function setCellValue(value:*) : void {
		super.setCellValue(value);
		getJLabel().setText(value.toString());
		__resized(null);
	}
	
	override public function getCellComponent() : Component {
		return getJLabel();
	}

	protected function getJLabel():JLabel{
		if(jlabel == null){
			jlabel = new JLabel();
			initJLabel(jlabel);
		}
		return jlabel;
	}
	
	protected function initJLabel(jlabel:JLabel):void{
		jlabel.setHorizontalAlignment(JLabel.LEFT);
		jlabel.setOpaque(true);
		jlabel.setFocusable(false);
		jlabel.addEventListener(ResizedEvent.RESIZED, __resized);
	}
	
	private function __resized(e:ResizedEvent):void{
		if(getJLabel().getWidth() < getJLabel().getPreferredWidth()){
			getJLabel().setToolTipText(value.toString());
			JSharedToolTip.getSharedInstance().unregisterComponent(getJLabel());
			sharedToolTip.registerComponent(getJLabel());
		}else{
			getJLabel().setToolTipText(null);
			sharedToolTip.unregisterComponent(getJLabel());
		}
	}
}
}