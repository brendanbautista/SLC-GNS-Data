SELECT 

svc.invoice_ref
,s.shpmnt_ref
,(select CAST(19+INT((e.date_stat) / 100000000000000000) AS CHAR(2)) || TRANSLATE('YE-MN-DA', DIGITS(e.date_stat),'xxYEMNDAxHRUTSC') from export.stat_item e where e.invoice_ref = s.shpmnt_ref and e.stat_code = 'LKI' and e.remarks_stat like ('%' || svc.invoice_ref || '%') fetch first row only) as LKI


FROM export.SVC_PROVIDER_ITM SVC

Left Outer Join export.shpmnt_hdr s
        On svc.invoice_ref = s.consol_ref

WHERE SVC.SVC_PROVIDER_ID = 'G0431613'
AND SVC.Date_Create > 123120100000000000
AND SVC.TRAN_UPDATE not in ('130')