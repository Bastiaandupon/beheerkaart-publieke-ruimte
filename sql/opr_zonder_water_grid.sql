/* query time: 1m 51s
 * 
 *  Intersectie met Bgt-BRK-zonder-water (Beheerkaart - Publieke Ruimte) met cbs-grid (100x100)
 * 
 *  waar publieke ruimte groter is dan 10 %
 * 
 *  output: opr_zonder_water_grid
 * 
 * aliasses:
 * 
 * join		 = INNER JOIN
 * left join = LEFT OUTER JOIN
 */
drop table if exists "openbare_ruimte_CROW".opr_zonder_water_grid;
CREATE TABLE "openbare_ruimte_CROW".opr_zonder_water_grid as 
(
select
	grid.id,
	grid.col,
	grid."row",
	grid.brtk2015,
	grid.in_oude_or_raster,
	grid.geometrie,
	case when join_agg.som_opp_intersectie is null 
	  then 0
	  else join_agg.som_opp_intersectie
	end opp_som_intersectie,
	case when join_agg.som_opp_intersectie is null
	  then 0
	  else join_agg.som_opp_intersectie / ST_Area(join_agg.grid_geom)
	end fractie
from 	
  "openbare_ruimte_CROW".cbs_grid_poly grid
left join
--
	(select
	    distinct on (grid_agg.id)
		grid_agg.id,
		grid_agg.col,
		grid_agg."row",
		grid_agg.brtk2015,
		grid_agg.in_oude_or_raster,
		grid_agg.grid_geom,
		sum(grid_agg.opp_intersectie) over (partition by grid_agg.id) as som_opp_intersectie
	from    (
            -- intersectie brk_bgt met grid: N gridcellen X M brk_bgt objecten
			select distinct
				layer1.id,
				layer1.col,
				layer1."row",
				layer1.brtk2015,
				layer1.in_oude_or_raster,
				layer1.geometrie as grid_geom,
				round(st_area(st_intersection(layer1.geometrie, layer2.geometrie))::numeric,2) opp_intersectie
			from
				"openbare_ruimte_CROW".cbs_grid_poly as layer1
			join 
				"openbare_ruimte_CROW".brk_bgt_zonder_water as layer2
			on 
				ST_INTERSECTS(layer1.geometrie,layer2.geometrie)
			) grid_agg
            --
    order by grid_agg.id,som_opp_intersectie desc
    --
    ) join_agg			
on  grid.id = join_agg.id 
);
--
drop index if exists "openbare_ruimte_CROW".opr_zonder_water_grid_gindx;
CREATE INDEX opr_zonder_water_grid_gindx ON "openbare_ruimte_CROW".opr_zonder_water_grid USING GIST (geometrie);
create index opr_zonder_water_grid_fractie_idx on "openbare_ruimte_CROW".opr_zonder_water_grid(fractie);
vacuum analyze "openbare_ruimte_CROW".opr_zonder_water_grid;
--
select Populate_Geometry_Columns('"openbare_ruimte_CROW".opr_zonder_water_grid'::regclass, true);

