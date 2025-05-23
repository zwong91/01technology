#include "Stdafx.h"
#include "Resource.h"
#include "ServerItemView.h"

//宏定义
#define WN_SET_LINE_COLOR				(TV_FIRST+40)		//设置颜色消息

//////////////////////////////////////////////////////////////////////////

BEGIN_MESSAGE_MAP(CServerItemView, CTreeCtrl)
	ON_NOTIFY_REFLECT(NM_CLICK, OnNMClick)
	ON_NOTIFY_REFLECT(NM_RCLICK, OnNMRclick)
	ON_NOTIFY_REFLECT(NM_DBLCLK, OnNMDblclk)
	ON_NOTIFY_REFLECT(NM_RDBLCLK, OnNMRdblclk)
	ON_NOTIFY_REFLECT(TVN_SELCHANGED, OnTvnSelchanged)
	ON_NOTIFY_REFLECT(TVN_ITEMEXPANDED, OnTvnItemexpanded)
END_MESSAGE_MAP()

//////////////////////////////////////////////////////////////////////////

//静态变量
IServerListSink		* CListItem::m_pIServerListSink=NULL;		//回调接口	

//析构函数
CListItem::~CListItem()
{
	m_dwData=0;
	m_pParentItem=NULL;
}

//枚举子项
CListItem * CListItem::EnumChildItem(INT_PTR nIndex)
{
	if (nIndex>=m_ListItemArray.GetCount()) return NULL;
	return m_ListItemArray[nIndex];
}

//查找子项
CListType * CListItem::SearchTypeItem(WORD wTypeID)
{
	for (INT_PTR i=0;i<m_ListItemArray.GetCount();i++)
	{
		CListItem * pListItem=m_ListItemArray[i];
		if (pListItem->GetItemGenre()==ItemGenre_Type)
		{
			CListType * pListType=(CListType *)pListItem;
			tagGameType * pGameType=pListType->GetItemInfo();
			if (pGameType->wTypeID==wTypeID) return pListType;
		}
	}

	return NULL;
}

//查找子项
CListKind * CListItem::SearchKindItem(WORD wKindID)
{
	for (INT_PTR i=0;i<m_ListItemArray.GetCount();i++)
	{
		CListItem * pListItem=m_ListItemArray[i];
		if (pListItem->GetItemGenre()==ItemGenre_Kind)
		{
			CListKind * pListKind=(CListKind *)pListItem;
			const tagGameKind * pGameKind=pListKind->GetItemInfo();
			if (pGameKind->wKindID==wKindID) return pListKind;
		}
	}

	return NULL;
}

//查找子项
CListProcess * CListItem::SearchProcessItem(WORD wKindID)
{
	for (INT_PTR i=0;i<m_ListItemArray.GetCount();i++)
	{
		CListItem * pListItem=m_ListItemArray[i];
		if (pListItem->GetItemGenre()==ItemGenre_Process)
		{
			CListProcess * pListProcess=(CListProcess *)pListItem;
			const tagGameProcess * pGameProcess=pListProcess->GetItemInfo();
			if (pGameProcess->wKindID==wKindID) return pListProcess;
		}
	}

	return NULL;
}

//查找子项
CListStation * CListItem::SearchStationItem(WORD wKindID, WORD wStationID, bool bDeepSearch)
{
	//本层搜索
	for (INT_PTR i=0;i<m_ListItemArray.GetCount();i++)
	{
		CListItem * pListItem=m_ListItemArray[i];
		if (pListItem->GetItemGenre()==ItemGenre_Station)
		{
			CListStation * pListStation=(CListStation *)pListItem;
			const tagGameStation * pGameStation=pListStation->GetItemInfo();
			if ((pGameStation->wStationID==wStationID)&&(pGameStation->wKindID==wKindID)) return pListStation;
		}
	}

	//深度搜索
	if (bDeepSearch)
	{
		for (INT_PTR i=0;i<m_ListItemArray.GetCount();i++)
		{
			CListItem * pItemBase=m_ListItemArray[i];
			CListStation * pListStation=pItemBase->SearchStationItem(wKindID,wStationID,bDeepSearch);
			if (pListStation!=NULL) return pListStation;
		}
	}

	return NULL;
}

//查找子项
CListServer * CListItem::SearchServerItem(WORD wKindID, WORD wServerID, bool bDeepSearch)
{
	//本层搜索
	for (INT_PTR i=0;i<m_ListItemArray.GetCount();i++)
	{
		CListItem * pListItem=m_ListItemArray[i];
		if (pListItem->GetItemGenre()==ItemGenre_Server)
		{
			CListServer * pListServer=(CListServer *)pListItem;
			const tagGameServer * pGameServer=pListServer->GetItemInfo();
			if ((pGameServer->wServerID==wServerID)&&(pGameServer->wKindID==wKindID)) return pListServer;
		}
	}

	//深度搜索
	if (bDeepSearch)
	{
		for (INT_PTR i=0;i<m_ListItemArray.GetCount();i++)
		{
			CListItem * pItemBase=m_ListItemArray[i];
			CListServer * pListServer=pItemBase->SearchServerItem(wKindID,wServerID,bDeepSearch);
			if (pListServer!=NULL) return pListServer;
		}
	}

	return NULL;
}

//////////////////////////////////////////////////////////////////////////

//构造函数
CServerListManager::CServerListManager()
{
	m_pIServerListSink=NULL;
}

