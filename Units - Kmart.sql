create or replace view KSFPA.ONLINE_UGAM_PVT.VW_KMART_UNITS_SUMMARY_SUPER(
	FY_PW,
	FYP_RANK,
	FK_CREATED_DATE,
	STORE_NO,
	STATE,
	ORDER_TYPE,
	UNITS_ASSIGNED,
	UNITS_COMPLETED,
	UNITS_REJECTED,
	LOST_SALES
) as


SELECT
FY_PW,
FYP_RANK,
FK_CREATED_DATE,
STORE_NO,
STATE,
ORDER_TYPE,
SUM(UnitsAttempted) AS Units_Assigned,
SUM(UnitsPicked) AS Units_Completed,
SUM(QtyRejected) AS Units_Rejected,
SUM(UA_SALES) - SUM(UP_SALES) AS Lost_Sales

FROM(

SELECT 
    concat('FY',accounting_year, 'P', right(accounting_period_number,2), 'W', accounting_week_number) FY_PW,
    DENSE_RANK() OVER(ORDER BY FY_PW DESC) AS FYP_RANK,
    spo.Str_ID AS STORE_NO,
    DL.STATE AS STATE,
    SPO.ORDERID AS ORDER_ID,
    DATE(spo.DO_Modified) AS FK_CREATED_DATE,
    CUST.CUSTOMERORDERTYPE AS ORDER_TYPE,
    SUM(spo.QtyRequired) AS UnitsAttempted,
    SUM(SPO.QTYREQUIRED * SOI.UNITPRICE) AS UA_SALES,
    SUM(spo.QtyPicked) AS UnitsPicked,
    SUM(SPO.QtyPicked * SOI.UNITPRICE) AS UP_SALES,
    SUM(spo.QtyRequired) - SUM(spo.QtyPicked) AS QtyRejected,
    

FROM 
    KSFPA.OMS.StorePick_OrderItems spo
    LEFT JOIN KSFPA.OMS.Storeorder so ON spo.Str_ID = so.Str_ID AND spo.OrderID = so.OrderID
    LEFT JOIN KSFPA.OMS.StoreOrderItems soi ON spo.OrderID = soi.OrderID AND spo.Str_ID = soi.Str_ID AND spo.SKU = soi.SKU
    LEFT JOIN KSFPA.MR2C.KEYCODE KC ON spo.SKU = KC.PRODUCT_SOURCE_IDENTIFIER  
    LEFT JOIN KSFPA.OMS.Storepick sp ON spo.StorePickID = sp.StorePickID
    LEFT JOIN KSF_SOPHIA_DATA_INTELLIGENCE_HUB_PROD.COMMON_DIMENSIONS.DIM_DATE dd
    ON dd.date=date(spo.do_modified)
    LEFT JOIN KSFPA.OMS.CUSTOMERORDER CUST 
    ON SO.ORDERID = CUST.ORDERID
    LEFT JOIN KSF_SOPHIA_DATA_INTELLIGENCE_HUB_PROD.COMMON_DIMENSIONS.DIM_LOCATION DL
    ON spo.str_id::varchar=dl.location_code::varchar
WHERE 
    spo.DO_Modified >= DATE '2024-01-01'
    AND spo.DO_Modified < DATE_TRUNC('DAY', CURRENT_DATE)
    AND sp.StorePickStatus IN ('PickingComplete')
    AND spo.Str_ID NOT IN ('9995','9996','9997','9998','9999')
    AND spo.QtyRequired IS NOT NULL
GROUP BY 
    FY_PW,
    STORE_NO,
    STATE,
    ORDER_TYPE,
    ORDER_ID,
    DATE(spo.DO_Modified),
    accounting_year,
    accounting_period_number,
    accounting_week_number
    
ORDER BY 
    STORE_NO,
    DATE(spo.DO_Modified)

    )
    GROUP BY 1,2,3,4,5,6;
