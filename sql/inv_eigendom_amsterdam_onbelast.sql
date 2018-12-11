/*
 * de inverse selectie van BRK (grond)percelen waarvan gemeente amsterdam de eigenaar is
 * 
 * m.u.v. opstal nuts en b.p. recht
 * 
 * 
 */
drop table if exists "openbare_ruimte_CROW".inv_eigendom_amsterdam_onbelast;
create table "openbare_ruimte_CROW".inv_eigendom_amsterdam_onbelast as
(
--inverse selectie
select 	sub.id,
		sub.poly_geom,
		sub.naam, 
		sub.aanschrijfbaar,
		sub.grondeigenaar,
		sub.appartementeigenaar,
		sub.kadastraal_object_id,
		sub.kadastraal_subject_id
from (select 
		distinct kot.id,
		kot.poly_geom,
		enr.naam,
		edm.aanschrijfbaar,
		edm.grondeigenaar,
		edm.appartementeigenaar,
		edm.kadastraal_object_id,
		edm.kadastraal_subject_id
		from
		bagdatapunt.brk_kadastraalobject as KOT
		join bagdatapunt.brk_eigendom as EDM on
		kot.id = edm.kadastraal_object_id
		join bagdatapunt.brk_eigenaar as ENR on
		edm.kadastraal_subject_id = enr.id
		where
		enr.cat_id = 1
		--1 = Gem. AMSTERDAM
		and kot.indexletter = 'G'
		--grondperceel, niet appartement
		-- voorwaarde: minus alle percelen met een andere rechthebbende, m.u.v. opstal nuts en b.p. recht
		and kot.id not in (
							---B
							-- selecteer alle percelen met een andere rechthebbende...
							 select
								distinct edm.kadastraal_object_id
								--kot.poly_geom,
								--enr.naam, 
								--edm.aanschrijfbaar,
								--edm.grondeigenaar,
								--edm.appartementeigenaar,
								--edm.kadastraal_object_id,
								--edm.kadastraal_subject_id
							from
								bagdatapunt.brk_eigendom edm
							join bagdatapunt.brk_eigenaar as enr on
								edm.kadastraal_subject_id = enr.id
							where
								enr.cat_id != 1
								--eigenaar ongelijk aan Gem. AMSTERDAM
								and edm.aard_zakelijk_recht_akr != 'OL'
								and edm.aard_zakelijk_recht_akr != '?'
								and
								-- voorwaarde: afbakening percelen waar amsterdam eigenaar is
							 kadastraal_object_id in (
														select
															distinct kot.id
														from
															bagdatapunt.brk_kadastraalobject as KOT
														join bagdatapunt.brk_eigendom as EDM on
															kot.id = edm.kadastraal_object_id
														join bagdatapunt.brk_eigenaar as ENR on
															edm.kadastraal_subject_id = enr.id
														where
															enr.cat_id = 1
															--1 = Gem. AMSTERDAM
														and kot.indexletter = 'G'
															--grondperceel, niet appartement
														)
					    )
	) sub
where sub.id not in (
					--A
					select 
					    distinct 
					    kot.id
					    /*kot.poly_geom,
					    enr.naam, 
					    edm.aanschrijfbaar,
					    edm.grondeigenaar,
					    edm.appartementeigenaar,
					    edm.kadastraal_object_id,
					    edm.kadastraal_subject_id*/
					from 
						bagdatapunt.brk_kadastraalobject as KOT
					join 
						bagdatapunt.brk_eigendom as EDM 
					on 
						kot.id = edm.kadastraal_object_id
					join 
						bagdatapunt.brk_eigenaar as ENR 
					on 
						edm.kadastraal_subject_id = enr.id
					where 
						enr.cat_id= 1 --1 = Gem. AMSTERDAM
					and 
						kot.indexletter = 'G' --grondperceel, niet appartement
					-- voorwaarde: minus alle percelen met een andere rechthebbende, m.u.v. opstal nuts en b.p. recht
					and 
						kot.id not in ( ---B
					                    -- selecteer alle percelen met een andere rechthebbende...
										select
										    distinct 
										    edm.kadastraal_object_id
										    --kot.poly_geom,
										    --enr.naam, 
										    --edm.aanschrijfbaar,
										    --edm.grondeigenaar,
										    --edm.appartementeigenaar,
										    --edm.kadastraal_object_id,
										    --edm.kadastraal_subject_id
										from 
										    bagdatapunt.brk_eigendom edm
										join 
										    bagdatapunt.brk_eigenaar as enr 
										on
											edm.kadastraal_subject_id = enr.id
										where 
										    enr.cat_id != 1 --eigenaar ongelijk aan Gem. AMSTERDAM
										and 
											edm.aard_zakelijk_recht_akr != 'OL' 
										and 
										    edm.aard_zakelijk_recht_akr !='?'
										and 
										    -- voorwaarde: afbakening percelen waar amsterdam eigenaar is
										    kadastraal_object_id in (  select
																		    distinct 
																		    kot.id
																		from 
																			bagdatapunt.brk_kadastraalobject as KOT
																		join 
																		    bagdatapunt.brk_eigendom as EDM 
																		on 
																			kot.id = edm.kadastraal_object_id
																		join 
																		    bagdatapunt.brk_eigenaar as ENR 
																		on 
																			edm.kadastraal_subject_id = enr.id
																		where 
																		    enr.cat_id= 1 --1 = Gem. AMSTERDAM
																		and 
																		    kot.indexletter = 'G' --grondperceel, niet appartement
																	 )
										)
						) --einde_inv
);

drop index if exists "openbare_ruimte_CROW".inv_eigendom_amsterdam_onbelast_gindx;
CREATE INDEX inv_eigendom_amsterdam_onbelast_gindx ON "openbare_ruimte_CROW".inv_eigendom_amsterdam_onbelast USING GIST (poly_geom);

vacuum analyze "openbare_ruimte_CROW".inv_eigendom_amsterdam_onbelast;