//析构函数
CServerListManager::~CServerListManager()
{
	ClearAllItem();
}
void CServerListManager::ClearAllItem()
{
	int i=0;
	INT_PTR nCount=m_PtrArrayType.GetCount();
	for (i=0;i<nCount;i++) delete m_PtrArrayType[i];
	m_PtrArrayType.RemoveAll();

	nCount=m_PtrArrayKind.GetCount();
	for (i=0;i<nCount;i++) delete m_PtrArrayKind[i];
	m_PtrArrayKind.RemoveAll();

	nCount=m_PtrArrayProcess.GetCount();
	for (i=0;i<nCount;i++) delete m_PtrArrayProcess[i];
	m_PtrArrayProcess.RemoveAll();

	nCount=m_PtrArrayStation.GetCount();
	for (i=0;i<nCount;i++) delete m_PtrArrayStation[i];
	m_PtrArrayStation.RemoveAll();

	nCount=m_PtrArrayServer.GetCount();
	for (i=0;i<nCount;i++) delete m_PtrArrayServer[i];
	m_PtrArrayServer.RemoveAll();

	nCount=m_PtrArrayInside.GetCount();
	for (i=0;i<nCount;i++) delete m_PtrArrayInside[i];
	m_PtrArrayInside.RemoveAll();

	return;
}
//初始化函数
bool CServerListManager::InitServerListManager(IServerListSink * pIServerListSink)
{
	//设置变量
	m_pIServerListSink=pIServerListSink;
	CListItem::m_pIServerListSink=pIServerListSink;

	//插入数据
	tagGameInside GameInside;
	memset(&GameInside,0,sizeof(GameInside));
	lstrcpyn(GameInside.szDisplayName,szProductName,sizeof(GameInside.szDisplayName));
	InsertInsideItem(&GameInside,1);

	return true;
}

//展开列表
bool CServerListManager::ExpandListItem(CListItem * pListItem)
{
	GT_ASSERT(m_pIServerListSink!=NULL);
	return m_pIServerListSink->ExpandListItem(pListItem);
}

//枚举类型
CListType * CServerListManager::EnumTypeItem(INT_PTR nIndex)
{
	if (nIndex>=m_PtrArrayType.GetCount()) return NULL;
	return m_PtrArrayType[nIndex];
}

//枚举游戏
CListKind * CServerListManager::EnumKindItem(INT_PTR nIndex)
{
	if (nIndex>=m_PtrArrayKind.GetCount()) return NULL;
	return m_PtrArrayKind[nIndex];
}

//枚举站点
CListStation * CServerListManager::EnumStationItem(INT_PTR nIndex)
{
	if (nIndex>=m_PtrArrayStation.GetCount()) return NULL;
	return m_PtrArrayStation[nIndex];
}

//枚举房间
CListServer * CServerListManager::EnumServerItem(INT_PTR nIndex)
{
	if (nIndex>=m_PtrArrayServer.GetCount()) return NULL;
	return m_PtrArrayServer[nIndex];
}

//枚举内部项
CListInside * CServerListManager::EnumInsideItem(INT_PTR nIndex)
{
	if (nIndex>=m_PtrArrayInside.GetCount()) return NULL;
	return m_PtrArrayInside[nIndex];
}

//插入子项
bool CServerListManager::InsertTypeItem(tagGameType GameType[], WORD wCount)
{
	//效验参数
	GT_ASSERT(m_PtrArrayInside.GetCount()>0);
	if (wCount==0) return false;

	//变量定义
	CListType * pListType=NULL;
	CListInside * pRootListInside=m_PtrArrayInside[0];

	_BEGIN_TRY
	{
		//变量定义
		CListType * pListTypeTemp=NULL;

		for (WORD i=0;i<wCount;i++)
		{
			//查找存在
			pListTypeTemp=pRootListInside->SearchTypeItem(GameType[i].wTypeID);
			if (pListTypeTemp!=NULL) continue;

			//插入操作
			pListType=new CListType(pRootListInside);
			CopyMemory(pListType->GetItemInfo(),&GameType[i],sizeof(tagGameType));
			m_PtrArrayType.Add(pListType);
			m_pIServerListSink->OnListItemInserted(pListType);
		}
		return true;
	}
	CATCH_COMMON_EXCEPTION(SafeDelete(pListType);)CATCH_UNKNOWN_EXCEPTION(SafeDelete(pListType);)_END_CATCH

	return false;
}

//插入子项
bool CServerListManager::InsertKindItem(tagGameKind GameKind[], WORD wCount)
{
	CListKind * pListKind=NULL;
	_BEGIN_TRY
	{
		//变量定义
		WORD wTypeID=0;
		CListType * pListType=NULL;
		CListKind * pListKindTemp=NULL;

		for (WORD i=0;i<wCount;i++)
		{
			//寻找父项
			if ((pListType==NULL)||(GameKind[i].wTypeID!=wTypeID))
			{
				wTypeID=GameKind[i].wTypeID;
				pListType=SearchTypeItem(wTypeID);
				GT_ASSERT(pListType!=NULL);
				if (pListType==NULL) continue;
			}

			//查找存在
			pListKindTemp=pListType->SearchKindItem(GameKind[i].wKindID);
			if (pListKindTemp!=NULL) continue;

			//插入操作
			pListKind=new CListKind(pListType);
			CopyMemory(pListKind->GetItemInfo(),&GameKind[i],sizeof(tagGameKind));
			pListKind->m_bInstall=true;
			m_PtrArrayKind.Add(pListKind);
			m_pIServerListSink->OnListItemInserted(pListKind);
		}
		return true;
	}
	CATCH_COMMON_EXCEPTION(SafeDelete(pListKind);)CATCH_UNKNOWN_EXCEPTION(SafeDelete(pListKind);)_END_CATCH

	return false;
}

