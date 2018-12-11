/*
 * samenvoegen van delen water a en b
 * 
 * geometrie: cast to multipoly
 *  
 */
drop table if exists "openbare_ruimte_CROW".opr_water;
create table "openbare_ruimte_CROW".opr_water as
(select
	bgt_id,
	bgt_type,
	plus_type,
	ST_Multi(geometrie) as geometrie,
	sum_opp_intersectie,
	fractie,
	count_opp_intersectie
from
	"openbare_ruimte_CROW".waterdeel_gt06 as a_set
--
union
-- zachte set B, afknipen met eigendom amsterdam onbelast
select * from (
                select
                    bgt_id,
                    bgt_type,
                    plus_type,
                    st_multi(st_intersection(b_set.geometrie,eig.poly_geom)) geometrie,
                    sum_opp_intersectie,
                    fractie,
                    count_opp_intersectie
                from
                    "openbare_ruimte_CROW".waterdeel_02_06 b_set
                join
                    "openbare_ruimte_CROW".eigendom_amsterdam_onbelast eig
                on 
                	st_intersects(b_set.geometrie,eig.poly_geom)  
                where
                	st_IsValid(b_set.geometrie) = true 
                and 
			    	st_IsValid(eig.poly_geom) = true 
               ) b_set_intersect
where
    upper(st_geometrytype(geometrie)) like '%POLY%' -- filter alleen de intersectdelen die poly of multipoly zijn
);
--
drop index if exists "openbare_ruimte_CROW".opr_water_gindx;
CREATE INDEX opr_water_gindx ON "openbare_ruimte_CROW".opr_water USING GIST (geometrie);
--
vacuum analyze "openbare_ruimte_CROW".opr_water;            