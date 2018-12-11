/*
 * query time: 57s
 * 
 * intersectie met brk (eigendom_amsterdam_onbelast) en BGT_zonder_water objecten
 * 
 * waarbij de instersectie /fractie > 0.15
 * 
 * update 1:
 * 
 * Spatial filter op gem. Amsterdam
 * 
 * error:
 * Error occurred during SQL script execution
 * Reason:
 * SQL Error [XX000]: ERROR: Error performing intersection: TopologyException: Input geom 0 is invalid: Self-intersection at or near point 
 * 122453.20580039968 486724.91718955018 at 122453.20580039968 486724.91718955018
 * 
 * reden:
 * Aantal Bgt-objecten hadden invalide geometrien, dit is gemeld
 * 
 *  
 */
drop table if exists "openbare_ruimte_CROW".brk_bgt_zonder_water_amsterdam;
CREATE TABLE "openbare_ruimte_CROW".brk_bgt_zonder_water_amsterdam as
(select 
	bgt_id,
	bkr_id,
	"type",
	nivo,
	bgt_functie,
	bgt_fysiekvoorkomen,
	plus_fysiekvoorkomen,
	bgt_type,
	plus_type,
	layer1.geometrie,
	opp_intersectie,
	fractie
from 
	"openbare_ruimte_CROW".brk_bgt_zonder_water layer1
join 
	bagdatapunt.brk_gemeente layer2
on 
	ST_INTERSECTS(layer1.geometrie,layer2.geometrie)
where 
	layer2.gemeente = 'Amsterdam'
);
drop index if exists "openbare_ruimte_CROW".brk_bgt_zonder_water_amsterdam_gindx;
CREATE INDEX brk_bgt_zonder_water_amsterdam_gindx ON "openbare_ruimte_CROW".brk_bgt_zonder_water_amsterdam USING GIST (geometrie);

vacuum analyze "openbare_ruimte_CROW".brk_bgt_zonder_water_amsterdam;