//插入子项
bool CServerListManager::InsertProcessItem(tagGameProcess GameProcess[], WORD wCount)
{
	CListProcess * pListProcess=NULL;
	_BEGIN_TRY
	{
		//变量定义
		WORD wTypeID=0;
		CListType * pListType=NULL;
		CListProcess * pListProcessTemp=NULL;

		for (WORD i=0;i<wCount;i++)
		{
			//寻找父项
			if ((pListType==NULL)||(GameProcess[i].wTypeID!=wTypeID))
			{
				wTypeID=GameProcess[i].wTypeID;
				pListType=SearchTypeItem(wTypeID);
				GT_ASSERT(pListType!=NULL);
				if (pListType==NULL) continue;
			}

			//查找存在
			pListProcessTemp=pListType->SearchProcessItem(GameProcess[i].wKindID);
			if (pListProcessTemp!=NULL) continue;

			//插入操作
			pListProcess=new CListProcess(pListType);
			CopyMemory(pListProcess->GetItemInfo(),&GameProcess[i],sizeof(tagGameProcess));
			pListProcess->m_bInstall=true;
			m_PtrArrayProcess.Add(pListProcess);
			m_pIServerListSink->OnListItemInserted(pListProcess);
		}
		return true;
	}
	CATCH_COMMON_EXCEPTION(SafeDelete(pListProcess);)CATCH_UNKNOWN_EXCEPTION(SafeDelete(pListProcess);)_END_CATCH

	return false;
}

//插入子项
bool CServerListManager::InsertStationItem(tagGameStation GameStation[], WORD wCount)
{
	CListStation * pListStation=NULL;
	_BEGIN_TRY
	{
		//变量定义
		WORD wKindID=0,wStationID=0;
		CListKind * pListKind=NULL;
		CListItem * pListParent=NULL;
		CListStation * pListStationJoin=NULL;
		CListStation * pListStationTemp=NULL;

		for (WORD i=0;i<wCount;i++)
		{
			//寻找种类
			if ((pListKind==NULL)||(GameStation[i].wKindID!=wKindID))
			{
				pListKind=SearchKindItem(GameStation[i].wKindID);
				GT_ASSERT(pListKind!=NULL);
				if (pListKind==NULL) continue;
				wKindID=GameStation[i].wKindID;
				pListParent=pListKind;
			}

			//查找存在
			pListStationTemp=pListKind->SearchStationItem(GameStation[i].wKindID,GameStation[i].wStationID,true);
			if (pListStationTemp!=NULL) continue;

			//寻找站点
			if (GameStation[i].wJoinID!=0)
			{
				if ((pListStationJoin==NULL)||(GameStation[i].wJoinID!=wStationID))
				{
					pListStationJoin=pListKind->SearchStationItem(GameStation[i].wKindID,GameStation[i].wJoinID,true);
					GT_ASSERT(pListStationJoin!=NULL);
					if (pListStationJoin==NULL) continue;
					wStationID=GameStation[i].wJoinID;
				}
				pListParent=pListStationJoin;
			}

			//插入操作
			pListStation=new CListStation(pListParent,pListKind);
			CopyMemory(pListStation->GetItemInfo(),&GameStation[i],sizeof(tagGameStation));
			m_PtrArrayStation.Add(pListStation);
			m_pIServerListSink->OnListItemInserted(pListStation);
		}
		return true;
	}
	CATCH_COMMON_EXCEPTION(SafeDelete(pListStation);)CATCH_UNKNOWN_EXCEPTION(SafeDelete(pListStation);)_END_CATCH

	return false;
}

//插入子项
bool CServerListManager::InsertServerItem(tagGameServer GameServer[], WORD wCount)
{
	CListServer * pListServer=NULL;
	_BEGIN_TRY
	{
		//变量定义
		WORD wKindID=0,wStationID=0;
		CListKind * pListKind=NULL;
		CListItem * pListParent=NULL;
		CListStation * pListStation=NULL;
		CListServer * pListServerTemp=NULL;

		for (WORD i=0;i<wCount;i++)
		{
			//地址转换
/*			if (GameServer[i].dwServerAddr==4128239067) GameServer[i].dwServerAddr=4127260682;
			else if (GameServer[i].dwServerAddr==4128239067) GameServer[i].dwServerAddr=4145016283;*/

			//寻找种类
			if ((pListKind==NULL)||(GameServer[i].wKindID!=wKindID))
			{
				pListKind=SearchKindItem(GameServer[i].wKindID);
				//GT_ASSERT(pListKind!=NULL);
				if (pListKind==NULL) continue;
				wKindID=GameServer[i].wKindID;
				pListParent=pListKind;
			}

			//查找存在
			pListServerTemp=pListKind->SearchServerItem(GameServer[i].wKindID,GameServer[i].wServerID,true);
			if (pListServerTemp!=NULL) continue;

			//寻找站点
			if (GameServer[i].wStationID!=0)
			{
				if ((pListStation==NULL)||(GameServer[i].wStationID!=wStationID))
				{
					pListStation=pListKind->SearchStationItem(GameServer[i].wKindID,GameServer[i].wStationID,true);
					if (pListStation==NULL) continue;
					wStationID=GameServer[i].wStationID;
				}
				pListParent=pListStation;
			}

			//插入操作
			pListServer=new CListServer(pListParent,pListKind);
			CopyMemory(pListServer->GetItemInfo(),&GameServer[i],sizeof(tagGameServer));
			m_PtrArrayServer.Add(pListServer);
			m_pIServerListSink->OnListItemInserted(pListServer);
		}
		return true;
	}
	CATCH_COMMON_EXCEPTION(SafeDelete(pListServer);)CATCH_UNKNOWN_EXCEPTION(SafeDelete(pListServer);)_END_CATCH

	return false;
}

