create or replace view KSFPA.ONLINE_UGAM_PVT.SHIPMENT_SUPER(
	FY_PW,
	FYP_RANK,
	STATE,
	STORE_NO,
	STORE,
	TRANSACTION_COUNT,
	SHIPMENT_COUNT,
	UNITS,
	DD_ORDER_TYPE,
	YEAR
) as

select   
  CONCAT('FY',ACCOUNTING_YEAR,'P',RIGHT(ACCOUNTING_PERIOD_NUMBER,2),'W',ACCOUNTING_WEEK_NUMBER) AS FY_PW, 
  DENSE_RANK() OVER(ORDER BY FY_PW DESC) AS FYP_RANK,
  dl.STATE AS STATE,
  DL.LOCATION_CODE AS Store_No,
  DL.LOCATION_NAME AS Store,
  COUNT(DISTINCT fact.DD_EXTERNALORDERID) AS TRANSACTION_COUNT,
  COUNT(DISTINCT fact.DD_DOMSHIPMENTID) AS SHIPMENT_COUNT, 
  COUNT(DISTINCT fact.QUANTITY_SOLD) as UNITS,
  fact.DD_ORDER_TYPE as DD_ORDER_TYPE,
  d.accounting_year as Year
from KSF_SOPHIA_DATA_INTELLIGENCE_HUB_PROD.SALES.FACT_SALES_DETAIL fact 
join KSF_SOPHIA_DATA_INTELLIGENCE_HUB_PROD.COMMON_DIMENSIONS.DIM_DATE d
on d.SK_DATE_ID=fact.FK_DATE_ID
join KSF_SOPHIA_DATA_INTELLIGENCE_HUB_PROD.COMMON_DIMENSIONS.DIM_LOCATION dl
on dl.sk_location_id = fact.fk_location_id
where DD_EXTERNALORDERID is not NULL and DD_EXTERNALORDERID>0 
and FK_SOURCE_SYSTEM_ID=15 
and d.ACCOUNTING_YEAR >= 2023 
GROUP BY 1,3,4,5,9,10;