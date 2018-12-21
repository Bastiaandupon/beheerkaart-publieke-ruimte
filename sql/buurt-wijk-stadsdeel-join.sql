/*
 * 	Bag_buurt met alle gebiedsnamen:
 * 	wijken/buurtcombinaties
 * 	gebiedsgerichtwerken, alleen ruimtelijk bepaald
 * 	stadsdelen
 * 	gemeente
 * 
 */
drop table if exists "openbare_ruimte_CROW".buurt_all;
CREATE TABLE "openbare_ruimte_CROW".buurt_all as
(
select 
	brt.id as buurt_id,
	brt.naam as buurt_naam,
	brt.code as buurt_code,
	brt.vollcode as buurt_vollcode,	
	brt.buurtcombinatie_id,
	bce.naam as buurtcombinatie_naam,
	bce.code as buurtcombinatie_code,
	bce.vollcode as buurtcombinatie_vollcode,
	case when brt_ggw.ggw_id notnull then brt_ggw.ggw_id else 'geenwaarde' end as gebiedsgerichtwerken_code,
	case when brt_ggw.ggw_naam notnull then brt_ggw.ggw_naam else 'geenwaarde' end as gebiedsgerichtwerken_naam,
	brt.stadsdeel_id,
	sdl.naam as stadsdeel_naam,
	sdl.code as stadsdeel_code,
	sdl.gemeente_id,	
	gme.naam as gemeente_naam,
	gme.code as gemeente_code,
	brt.geometrie
from
	bagdatapunt.bag_buurt as brt
join
	bagdatapunt.bag_buurtcombinatie as bce
on
	brt.buurtcombinatie_id = bce.id
left join
		(select 
			brt.id as brt_id,
			ggw.id as ggw_id,
			ggw.naam as ggw_naam
		from 
			bagdatapunt.bag_buurt brt
		join 
			bagdatapunt.bag_gebiedsgerichtwerken ggw
		on
			ST_Intersects(brt.geometrie, ggw.geometrie)
		where 
			st_area(st_intersection(brt.geometrie, ggw.geometrie))/st_area(brt.geometrie) > 0.5
		)brt_ggw
on 
	brt.id = brt_ggw.brt_id
join
	bagdatapunt.bag_stadsdeel as sdl
on 
	brt.stadsdeel_id = sdl.id
join
	bagdatapunt.bag_gemeente as gme
on 
	sdl.gemeente_id  = gme.id
)
;
drop index if exists "openbare_ruimte_CROW".buurt_all_gindx;
CREATE INDEX buurt_all_gindx ON "openbare_ruimte_CROW".buurt_all USING GIST (geometrie);

vacuum analyze "openbare_ruimte_CROW".buurt_all;
