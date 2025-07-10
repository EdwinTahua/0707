@EndUserText.label: 'Custom entity'
@ObjectModel.query.implementedBy: 'ABAP:YCL_SCM_188'
define custom entity yce_grp_188
  // with parameters parameter_name : parameter_type
{

  key bank_internal_id : abap.char(15);
      BANK_COUNTRY     : abap.char(4);
      bank_name        : abap.char(15);
      swiftcode        : abap.char(15);
      bank_group       : abap.char(15);
      bank_number      : abap.char(15);
      region           : abap.char(15);
      street_name      : abap.char(15);
      city_name        : abap.char(15);
      branch           : abap.char(15);


}
