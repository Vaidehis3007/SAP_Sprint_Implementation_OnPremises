@AbapCatalog.sqlViewName: 'ZICDS6829892'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS VIEW VAIDEHI'
@Metadata.ignorePropagatedAnnotations: true
define view ZI_CDS_6829892 as select from z6829892_eina as eina

  inner join z6829892_lfa1 as lfa1
    on eina.lifnr = lfa1.lifnr
  inner join z6829892_makt as makt
    on eina.matnr = makt.matnr
{
   
    key lfa1.lifnr,
    key eina.infnr,
 
        lfa1.land1,
        lfa1.name1,
        lfa1.ort01,
        
        eina.matnr,
        eina.matkl,
        eina.anzpu,

        upper( makt.maktx ) as maktx,   

        case 
            when eina.anzpu between 1 and 100 then 'LOW'
            when eina.anzpu between 101 and 200 then 'MEDIUM'
            when eina.anzpu > 200 then 'HIGH'
            else 'UNKNOWN'
        end as priority,
        ' 'as rifnr_new, 
        ' ' as mfrnr_new
}
where makt.spras = $session.system_language