//插入子项
bool CServerListManager::InsertInsideItem(tagGameInside GameInside[], WORD wCount)
{
	CListInside * pListInside=NULL;
	_BEGIN_TRY
	{
		for (WORD i=0;i<wCount;i++)
		{
			pListInside=new CListInside(NULL);
			CopyMemory(pListInside->GetItemInfo(),&GameInside[i],sizeof(tagGameInside));
			m_PtrArrayInside.Add(pListInside);
			m_pIServerListSink->OnListItemInserted(pListInside);
		}
		return true;
	}
	CATCH_COMMON_EXCEPTION(SafeDelete(pListInside);)CATCH_UNKNOWN_EXCEPTION(SafeDelete(pListInside);)_END_CATCH


	return false;
}

//查找子项
CListType * CServerListManager::SearchTypeItem(WORD wTypeID)
{
	for (INT_PTR i=0;i<m_PtrArrayType.GetCount();i++)
	{
		CListType * pListType=m_PtrArrayType[i];
		tagGameType * pGameType=pListType->GetItemInfo();
		if (pGameType->wTypeID==wTypeID) return pListType;
	}
	return NULL;
}

//查找子项
CListKind * CServerListManager::SearchKindItem(WORD wKindID)
{
	for (INT_PTR i=0;i<m_PtrArrayKind.GetCount();i++)
	{
		CListKind * pListKind=m_PtrArrayKind[i];
		tagGameKind * pGameKind=pListKind->GetItemInfo();
		if (pGameKind->wKindID==wKindID) return pListKind;
	}
	return NULL;
}

//查找子项
CListProcess * CServerListManager::SearchProcessItem(WORD wKindID)
{
	for (INT_PTR i=0;i<m_PtrArrayProcess.GetCount();i++)
	{
		CListProcess * pListProcess=m_PtrArrayProcess[i];
		tagGameProcess * pGameProcess=pListProcess->GetItemInfo();
		if (pGameProcess->wKindID==wKindID) return pListProcess;
	}
	return NULL;
}

//查找子项
CListStation * CServerListManager::SearchStationItem(WORD wKindID, WORD wStationID)
{
	for (INT_PTR i=0;i<m_PtrArrayStation.GetCount();i++)
	{
		CListStation * pListStation=m_PtrArrayStation[i];
		tagGameStation * pGameStation=pListStation->GetItemInfo();
		if ((pGameStation->wStationID==wStationID)&&(pGameStation->wKindID==wKindID)) return pListStation;
	}
	return NULL;
}

//查找子项
CListServer * CServerListManager::SearchServerItem(WORD wKindID, WORD wServerID)
{
	for (INT_PTR i=0;i<m_PtrArrayServer.GetCount();i++)
	{
		CListServer * pListServer=m_PtrArrayServer[i];
		tagGameServer * pGameServer=pListServer->GetItemInfo();
		if ((pGameServer->wServerID==wServerID)&&(pGameServer->wKindID==wKindID)) return pListServer;
	}
	return NULL;
}

//更新类型
bool CServerListManager::UpdateGameKind(WORD wKindID)
{
	CListKind * pListKind=SearchKindItem(wKindID);
	if (pListKind!=NULL)
	{
		
		tagGameKind * pGameKind=pListKind->GetItemInfo();
		pListKind->m_bInstall=true;
		m_pIServerListSink->OnListItemUpdate(pListKind);
		return true;
	}

	return false;
}

//更新总数
bool CServerListManager::UpdateGameOnLineCount(DWORD dwOnLineCount)
{
	if (m_PtrArrayInside.GetCount()>0)
	{
		CListInside * pListInside=m_PtrArrayInside[0];
		tagGameInside * pGameInside=pListInside->GetItemInfo();
		_sntprintf(pGameInside->szDisplayName,sizeof(pGameInside->szDisplayName),TEXT("%s"),szProductName);
		m_pIServerListSink->OnListItemUpdate(pListInside);
		return true;
	}

	return false;
}

//类型人数
bool CServerListManager::UpdateGameKindOnLine(WORD wKindID, DWORD dwOnLineCount)
{
	//寻找类型
	CListKind * pListKind=SearchKindItem(wKindID);
	if (pListKind!=NULL)
	{
		tagGameKind * pGameKind=pListKind->GetItemInfo();
		pGameKind->dwOnLineCount=dwOnLineCount;
		m_pIServerListSink->OnListItemUpdate(pListKind);
		return true;
	}

	return false;
}

//房间人数
bool CServerListManager::UpdateGameServerOnLine(CListServer * pListServer, DWORD dwOnLineCount)
{
	//效验参数
	GT_ASSERT(pListServer!=NULL);
	if (pListServer==NULL) return false;

	//更新信息
	tagGameServer * pGameServer=pListServer->GetItemInfo();
	pGameServer->dwOnLineCount=dwOnLineCount;
	m_pIServerListSink->OnListItemUpdate(pListServer);

	return true;
}

