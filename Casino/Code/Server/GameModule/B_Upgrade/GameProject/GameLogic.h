#ifndef GAME_LOGIC_HEAD_FILE
#define GAME_LOGIC_HEAD_FILE

#pragma once

//////////////////////////////////////////////////////////////////////////
//宏定义

//牌副定义
#define CELL_PACK					54									//单元数目

//属性定义
#define MAX_COUNT					60									//最大数目
#define MAX_TRACKOR					18									//最大连牌
#define	COLOR_RIGHT					40									//花色权位

//无效定义
#define CT_ERROR					0									//错误类型
#define VALUE_ERROR					0x00								//数值定义
#define COLOR_ERROR					0xFF								//花色定义

//花色定义
#define COLOR_NT					0x40								//花色定义
#define COLOR_HEI_TAO				0x30								//花色定义
#define COLOR_HONG_TAO				0x20								//花色定义
#define COLOR_MEI_HUA				0x10								//花色定义
#define COLOR_FANG_KUAI				0x00								//花色定义

//数值掩码
#define	LOGIC_MASK_COLOR			0xF0								//花色掩码
#define	LOGIC_MASK_VALUE			0x0F								//数值掩码

//扑克类型
#define CT_ERROR					0									//错误类型
#define CT_SINGLE					1									//单牌类型
#define CT_SAME_2					2									//对牌类型
#define CT_SAME_3					3									//三牌类型
#define CT_SAME_4					4									//四牌类型
#define CT_TRACKOR_2				5									//拖拉机型
#define CT_TRACKOR_3				6									//拖拉机型
#define CT_TRACKOR_4				7									//拖拉机型
#define CT_THROW_CARD				8									//甩牌类型

//////////////////////////////////////////////////////////////////////////
//结构定义

//连牌信息
struct tagSameDataInfo
{
	BYTE							cbCardCount;						//扑克数目
	BYTE							cbBlockCount;						//牌段数目
	BYTE							cbSameData[MAX_COUNT];				//拖拉机牌
};

//拖拉机信息
struct tagTractorDataInfo
{
	BYTE							cbCardCount;						//扑克数目
	BYTE							cbTractorCount;						//拖牌个数
	BYTE							cbTractorMaxIndex;					//索引位置
	BYTE							cbTractorMaxLength;					//最大长度
	BYTE							cbTractorData[MAX_COUNT*3/2];		//拖拉机牌
};

//牌型结构
struct tagAnalyseResult
{
	BYTE							cbCardColor;						//扑克花色
	tagSameDataInfo					SameDataInfo[2];					//同牌数据
	tagTractorDataInfo				TractorDataInfo[2-1];				//拖牌数据
};

//最大牌型结构
struct tagAnalyseMostResult
{
	tagTractorDataInfo				TractorDataInfo[5][MAX_COUNT/2];	//拖牌数据
	BYTE							cbTractorDataInfoCount[5];			//拖牌数目
	tagSameDataInfo					SameDataInfo[5][MAX_COUNT/2];		//同牌数据
	BYTE							cbSameDataInfoInfoCount[5];			//同牌数目
	BYTE							cbSingleCardData[5][MAX_COUNT];		//单牌数据
	BYTE							cbSingleCardCount[5];				//单牌个数
};

//需求结构
struct tagDemandInfo
{
	BYTE 							cbMaxTractor[2-1];					//长度需求
	BYTE							cbSameCardCount[2];					//同牌需求
	BYTE 							cbTractorCardCount[2-1];			//拖牌需求
};

//出牌结果
struct tagOutCardResult
{
	BYTE							cbCardCount;						//扑克数目
	BYTE							cbResultCard[MAX_COUNT];			//结果扑克
};

//////////////////////////////////////////////////////////////////////////

//游戏逻辑类
class CGameLogic
{
	//属性变量
protected:
	BYTE							m_cbPackCount;						//牌副数目
	BYTE							m_cbDispatchCount;					//派发数目

