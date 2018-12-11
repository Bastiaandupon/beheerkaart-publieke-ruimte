/*
 * query time: 11m 21s 
 * 
 * intersectie met brk (eigendom_amsterdam_onbelast) en BGT_union objecten
 * 
 * waarbij de instersectie /fractie > 0.15
 * 
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
drop table if exists "openbare_ruimte_CROW".brk_bgt;
CREATE TABLE "openbare_ruimte_CROW".brk_bgt as
(select 
	sub.*
from(
		select
			layer1.bgt_id as bgt_id,
			layer2.id bkr_id,
			layer1."type",
			layer1.nivo,
			layer1.bgt_functie,
			layer1.bgt_fysiekvoorkomen,
			layer1.plus_fysiekvoorkomen,
			layer1.bgt_type,
			layer1.plus_type,
			layer1.geometrie,
			st_area(st_intersection(layer1.geometrie, layer2.poly_geom)) opp_intersectie,
			st_area(st_intersection(layer1.geometrie, layer2.poly_geom))/st_area(layer1.geometrie) as fractie
		from
			"openbare_ruimte_CROW".bgt_union_all layer1
		join 
			"openbare_ruimte_CROW".eigendom_amsterdam_onbelast layer2
		on 
			ST_INTERSECTS(layer1.geometrie,layer2.poly_geom)
		where
			st_IsValid(layer1.geometrie) = true 
		and 
			st_IsValid(layer2.poly_geom) = true

	)sub
where
	sub.fractie > 0.15
and
	st_isvalid(sub.geometrie) = true
);
									  				
drop index if exists "openbare_ruimte_CROW".brk_bgt_gindx;
CREATE INDEX brk_bgt_gindx ON "openbare_ruimte_CROW".brk_bgt USING GIST (geometrie);

vacuum analyze "openbare_ruimte_CROW".brk_bgt;
