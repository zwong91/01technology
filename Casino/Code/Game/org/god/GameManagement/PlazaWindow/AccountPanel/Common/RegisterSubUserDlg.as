﻿package 
{
	import flash.events.Event;
	
	import org.god.Common.MD5;
	import org.god.Common.FuncUtil;
	import org.god.IGameManagement.IMain;
	import org.god.IGameManagement.GlobalMain;
	import org.god.SkinControl.BaseDialog;
	import org.god.SkinControl.SkinTextField;
	import org.god.SkinControl.DialogEvent;
	import org.god.Net.tagUserData;
	import org.god.Net.CMD_GP_RegisterSubUser;
	
	import org.aswing.JComboBox;
	import org.aswing.VectorListModel;
	import org.aswing.ASFont;
	import org.aswing.ASColor;
	import org.aswing.JLabel;
	import org.aswing.geom.IntRectangle;
	//注册子用户对话框
	public class RegisterSubUserDlg extends BaseDialog
	{
		protected var m_pParentUserData:tagUserData;

		protected var m_labelTitle:JLabel;

		protected var m_tfAccount:SkinTextField;
		protected var m_tfName:SkinTextField;
		protected var m_tfPasswd:SkinTextField;
		protected var m_tfPasswsAgain:SkinTextField;
		
		public function RegisterSubUserDlg(pParentUserData:tagUserData,
										   pUserData:*,owner:* = null)
		{
			super(new IMAGE_DLG_BASICUSERINFO(449,285), pUserData, owner);
			
			m_pParentUserData = pParentUserData;

			CreateControl();
			InitControl();
			
		}
		protected function CreateControl():void
		{
			m_labelTitle = new JLabel("",null,JLabel.CENTER);
			addChild(m_labelTitle);
			m_labelTitle.setComBounds(new IntRectangle(0,12,449,24));
			var MyFont:ASFont = new ASFont;
			MyFont = MyFont.changeSize(20);
			MyFont = MyFont.changeBold(true);
			m_labelTitle.setFont(MyFont);
			m_labelTitle.setForeground(new ASColor(0x020202));

			var nXPos:Number = 150;
			var nYPos:Number = 68;
			var nWidth:Number = 200;
			var nHeight:Number = 22;
			var nYOffset:Number = 29; 
			
			m_tfAccount = new SkinTextField();
			m_tfName = new SkinTextField();
			m_tfPasswd = new SkinTextField();
			m_tfPasswsAgain = new SkinTextField();
			addChild(m_tfAccount);
			addChild(m_tfName);
			addChild(m_tfPasswd);
			addChild(m_tfPasswsAgain);
			m_tfAccount.setComBoundsXYWH(nXPos, nYPos, nWidth, nHeight);
			m_tfName.setComBoundsXYWH(nXPos, nYPos + nYOffset, nWidth, nHeight);
			m_tfPasswd.setComBoundsXYWH(nXPos, nYPos+ nYOffset*2, nWidth, nHeight);
			m_tfPasswsAgain.setComBoundsXYWH(nXPos, nYPos+ nYOffset*3, nWidth, nHeight);
			m_tfAccount.setMaxChars(NAME_LEN-2);
			m_tfName.setMaxChars(NAME_LEN-2);
			m_tfPasswd.setMaxChars(PASS_LEN/2);
			m_tfPasswsAgain.setMaxChars(PASS_LEN/2);
			m_tfAccount.setOnlyASCIICharAndNumber(true);
			m_tfName.setOnlyASCIICharAndNumber(true);
			m_tfPasswd.setDisplayAsPassword(true);
			m_tfPasswsAgain.setDisplayAsPassword(true);
			
			
		}
		protected function InitControl():void
		{
			var strTitle:String = IDS_NEW + IDS_SUBUSER + 
			"[" + IDS_PARENTUSER + ":" + m_pParentUserData.szAccount + "]";
			m_labelTitle.setText(strTitle);
					
			m_tfAccount.setPrefix(FuncUtil.fu_GetSubAcountPrefix());
			
			if(DEBUG)
			{
				m_tfAccount.setText(FuncUtil.fu_GetSubAcountPrefix() + "aaa");
				m_tfName.setText(FuncUtil.fu_GetSubAcountPrefix() + "aaa");
				m_tfPasswd.setText("111111");
				m_tfPasswsAgain.setText("111111");
			}
		
		}
		public override function Destroy():void
		{
			m_pParentUserData = null;
			
			removeChild(m_labelTitle);
			m_labelTitle = null;
			
			m_tfAccount.Destroy();
			removeChild(m_tfAccount);
			m_tfAccount = null;
			m_tfName.Destroy();
			removeChild(m_tfName);
			m_tfName = null;
			m_tfPasswd.Destroy();
			removeChild(m_tfPasswd);
			m_tfPasswd = null;
			m_tfPasswsAgain.Destroy();
			removeChild(m_tfPasswsAgain);
			m_tfPasswsAgain = null;
			
			super.Destroy();
		}
		public override function setFont(newFont:ASFont):void
		{
			super.setFont(newFont);
			if(m_tfAccount)
			{
				m_tfAccount.setFont(newFont);
				m_tfName.setFont(newFont);
				m_tfPasswd.setFont(newFont);
				m_tfPasswsAgain.setFont(newFont);
				
			}
		}
		
		//////////////////////////
		protected function ShowMessageBox(strMsg:String):void
		{
			var main:IMain = GlobalMain.getMain();
			if(main)
			{
				main.ShowMessageBox(strMsg);
			}
		}
		//////////////////////////
		
		override public function OnEventOK(e:Event):void
		{
			if(m_tfAccount.getText().length <= 1)
			{
				ShowMessageBox(IDS_ERR_ACOUNTEMPTY);
				m_tfAccount.makeFocus();
				return;
			}
			if(m_tfName.getText().length <= 0)
			{
				ShowMessageBox(IDS_ERR_NAMEEMPTY);
				m_tfName.makeFocus();
				return;
			}
			if(m_tfPasswd.getText().length <= 5)
			{
				ShowMessageBox(IDS_ERR_PASSWDEMPTY);
				m_tfPasswd.makeFocus();
				return;
			}
			if(m_tfPasswsAgain.getText().length <= 5)
			{
				ShowMessageBox(IDS_ERR_PASSWDEMPTY);
				m_tfPasswsAgain.makeFocus();
				return;
			}
			if(m_tfPasswd.getText() != m_tfPasswsAgain.getText())
			{
				ShowMessageBox(IDS_ERR_PASSWDVERIFTY);
				m_tfPasswsAgain.makeFocus();
				return;
			}
					
			var RegisterSubUser:CMD_GP_RegisterSubUser = m_pUserData  as CMD_GP_RegisterSubUser;
			RegisterSubUser.dwParentUserID = m_pParentUserData.dwUserID;
			RegisterSubUser.szAccount = m_tfAccount.getText();
			RegisterSubUser.szName = m_tfName.getText();
			RegisterSubUser.szPassWord = MD5.hash(m_tfPasswd.getText());
			
			dispatchEvent(new DialogEvent(DialogEvent.CMD_OK, m_pUserData, m_pParentUserData));
			
			Destroy();
		}
	}
}
include "../../StringTableDef.as"
include "../../../../Common/StringTableDef.as"
include "../../../../GlobalConst.as"
include "../../../../Net/GLOBALDEF.as"