	//逻辑变量
protected:
	BYTE							m_cbMainColor;						//主牌花色
	BYTE							m_cbMainValue;						//主牌数值

	//辅助变量
protected:
	BYTE							m_cbSortRight[5];					//排序权位

	//变量定义
public:
	static const BYTE				m_cbNTValue;						//常主数值
	static const BYTE				m_cbCardData[CELL_PACK];			//扑克数据

	//函数定义
public:
	//构造函数
	CGameLogic();
	//析构函数
	virtual ~CGameLogic();

	//状态设置
public:
	//设置副数
	bool SetPackCount(BYTE cbPackCount);
	//获取副数
	BYTE GetPackCount() { return m_cbPackCount; }
	//派发数目
	BYTE GetDispatchCount() { return m_cbDispatchCount; }

	//信息函数
public:
	//主牌花色
	bool SetMainColor(BYTE cbMainColor);
	//主牌数值
	bool SetMainValue(BYTE cbMainValue);
	//主牌花色
	BYTE GetMainColor() { return m_cbMainColor; }
	//主牌数值
	BYTE GetMainValue() { return m_cbMainValue; }

	//控制函数
public:
	//排列扑克
	void SortCardList(BYTE cbCardData[], BYTE cbCardCount);
	//混乱扑克
	void RandCardList(BYTE cbCardBuffer[], BYTE cbBufferCount);
	//删除扑克
	bool RemoveCard(const BYTE cbRemoveCard[], BYTE cbRemoveCount, BYTE cbCardData[], BYTE cbCardCount);

	//额度函数
public:
	//获取额度
	WORD GetCardScore(const BYTE cbCardData[], BYTE cbCardCount);
	//额度扑克
	BYTE GetScoreCard(const BYTE cbCardData[], BYTE cbCardCount, BYTE cbScoreCard[], BYTE cbMaxCount);

	//功能函数
public:
	//分析扑克
	bool AnalyseCardData(const BYTE cbCardData[], BYTE cbCardCount, tagAnalyseResult & AnalyseResult);
	//出牌判断
	bool SearchOutCard(const BYTE cbHandCardData[], BYTE cbHandCardCount,const  BYTE cbTurnCardData[], BYTE cbTurnCardCount, tagOutCardResult & OutCardResult);
	//出牌判断
	bool SearchMostOutCard(const BYTE cbHandCardData[], BYTE cbHandCardCount,const  BYTE cbTurnCardData[], BYTE cbTurnCardCount, tagOutCardResult & OutCardResult);
	//效验出牌
	bool EfficacyOutCard(const BYTE cbOutCardData[], BYTE cbOutCardCount, const BYTE cbFirstCardData[], BYTE cbFirstCardCount, const BYTE cbHandCardData[], BYTE cbHandCardCount);
	//效验甩牌
	bool EfficacyThrowCard(const BYTE cbOutCardData[], BYTE cbOutCardCount, WORD wOutCardIndex, const BYTE cbHandCardData[GAME_PLAYER][MAX_COUNT], BYTE cbHandCardCount, tagOutCardResult & OutCardResult);
	//分牌
	bool SplitCardByColor(const BYTE cbCardData[], BYTE cbCardCount,BYTE cbResultCardData[5][MAX_COUNT],BYTE cbResultCardCount[5]);
	

	//对比函数
public:
	//对比扑克
	bool CompareCardData(BYTE cbFirstCardData, BYTE cbNextCardData);
	//对比扑克
	bool CompareCardResult(const tagAnalyseResult WinnerResult, const tagAnalyseResult UserResult);
	//对比扑克
	bool CompareCardResult(const tagTractorDataInfo WinnerResult, const tagTractorDataInfo UserResult);
	//对比扑克
	bool CompareCardResult(const tagSameDataInfo WinnerResult, const tagSameDataInfo UserResult);
	//对比扑克
	WORD CompareCardArray(const BYTE cbOutCardData[GAME_PLAYER][MAX_COUNT], BYTE cbCardCount, WORD wFirstIndex);
	//对比扑克
	tagTractorDataInfo GetMostTractorDataInfo(tagTractorDataInfo TractorDataInfo[MAX_COUNT/2],
		BYTE cbTrackorCount);
	//对比扑克
	tagSameDataInfo GetMostSameDataInfo(tagSameDataInfo SameDataInfo[MAX_COUNT/2],
		BYTE cbSameDataInfoCount);
	//对比扑克
	BYTE GetMostSingleCard(BYTE cbCardData[], BYTE cbCardCount);