//////////////////////////////////////////////////////////////////////////

//构造函数
CServerItemView::CServerItemView()
{
	m_bShowOnLineCount=false;
}

//析构函数
CServerItemView::~CServerItemView()
{
}

//显示人数
void CServerItemView::ShowOnLineCount(bool bShowOnLineCount)
{
	bShowOnLineCount=true;
	if (m_bShowOnLineCount!=bShowOnLineCount)
	{
		m_bShowOnLineCount=bShowOnLineCount;
	}

	return;
}

//配置函数
bool CServerItemView::InitServerItemView(ITreeCtrlSink * pITreeCtrlSink)
{
	//设置控件
	SetItemHeight(20);
	SetTextColor(RGB(72,79,63));
	SetBkColor(RGB(250,250,250));
	SendMessage(WN_SET_LINE_COLOR,0,(LPARAM)RGB(72,79,63));

	//设置变量
	GT_ASSERT(pITreeCtrlSink!=NULL);
	m_pITreeCtrlSink=pITreeCtrlSink;

	//加载图片
	if (m_ImageList.GetSafeHandle()==NULL)
	{
	
	}

	return true;
}

//展开列表
bool __cdecl CServerItemView::ExpandListItem(CListItem * pListItem)
{
	//效验参数
	GT_ASSERT(pListItem!=NULL);

	//展开列表
	HTREEITEM hTreeItem=(HTREEITEM)pListItem->GetItemData();
	if (hTreeItem!=NULL) 
	{
		Expand(hTreeItem,TVE_EXPAND);
		return true;
	}

	return false;
}

//更新通知
void __cdecl CServerItemView::OnListItemUpdate(CListItem * pListItem)
{
	//效验参数
	GT_ASSERT(pListItem!=NULL);

	//更新显示
	switch (pListItem->GetItemGenre())
	{
	case ItemGenre_Kind:		//游戏类型
		{
			//变量定义
			CListKind * pListKind=(CListKind *)pListItem;

			//获取信息
			TCHAR szItemTitle[128]=TEXT("");
			DWORD dwImageIndex=GetGameImageIndex(pListKind);
			GetGameItemTitle(pListKind,szItemTitle,sizeof(szItemTitle));

			//更新树项
			HTREEITEM hTreeItem=(HTREEITEM)pListKind->GetItemData();
			SetItem(hTreeItem,TVIF_IMAGE|TVIF_TEXT|TVIF_SELECTEDIMAGE,szItemTitle,dwImageIndex,dwImageIndex,0,0,0);

			return;
		}
	case ItemGenre_Process:		//进程类型
		{
			//变量定义
			CListProcess * pListProcess=(CListProcess *)pListItem;

			//获取信息
			TCHAR szItemTitle[128]=TEXT("");
			DWORD dwImageIndex=GetGameImageIndex(pListProcess);
			GetGameItemTitle(pListProcess,szItemTitle,sizeof(szItemTitle));

			//更新树项
			HTREEITEM hTreeItem=(HTREEITEM)pListProcess->GetItemData();
			SetItem(hTreeItem,TVIF_IMAGE|TVIF_TEXT,szItemTitle,dwImageIndex,dwImageIndex,0,0,0);

			return;
		}
	case ItemGenre_Server:		//游戏房间
		{
			//变量定义
			CListServer * pListServer=(CListServer *)pListItem;
			tagGameServer * pGameServer=pListServer->GetItemInfo();

			//获取信息
			TCHAR szItemTitle[128]=TEXT("");
			GetGameItemTitle(pListServer,szItemTitle,sizeof(szItemTitle));

			//更新显示
			HTREEITEM hTreeItem=(HTREEITEM)pListServer->GetItemData();
			SetItemText(hTreeItem,szItemTitle);

			//更新类型
			INT_PTR nIndex=0;
			CListItem * pListItemTemp=NULL;
			CListKind * pListKind=pListServer->GetListKind();
			tagGameKind * pGameKind=pListKind->GetItemInfo();
			pGameKind->dwOnLineCount=0L;
			do
			{
				pListItemTemp=pListKind->EnumChildItem(nIndex++);
				if (pListItemTemp==NULL) break;
				if (pListItemTemp->GetItemGenre()==ItemGenre_Server)
				{
					pListServer=(CListServer *)pListItemTemp;
					pGameKind->dwOnLineCount+=pListServer->GetItemInfo()->dwOnLineCount;
				}
			} while (true);

			//更新显示
			GetGameItemTitle(pListKind,szItemTitle,sizeof(szItemTitle));
			hTreeItem=(HTREEITEM)pListKind->GetItemData();
			SetItemText(hTreeItem,szItemTitle);

			return;
		}
	case ItemGenre_Inside:	//内部类型
		{
			//变量定义
			CListInside * pListInside=(CListInside *)pListItem;
			tagGameInside * pGameInside=pListInside->GetItemInfo();

			//消息处理
			HTREEITEM hTreeItem=(HTREEITEM)pListInside->GetItemData();
			SetItemText(hTreeItem,pGameInside->szDisplayName);

			return;
		}
	}

	return;
}

