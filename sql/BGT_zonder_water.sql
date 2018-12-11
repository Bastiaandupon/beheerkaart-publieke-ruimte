/*
 * 
 * Query time: 1.30 sec
 * 
 * Hierbij worden vanuit het BGT schema de materialized views samengevoegd van:
 * - wegdelen (nivo 0,1,2)
 * - terreindelen (nivo 0,1,2)
 * - inrichtingselement (nivo 0) (kademuren)
 * 
 * Vanuit het schema "openbare_ruimte_CROW".opr_water wordt het waterdeel toegevoegd.
 * het waterdeel kent al een voorselectie met eigendom_amsterdam_onbelast.
 * 
 * deze union heeft een filter op:
 * "bgt_fysiekvoorkomen" NOT IN ('erf') -- erven niet meenemen
 * 
 * geometrie: multipoly
 * 
 * update 1: waterdeel heeft veel kleine intersecties: 
 * 
 * filter op oppervlakte > 0.5
 * 
 * update 2:
 * In de bgt die dynamisch wordt ingelezen, zijn een 6 tal objecten invalide
 * 
 * update 3:
 * via ST_MakeValid(groep.geometrie) kan dit alsnog gefixed worden
 * 
 * update 4:
 * Naar team basisinformatie de (Arjen Witte) de invalide bgt-objecten gestuurd. Update bgt gebeurd maandelijks (N.B.landelijke Voorziening/pdok is dagelijks)
 * 
 */
drop table if exists "openbare_ruimte_CROW".bgt_zonder_water;
create table "openbare_ruimte_CROW".bgt_zonder_water as
(select
	agg.bgt_id,
	agg."type",
	agg.nivo,
	agg.bgt_functie,
	agg.bgt_fysiekvoorkomen,
	agg.plus_fysiekvoorkomen,
	agg.bgt_type,
	agg.plus_type,
	st_MakeValid(st_setsrid(st_multi(agg.geometrie), 28992)) as geometrie,
	st_area(geometrie) as opp
from (select * 
			from (
			  select identificatie_lokaalid as bgt_id, 'wegdeel' "type", '0' "nivo" , bgt_functie, bgt_fysiekvoorkomen, plus_fysiekvoorkomen, 'geen waarde' "bgt_type", 'geen waarde' "plus_type",geometrie from bgt.wegdeel_vlak0
			union
			  select identificatie_lokaalid as bgt_id, 'wegdeel' "type", '1' "nivo" , bgt_functie, bgt_fysiekvoorkomen, plus_fysiekvoorkomen,'geen waarde' "bgt_type", 'geen waarde' "plus_type", geometrie from bgt.wegdeel_vlak1
			union
			  select identificatie_lokaalid as bgt_id, 'wegdeel' "type", '2' "nivo" , bgt_functie, bgt_fysiekvoorkomen, plus_fysiekvoorkomen,'geen waarde' "bgt_type", 'geen waarde' "plus_type", geometrie from bgt.wegdeel_vlak2 
			union
			  select identificatie_lokaalid as bgt_id, 'terreindeel' "type", '0' "nivo" , 'geen waarde' "bgt_functie", bgt_fysiekvoorkomen, plus_fysiekvoorkomen, 'geen waarde' "bgt_type", 'geen waarde' "plus_type", geometrie from bgt.terreindeel_vlak0
			union
			  select identificatie_lokaalid as bgt_id, 'terreindeel' "type", '1' "nivo" , 'geen waarde' "bgt_functie", bgt_fysiekvoorkomen, plus_fysiekvoorkomen, 'geen waarde' "bgt_type", 'geen waarde' "plus_type", geometrie from bgt.terreindeel_vlak1
			union
			  select identificatie_lokaalid as bgt_id, 'terreindeel' "type", '2' "nivo" , 'geen waarde' "bgt_functie", bgt_fysiekvoorkomen, plus_fysiekvoorkomen, 'geen waarde' "bgt_type", 'geen waarde' "plus_type", geometrie from bgt.terreindeel_vlak2
			union
			  select identificatie_lokaalid as bgt_id, 'inrichtingselement' "type", '0' "nivo", 'geen waarde' "bgt_functie", 'geen waarde' "bgt_fysiekvoorkomen", 'geen waarde' "plus_fysiekvoorkomen", bgt_type, plus_type, geometrie from bgt.inrichtingselement_vlak0 --kademuren voor CROW
			/*union
			  select bgt_id, 'waterdeel' "type", '0' "nivo", 'geen waarde' "bgt_functie", 'geen waarde' "bgt_fysiekvoorkomen", 'geen waarde' "plus_fysiekvoorkomen", bgt_type, plus_type, geometrie from "openbare_ruimte_CROW".opr_water*/
				  ) sub
			where
				"bgt_fysiekvoorkomen" NOT IN ('erf') -- erven niet meenemen
		)agg
where 
	st_area(geometrie) > 0.5 -- filter kleine intersecties
--and 
--	st_isvalid(agg.geometrie) = true --invalide geometrieen error
);
--
drop index if exists "openbare_ruimte_CROW".bgt_zonder_water_gindx;
CREATE index bgt_zonder_water_gindx on "openbare_ruimte_CROW".bgt_zonder_water USING GIST (geometrie);
--
vacuum analyze "openbare_ruimte_CROW".bgt_zonder_water;
--
-- Aanmaken metadata voor zichtbaarheid in QGIS
select Populate_Geometry_Columns('"openbare_ruimte_CROW".bgt_zonder_water'::regclass, true);
