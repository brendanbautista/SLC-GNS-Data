WITH MAIN AS (
SELECT
svc.invoice_ref
,s.shpmnt_ref
,o.onhand_ref
,s.consol_ref
 
FROM export.SVC_PROVIDER_ITM SVC
Left Outer Join export.shpmnt_hdr s
        On svc.invoice_ref = s.consol_ref
LEFT OUTER JOIN EXPORT.ONHAND_HDR O
        ON O.SHPMNT_REF = S.SHPMNT_REF        
WHERE SVC.SVC_PROVIDER_ID = 'G0431613'
AND SVC.Date_Create > 123120100000000000
AND SVC.TRAN_UPDATE not in ('130')
AND S.PORT_ORIGIN not in ('LAS')
AND left(s.shpmnt_ref, 1) in ('H','4')

)
,
HOUSE_EVENTS AS(
        SELECT
        M.SHPMNT_REF
        ,E.SMP
        ,E.DSN
        ,E.LKI
        ,E.FRD
        ,E.BLP
        FROM
                MAIN M
                INNER JOIN LATERAL(
                        SELECT
                                M.SHPMNT_REF
                                ,LAST_VALUE(CASE WHEN E.STAT_CODE IN ('SMP') THEN E.DATE_STAT END , 'IGNORE NULLS')
                                        OVER (PARTITION BY E.INVOICE_REF ORDER BY E.UPDATE_DATE, E.DATE_CREATE, E.ORDAT_SEQUENCE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                                        AS SMP                        
                                ,LAST_VALUE(CASE WHEN E.STAT_CODE IN ('DSN') THEN E.DATE_STAT END , 'IGNORE NULLS')
                                        OVER (PARTITION BY E.INVOICE_REF ORDER BY E.UPDATE_DATE, E.DATE_CREATE, E.ORDAT_SEQUENCE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                                        AS DSN                                
                                ,LAST_VALUE(CASE WHEN E.STAT_CODE IN ('LKI') THEN E.DATE_STAT END , 'IGNORE NULLS')
                                        OVER (PARTITION BY E.INVOICE_REF ORDER BY E.UPDATE_DATE, E.DATE_CREATE, E.ORDAT_SEQUENCE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                                        AS LKI 
                                ,LAST_VALUE(CASE WHEN E.STAT_CODE IN ('FRD','FND') THEN E.DATE_STAT END , 'IGNORE NULLS')
                                        OVER (PARTITION BY E.INVOICE_REF ORDER BY E.UPDATE_DATE, E.DATE_CREATE, E.ORDAT_SEQUENCE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                                        AS FRD   
                                ,LAST_VALUE(CASE WHEN E.STAT_CODE IN ('BLP') THEN E.DATE_STAT END , 'IGNORE NULLS')
                                        OVER (PARTITION BY E.INVOICE_REF ORDER BY E.UPDATE_DATE, E.DATE_CREATE, E.ORDAT_SEQUENCE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                                        AS BLP                                                                                                                
                               ,ROW_NUMBER() OVER(PARTITION BY E.INVOICE_REF) AS RW
                        FROM
                                EXPORT.STAT_ITEM E
                        WHERE
                                E.INVOICE_REF IN (M.SHPMNT_REF, M.CONSOL_REF,M.ONHAND_REF)
                                AND E.STAT_CODE IN ('SMP','DSN','LKI','FRD','FND','BLP')
                )E ON E.RW = 1
)
 
 
SELECT
 
DISTINCT
 
M.SHPMNT_REF
,M.CONSOL_REF
,MAX(CAST(19+INT((HE.SMP) / 
                100000000000000000) AS CHAR(2)) || 
                TRANSLATE('YE-MN-DA', 
                DIGITS(HE.SMP),
                'xxYEMNDAxHRUTSC')) AS SMP_DATE
,MAX(CAST(19+INT((HE.DSN) / 
                100000000000000000) AS CHAR(2)) || 
                TRANSLATE('YE-MN-DA', 
                DIGITS(HE.DSN),
                'xxYEMNDAxHRUTSC')) AS DSN_DATE
,MAX(CAST(19+INT((HE.LKI) / 
                100000000000000000) AS CHAR(2)) || 
                TRANSLATE('YE-MN-DA', 
                DIGITS(HE.LKI),
                'xxYEMNDAxHRUTSC')) AS LKI_DATE
,MAX(CAST(19+INT((HE.FRD) / 
                100000000000000000) AS CHAR(2)) || 
                TRANSLATE('YE-MN-DA', 
                DIGITS(HE.FRD),
                'xxYEMNDAxHRUTSC')) AS FRD_DATE
,MAX(CAST(19+INT((HE.BLP) / 
                100000000000000000) AS CHAR(2)) || 
                TRANSLATE('YE-MN-DA', 
                DIGITS(HE.BLP),
                'xxYEMNDAxHRUTSC')) AS BLP_DATE
 
FROM MAIN M
 
LEFT OUTER JOIN HOUSE_EVENTS HE
        ON HE.SHPMNT_REF = M.SHPMNT_REF
GROUP BY
M.SHPMNT_REF
,M.CONSOL_REF        