//插入通知
void __cdecl CServerItemView::OnListItemInserted(CListItem * pListItem)
{
	//效验参数
	GT_ASSERT(pListItem!=NULL);

	//变量定义
	TV_INSERTSTRUCT InsertInf;
	memset(&InsertInf,0,sizeof(InsertInf));

	//设置变量
	InsertInf.item.cchTextMax=128;
	InsertInf.hInsertAfter=TVI_LAST;
	InsertInf.item.lParam=(LPARAM)pListItem;
	InsertInf.item.mask=TVIF_IMAGE|TVIF_SELECTEDIMAGE|TVIF_TEXT|TVIF_PARAM;

	//寻找父项
	CListItem * pListParent=pListItem->GetParentItem();
	if (pListParent!=NULL) InsertInf.hParent=(HTREEITEM)pListParent->GetItemData();

	//获取信息
	TCHAR szItemTitle[128]=TEXT("");

	//构造数据
	switch (pListItem->GetItemGenre())
	{
	case ItemGenre_Type:		//游戏类型
		{
			//变量定义
			CListType * pListType=(CListType *)pListItem;
			tagGameType * pGameType=pListType->GetItemInfo();

			//构造数据
			InsertInf.item.iImage=IND_TYPE;
			InsertInf.item.iSelectedImage=IND_TYPE;
			_sntprintf(szItemTitle,128,TEXT("%s (ID:%d Sort:%d--Image:%d)"),(LPCSTR)(pGameType->szTypeName), 
				(int)pGameType->wTypeID, 
				(int)pGameType->wSortID,
				(int)pGameType->nbImageID);
			InsertInf.item.pszText=szItemTitle;
			pListType->SetItemData((DWORD_PTR)InsertItem(&InsertInf));
			SetItemState((HTREEITEM)pListType->GetItemData(),TVIS_BOLD,TVIS_BOLD);

			break;
		}
	case ItemGenre_Kind:		//游戏种类
		{
			//变量定义
			CListKind * pListKind=(CListKind *)pListItem;
			tagGameKind * pGameKind=pListKind->GetItemInfo();

			DWORD dwImageIndex=GetGameImageIndex(pListKind);
			
			_sntprintf(szItemTitle,128,TEXT("%s (ID:%d Sort:%d--类型:%s 桌子数目:%d 上/下限:%d/%d 入场卷:%d 抽水率:%f)"),(LPCSTR)(pGameKind->szKindName), 
				(int)pGameKind->wKindID,
				(int)pGameKind->wSortID,
				GetGameTypeName(pGameKind->wProcessType),
				(int)pGameKind->wTableCount,
				(int)pGameKind->dwCellScore,
				(int)pGameKind->dwHighScore,
				(int)pGameKind->dwLessScore,
				pGameKind->fTaxRate);

			//设置数据
			InsertInf.item.pszText=szItemTitle;
			InsertInf.item.iImage=dwImageIndex;
			InsertInf.item.iSelectedImage=dwImageIndex;
			pListKind->SetItemData((DWORD_PTR)InsertItem(&InsertInf));

			break;
		}
	case ItemGenre_Process:		//游戏进程
		{
			//变量定义
			CListProcess * pListProcess=(CListProcess *)pListItem;
			tagGameProcess * pGameProcess=pListProcess->GetItemInfo();

			//获取信息
			TCHAR szItemTitle[128]=TEXT("");
			DWORD dwImageIndex=GetGameImageIndex(pListProcess);
			GetGameItemTitle(pListProcess,szItemTitle,sizeof(szItemTitle));
			
			_sntprintf(szItemTitle,128,TEXT("%s"),(LPCSTR)(szItemTitle));

			//设置数据
			InsertInf.item.pszText=szItemTitle;
			InsertInf.item.iImage=dwImageIndex;
			InsertInf.item.iSelectedImage=dwImageIndex;
			pListProcess->SetItemData((DWORD_PTR)InsertItem(&InsertInf));

			break;
		}
	case ItemGenre_Station:		//游戏站点
		{
			//变量定义
			CListStation * pListStation=(CListStation *)pListItem;
			tagGameStation * pGameStation=pListStation->GetItemInfo();

			_sntprintf(szItemTitle,128,TEXT("%s (ID:%d Sort:%d)"),(LPCSTR)(pGameStation->szStationName),
				(int)pGameStation->wStationID,
				(int)pGameStation->wSortID);
			//设置数据
			InsertInf.item.iImage=IND_STATION;
			InsertInf.item.iSelectedImage=IND_STATION;
			InsertInf.item.pszText=szItemTitle;
			pListStation->SetItemData((DWORD_PTR)InsertItem(&InsertInf));

			break;
		}
	case ItemGenre_Server:		//游戏房间
		{
			//变量定义
			CListServer * pListServer=(CListServer *)pListItem;
			tagGameServer * pGameServer=pListServer->GetItemInfo();

			//构造标题
			TCHAR szItemTitle[128]=TEXT("");
			DWORD dwImageIndex=GetGameImageIndex(pListServer);
			
			_sntprintf(szItemTitle,128,TEXT("%s (ID:%d Sort:%d--最大人数:%d)"),(LPCSTR)(pGameServer->szServerName), 
				(int)pGameServer->wServerID,
				(int)pGameServer->wSortID,
				(int)pGameServer->wMaxConnect);

			//设置数据
			InsertInf.item.pszText=szItemTitle;
			InsertInf.item.iImage=dwImageIndex;
			InsertInf.item.iSelectedImage=dwImageIndex;
			pListServer->SetItemData((DWORD_PTR)InsertItem(&InsertInf));

			break;
		}
	case ItemGenre_Inside:		//内部数据
		{
			//插入分析
			CListInside * pListInside=(CListInside *)pListItem;
			tagGameInside * pGameInside=pListInside->GetItemInfo();

			//设置数据
			TCHAR szItemTitle[128]=TEXT("");
			_sntprintf(szItemTitle,128,TEXT("%s"),(LPCSTR)(pGameInside->szDisplayName));

			InsertInf.item.iImage=pGameInside->iImageIndex;
			InsertInf.item.iSelectedImage=pGameInside->iImageIndex;
			InsertInf.item.pszText=szItemTitle;
			pListInside->SetItemData((DWORD_PTR)InsertItem(&InsertInf));
			SetItemState((HTREEITEM)pListInside->GetItemData(),TVIS_BOLD,TVIS_BOLD);

			break;
		}
	}
	
	return;
}

