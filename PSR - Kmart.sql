create or replace view KSFPA.ONLINE_UGAM_PVT.PSR_KMART_SUPER(
	FY_PW,
	FYP_RANK,
	FK_CREATED_DATE,
	STORE_NO,
	STATE,
	ORDER_TYPE,
	UNITS_RECEIVED,
	UNITS_PICKED,
	DIF
) as 


SELECT 
        concat('FY',accounting_year, 'P', right(accounting_period_number,2), 'W', accounting_week_number) FY_PW,
        DENSE_RANK() OVER(ORDER BY FY_PW DESC) AS FYP_RANK,
        date(spo.do_modified) AS FK_CREATED_DATE, 
        spo.str_id AS STORE_NO,
        DL.state AS STATE,
        CUST.CUSTOMERORDERTYPE AS ORDER_TYPE,
        --     CASE	
        -- WHEN MAX(so.InStore_Flag) IN ('1') THEN 'CC'
        -- WHEN MAX(so.InStore_Flag) IN ('0') THEN 'STD'
        -- ELSE NULL -- Change this to another value if needed
        -- END AS customerordertype,        
        sum(qtyrequired) AS units_received,
        sum(qtypicked) AS units_picked,
        sum(qtypicked)/sum(qtyrequired)*100 AS DIF

FROM
    ksfpa.oms.storepick_orderitems spo
    LEFT JOIN KSFPA.OMS.Storepick sp ON spo.StorePickID = sp.StorePickID
    left join KSF_SOPHIA_DATA_INTELLIGENCE_HUB_PROD.COMMON_DIMENSIONS.DIM_DATE dd
    on dd.date=date(spo.do_modified)
    LEFT JOIN KSFPA.OMS.Storeorder so 
    ON spo.Str_ID = so.Str_ID AND spo.OrderID = so.OrderID
    LEFT JOIN KSFPA.OMS.CUSTOMERORDER CUST 
    ON SO.ORDERID = CUST.ORDERID
    left join KSF_SOPHIA_DATA_INTELLIGENCE_HUB_PROD.COMMON_DIMENSIONS.DIM_LOCATION DL
    on spo.str_id::varchar=dl.location_code::varchar
  
WHERE 
    date(spo.do_modified)>='2023-01-01'
    -- and date(so.do_packing)<='2024-04-30'
    AND spo.str_id not in ('9995','9996','9997','9998','9999')
    AND sp.StorePickStatus IN ('PickingComplete')
    AND spo.QtyRequired IS NOT NULL
  
GROUP BY
    1,3,4,5,6
ORDER BY 
    1,2,3,4 asc;
