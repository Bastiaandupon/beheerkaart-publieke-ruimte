/*
 * publieke ruimte zonder water grid
 * 
 * inclusief:
 * 		vervlijfindex_oud 
 * 		verblijversindex
 * 		alle gebiednamen
 * 		fractie publieke ruimte 
 * exlusief:
 * 		water
 */
drop table if exists "openbare_ruimte_CROW".publieke_ruimte_zonder_water_grid;
CREATE TABLE "openbare_ruimte_CROW".publieke_ruimte_zonder_water_grid as
(
select
	opr.id,
	opr.col,
	opr."row",
	brt.buurt_id,
	brt.buurt_naam,
	brt.buurt_code,
	brt.buurt_vollcode,
	brt.buurtcombinatie_id,
	brt.buurtcombinatie_naam,
	brt.buurtcombinatie_code,
	brt.buurtcombinatie_vollcode,
	brt.gebiedsgerichtwerken_id,
	brt.gebiedsgerichtwerken_naam,
	brt.gebiedsgerichtwerken_code,
	brt.stadsdeel_id,
	brt.stadsdeel_naam,
	brt.stadsdeel_code,
	brt.gemeente_id,
	brt.gemeente_naam,
	brt.gemeente_code,
	opr.in_oude_or_raster as verblijfindex_oud,
	vbi."verblijvers per ha  openbare ruimte 2014" as verblijvers_per_ha_openbare_ruimte_2014,	
	vbi."verblijvers per ha openbare ruimte 2016" as verblijvers_per_ha_openbare_ruimte_2016,
	vbi."index verblijvers  2014" as index_verblijvers_2014,
	vbi."index verblijvers 2016" as index_verblijvers_2016,
	opr.fractie,	 
	opr.geometrie
from
	"openbare_ruimte_CROW".opr_zonder_water_grid as opr	
left join
	"openbare_ruimte_CROW".buurt_all as brt
on 
	opr.brtk2015 = brt.buurt_vollcode
left join
	"openbare_ruimte_CROW".verblijversindex_2016 as vbi
on 
	brt.buurtcombinatie_vollcode = vbi.wijk_code
)
order by opr.id asc
;
drop index if exists "openbare_ruimte_CROW".publieke_ruimte_zonder_water_grid_gindx;
CREATE INDEX publieke_ruimte_zonder_water_grid_gindx ON "openbare_ruimte_CROW".publieke_ruimte_zonder_water_grid USING GIST (geometrie);
vacuum analyze "openbare_ruimte_CROW".publieke_ruimte_zonder_water_grid;