//左击列表
void CServerItemView::OnNMClick(NMHDR * pNMHDR, LRESULT * pResult)
{
	//变量定义
	CListItem * pListItem=NULL;
	HTREEITEM hTreeItem=GetCurrentTreeItem();

	//展开列表
	if (hTreeItem!=NULL)
	{
		Select(hTreeItem,TVGN_CARET);
		pListItem=(CListItem *)GetItemData(hTreeItem);
	}

	//发送消息
	GT_ASSERT(m_pITreeCtrlSink!=NULL);
	m_pITreeCtrlSink->OnTreeLeftClick(pListItem,hTreeItem,this);

	return;
}

//右击列表
void CServerItemView::OnNMRclick(NMHDR * pNMHDR, LRESULT * pResult)
{
	//变量定义
	CListItem * pListItem=NULL;
	HTREEITEM hTreeItem=GetCurrentTreeItem();

	//选择列表
	if (hTreeItem!=NULL)
	{
		Select(hTreeItem,TVGN_CARET);
		pListItem=(CListItem *)GetItemData(hTreeItem);
	}

	//发送消息
	GT_ASSERT(m_pITreeCtrlSink!=NULL);
	m_pITreeCtrlSink->OnTreeRightClick(pListItem,hTreeItem,this);

	return;
}

//左键双击
void CServerItemView::OnNMDblclk(NMHDR * pNMHDR, LRESULT * pResult)
{
	//变量定义
	CListItem * pListItem=NULL;
	HTREEITEM hTreeItem=GetCurrentTreeItem();

	//展开列表
	if (hTreeItem!=NULL)
	{
		Select(hTreeItem,TVGN_CARET);
		pListItem=(CListItem *)GetItemData(hTreeItem);
	}

	//发送消息
	GT_ASSERT(m_pITreeCtrlSink!=NULL);
	m_pITreeCtrlSink->OnTreeLeftDBClick(pListItem,hTreeItem,this);

	return;
}

//右键双击
void CServerItemView::OnNMRdblclk(NMHDR * pNMHDR, LRESULT * pResult)
{
	//变量定义
	CListItem * pListItem=NULL;
	HTREEITEM hTreeItem=GetCurrentTreeItem();

	//展开列表
	if (hTreeItem!=NULL)
	{
		Select(hTreeItem,TVGN_CARET);
		pListItem=(CListItem *)GetItemData(hTreeItem);
	}

	//发送消息
	GT_ASSERT(m_pITreeCtrlSink!=NULL);
	m_pITreeCtrlSink->OnTreeRightDBClick(pListItem,hTreeItem,this);

	return;
}

//选择改变
void CServerItemView::OnTvnSelchanged(NMHDR * pNMHDR, LRESULT * pResult)
{
	LPNMTREEVIEW pNMTreeView=reinterpret_cast<LPNMTREEVIEW>(pNMHDR);

	//变量定义
	CListItem * pListItem=NULL;
	HTREEITEM hTreeItem=pNMTreeView->itemNew.hItem;
	if (hTreeItem!=NULL) pListItem=(CListItem *)pNMTreeView->itemNew.lParam;

	//发送消息
	GT_ASSERT(m_pITreeCtrlSink!=NULL);
	m_pITreeCtrlSink->OnTreeSelectChanged(pListItem,hTreeItem,this);

	return;
}

//列表展开
void CServerItemView::OnTvnItemexpanded(NMHDR * pNMHDR, LRESULT * pResult)
{
	LPNMTREEVIEW pNMTreeView=reinterpret_cast<LPNMTREEVIEW>(pNMHDR);

	//变量定义
	CListItem * pListItem=NULL;
	HTREEITEM hTreeItem=pNMTreeView->itemNew.hItem;
	if (hTreeItem!=NULL) pListItem=(CListItem *)pNMTreeView->itemNew.lParam;

	//发送消息
	GT_ASSERT(m_pITreeCtrlSink!=NULL);
	m_pITreeCtrlSink->OnTreeItemexpanded(pListItem,hTreeItem,this);

	return;
}

//按钮测试
HTREEITEM CServerItemView::GetCurrentTreeItem()
{
	TVHITTESTINFO HitTestInfo;
	memset(&HitTestInfo,0,sizeof(HitTestInfo));
	HitTestInfo.flags=TVHT_ONITEM;
	GetCursorPos(&HitTestInfo.pt);
	ScreenToClient(&HitTestInfo.pt);
	return TreeView_HitTest(m_hWnd,&HitTestInfo);
}

//获取图标
DWORD CServerItemView::GetGameImageIndex(CListKind * pListKind)
{
	//效验参数
	GT_ASSERT(pListKind!=NULL);
	
	//安装判断
	if (pListKind->m_bInstall==false) return IND_KIND_NODOWN;

	//获取图标
	tagGameKind * pGameKind=pListKind->GetItemInfo();
	DWORD dwImageIndex=0;

	return dwImageIndex;
}

