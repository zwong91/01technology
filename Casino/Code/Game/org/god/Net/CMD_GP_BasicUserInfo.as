﻿package org.god.Net
{
	import flash.utils.ByteArray;

	//基本信息
	public class CMD_GP_BasicUserInfo
	{
		public static  const sizeof_CMD_GP_BasicUserInfo:uint = 
											4 + 4 + NAME_LEN + PASS_LEN + 1;

		public var dwOperationUserID:uint;//操作用户ID
		public var dwUserID:uint;//被操作用户ID
		public var szName:String="";//名称
		public var szPassWord:String = "";//登录密码
		public var cbFaceID:uint;
		
		public function CMD_GP_BasicUserInfo()
		{

		}
		
		public function toByteArray():ByteArray
		{
			var result:ByteArray = newLitteEndianByteArray();

			result.writeUnsignedInt(dwOperationUserID);
			result.writeUnsignedInt(dwUserID);
			writeStringToByteArray(result, szName, NAME_LEN);
			writeStringToByteArray(result, szPassWord, PASS_LEN);
			result.writeByte(cbFaceID);
			
			return result;
		}
	}
}
include "GLOBALDEF.as"
include "../Common/Memory.as"