	//类型函数
public:
	//获取类型
	BYTE GetCardType(const BYTE cbCardData[], BYTE cbCardCount);
	//获取数值
	BYTE GetCardValue(BYTE cbCardData) { return cbCardData&LOGIC_MASK_VALUE; }
	//获取花色
	BYTE GetCardColor(BYTE cbCardData) { return cbCardData&LOGIC_MASK_COLOR; }

	//逻辑函数
public:
	//有效判断
	bool IsValidCard(BYTE cbCardData);
	//排序等级
	BYTE GetCardSortOrder(BYTE cbCardData);
	//逻辑数值
	BYTE GetCardLogicValue(BYTE cbCardData);
	//逻辑花色
	BYTE GetCardLogicColor(BYTE cbCardData);
	//牌列花色
	BYTE GetCardLogicColor(const BYTE cbCardData[], BYTE cbCardCount);
	//牌列花色数目
	BYTE GetCardColorCount(const BYTE cbCardData[], BYTE cbCardCount,BYTE cbColorData[4]);
	//获取索引
	BYTE GetAnalyseMostResultIndexByCardColor(BYTE cbCardColor);


	//逻辑辅助
protected:
	//是否相连
	bool IsLineValue(BYTE cbFirstCard, BYTE cbSecondCard);
	//是否同花
	bool IsSameColor(BYTE cbFirstCard, BYTE cbSecondCard);
	//交集数目
	BYTE GetIntersectionCount(const BYTE cbCardData1[], BYTE cbCardCount1, const BYTE cbCardData2[], BYTE cbCardCount2);
	//判断相同
	bool HaveSameCardData(const BYTE cbCardData[], BYTE cbCardCount,BYTE cbSameCardDataIndex);

	//提取函数
protected:
	//提取扑克
	BYTE DistillCardByColor(const BYTE cbCardData[], BYTE cbCardCount, BYTE cbCardColor, BYTE cbResultCard[]);
	//提取扑克
	BYTE DistillCardByCount(const BYTE cbCardData[], BYTE cbCardCount, BYTE cbSameCount, tagSameDataInfo & SameDataInfo);
	//提取扑克
	BYTE DistillTrackorByCount(const BYTE cbCardData[], BYTE cbCardCount, BYTE cbSameCount, tagTractorDataInfo & TractorDataInfo);
	//提取扑克
	BYTE DistillSpiltTrackorByCount(const BYTE cbCardData[], BYTE cbCardCount, BYTE cbSameCount, tagTractorDataInfo TractorDataInfo[MAX_TRACKOR/2]);
	//提取扑克
	BYTE DistillSpiltSameDataInfoByCount(const BYTE cbCardData[], BYTE cbCardCount, BYTE cbSameCount, tagSameDataInfo  SameDataInfo[MAX_TRACKOR/2]);
public:
	//提取扑克
	BYTE DistillSingleCard(const BYTE cbCardData[], BYTE cbCardCount, BYTE cbMainColor, BYTE cbMainValue, BYTE cbResultCard[]);
	//提取扑克
	BYTE DistillMostCard(const BYTE cbCardData[], BYTE cbCardCount, tagAnalyseMostResult & AnalyseResult);

	//内部函数
protected:
	//更新权位
	void UpdateSortRight();
	//调整扑克
	bool RectifyCardWeave(const BYTE cbCardData[], BYTE cbCardCount, const tagAnalyseResult & TargetResult, tagAnalyseResult & RectifyResult);
};

//////////////////////////////////////////////////////////////////////////

#endif