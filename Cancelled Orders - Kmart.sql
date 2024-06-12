create or replace view KSFPA.ONLINE_UGAM_PVT.SUPER_DASH_CANCELLED_ORDERS(
	ACCOUNTING_YEAR,
	ACCOUNTING_PERIOD_DESCRIPTION,
	ACCOUNTING_WEEK_NUMBER,
	"Distinct Count - Upfront Rejection (HD)",
	"Distinct Count - Ready to Collect Order Not Collected",
	"Distinct Count - HD Store Rejection (Exception)",
	"Distinct Count - C&C Store Rejection (Exception)",
	"Distinct Count - Upfront Rejection (CC)"
) as
SELECT ACCOUNTING_YEAR,
       ACCOUNTING_PERIOD_DESCRIPTION,
       ACCOUNTING_WEEK_NUMBER,
       SUM("Distinct Count - Upfront Rejection (HD)") AS "Distinct Count - Upfront Rejection (HD)",
       SUM("Distinct Count - Ready to Collect Order Not Collected") AS "Distinct Count - Ready to Collect Order Not Collected",
       SUM("Distinct Count - HD Store Rejection (Exception)") AS "Distinct Count - HD Store Rejection (Exception)",
       SUM("Distinct Count - C&C Store Rejection (Exception)") AS "Distinct Count - C&C Store Rejection (Exception)",
       SUM("Distinct Count - Upfront Rejection (CC)") AS "Distinct Count - Upfront Rejection (CC)"
FROM KSFPA.ONLINE_UGAM_PVT.CC_ABSOLUTE_NUMBERS
GROUP BY 1,2,3;