//获取图标
DWORD CServerItemView::GetGameImageIndex(CListServer * pListServer)
{
	return IND_SERVER_NORNAL;
}

//获取图标
DWORD CServerItemView::GetGameImageIndex(CListProcess * pListProcess)
{
	//效验参数
	GT_ASSERT(pListProcess!=NULL);
	
	//安装判断
	if (pListProcess->m_bInstall==false) return IND_KIND_NODOWN;

	//获取图标
	tagGameProcess * pGameProcess=pListProcess->GetItemInfo();
	DWORD dwImageIndex=0;

	return dwImageIndex;
}

//获取图标
DWORD CServerItemView::GetGameImageIndex(LPCTSTR pszProcess, WORD wKindID)
{
	//寻找现存
	tagGameResourceInfo * pGameResourceInfo=NULL;
	for (INT_PTR i=0;i<m_GameResourceArray.GetCount();i++)
	{
		pGameResourceInfo=&m_GameResourceArray[i];
		if (pGameResourceInfo->wKindID==wKindID) return pGameResourceInfo->dwImageIndex;
	}

	//加载资源
	HINSTANCE hInstance=AfxLoadLibrary(pszProcess);
	if (hInstance==NULL) return IND_KIND_UNKNOW;
	
	//加载标志
	CBitmap GameLogo;
	DWORD dwImagePos=0L;
	AfxSetResourceHandle(hInstance);
	if (GameLogo.LoadBitmap(TEXT("GAME_LOGO"))) dwImagePos=m_ImageList.Add(&GameLogo,RGB(255,0,255));
	AfxSetResourceHandle(GetModuleHandle(NULL));
	AfxFreeLibrary(hInstance);

	//保存信息
	if (dwImagePos!=0L)
	{
		tagGameResourceInfo GameResourceInfo;
		memset(&GameResourceInfo,0,sizeof(GameResourceInfo));
		GameResourceInfo.wKindID=wKindID;
		GameResourceInfo.dwImageIndex=dwImagePos;
		m_GameResourceArray.Add(GameResourceInfo);
		return GameResourceInfo.dwImageIndex;
	}
	
	return IND_KIND_UNKNOW;
}

//获取标题
LPCTSTR CServerItemView::GetGameItemTitle(CListKind * pListKind, LPTSTR pszTitle, WORD wBufferSize)
{
	//效验参数
	GT_ASSERT(pszTitle!=NULL);
	GT_ASSERT(pListKind!=NULL);

	//生成标题
	tagGameKind * pGameKind=pListKind->GetItemInfo();
	if (m_bShowOnLineCount==true)
	{
		if (pListKind->m_bInstall==true)
		{
			_sntprintf(pszTitle,wBufferSize,TEXT("%s [ %ld ]"),pGameKind->szKindName,pGameKind->dwOnLineCount);
		}
		else
		{
			_sntprintf(pszTitle,wBufferSize,TEXT("%s [ %ld ] （未安装）"),pGameKind->szKindName,pGameKind->dwOnLineCount);
		}
	}
	else
	{
		if (pListKind->m_bInstall==true)
		{
			_sntprintf(pszTitle,wBufferSize,TEXT("%s"),pGameKind->szKindName);
		}
		else
		{
			_sntprintf(pszTitle,wBufferSize,TEXT("%s （未安装）"),pGameKind->szKindName);
		}
	}

	return pszTitle;
}

//获取标题
LPCTSTR CServerItemView::GetGameItemTitle(CListProcess * pListProcess, LPTSTR pszTitle, WORD wBufferSize)
{
	//效验参数
	GT_ASSERT(pszTitle!=NULL);
	GT_ASSERT(pListProcess!=NULL);

	//生成标题
	tagGameProcess * pGameProcess=pListProcess->GetItemInfo();
	if (m_bShowOnLineCount==true)
	{
		if (pListProcess->m_bInstall==true)
		{
			_sntprintf(pszTitle,wBufferSize,TEXT("%s [ %ld ]"),pGameProcess->szKindName,pGameProcess->dwOnLineCount);
		}
		else
		{
			_sntprintf(pszTitle,wBufferSize,TEXT("%s [ %ld ] （未安装）"),pGameProcess->szKindName,pGameProcess->dwOnLineCount);
		}
	}
	else
	{
		if (pListProcess->m_bInstall==true)
		{
			_sntprintf(pszTitle,wBufferSize,TEXT("%s"),pGameProcess->szKindName);
		}
		else
		{
			_sntprintf(pszTitle,wBufferSize,TEXT("%s （未安装）"),pGameProcess->szKindName);
		}
	}

	return pszTitle;
}

//获取标题
LPCTSTR CServerItemView::GetGameItemTitle(CListServer * pListServer, LPTSTR pszTitle, WORD wBufferSize)
{
	//效验参数
	GT_ASSERT(pszTitle!=NULL);
	GT_ASSERT(pListServer!=NULL);

	//生成标题
	tagGameServer * pGameServer=pListServer->GetItemInfo();
	if (m_bShowOnLineCount==true)
	{
		_sntprintf(pszTitle,wBufferSize,TEXT("%s [ %ld ]"),pGameServer->szServerName,pGameServer->dwOnLineCount);
	}
	else 
	{
		_sntprintf(pszTitle,wBufferSize,TEXT("%s"),pGameServer->szServerName);
	}

	return pszTitle;
}

//////////////////////////////////////////////////////////////////////////
