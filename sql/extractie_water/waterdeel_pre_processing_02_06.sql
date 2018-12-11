/*
 * Waterdeel met fractie tussen 0.2 en 0.6
 *  
 * st_valid: voor errors invalid polys
 */
drop table if exists "openbare_ruimte_CROW".waterdeel_02_06;
create table "openbare_ruimte_CROW".waterdeel_02_06 as
(
select 
	agg.bgt_id,
	agg.bgt_type,
	agg.plus_type,
	agg.geometrie,
    agg.opp_bgt,
	agg.sum_opp_intersectie,
	agg.count_opp_intersectie,
	agg.sum_opp_intersectie/agg.opp_bgt as fractie
from (
		select 
		    distinct on (bgt_id)
			sub.bgt_id,
			sub.bgt_type,
			sub.plus_type,
			sub.geometrie,
		    st_area(sub.geometrie) opp_bgt,
			sum (sub.opp_intersectie) over (partition by bgt_id) as sum_opp_intersectie,
			count (sub.opp_intersectie) over (partition by bgt_id) as count_opp_intersectie
		from (
				select
					layer1.identificatie_lokaalid bgt_id,
					layer2.id bkr_id,
					identificatie_lokaalid,
					bgt_type,
					plus_type,
					geometrie,
					st_area(st_intersection(layer1.geometrie, layer2.poly_geom)) opp_intersectie
				from
					bgt.waterdeel_vlak0 layer1
				join
					"openbare_ruimte_CROW".eigendom_amsterdam_onbelast layer2
				on
					ST_INTERSECTS(layer1.geometrie,layer2.poly_geom)
				where
					st_IsValid(layer1.geometrie) = true 
				and 
					st_IsValid(layer2.poly_geom) = true
				) sub
	  ) agg
where
    agg.sum_opp_intersectie/agg.opp_bgt < 0.6     
and
    agg.sum_opp_intersectie/agg.opp_bgt > 0     -- moet dit 0 zijn??
)
;
drop index if exists "openbare_ruimte_CROW".waterdeel_02_06_gindx;
CREATE INDEX waterdeel_02_06_gindx ON "openbare_ruimte_CROW".waterdeel_02_06 USING GIST (geometrie);
--
vacuum analyze "openbare_ruimte_CROW".waterdeel_02_06;
--