-- Curated rewards by weapon and accessory. Existing weapons outside the pilot
-- still use their established unlock rules in UnlockCatalog.
local levels = {}
local function track(weapon, reflex, suppressor, grip, laser, variants)
 local row = variants or {}
 row.optics_g_i_mini_reflex = reflex
 row.suppressors_monolithic_suppressor = suppressor
 row.foregrips_commando_foregrip = grip
 row.lasers_tac_laser = laser
 levels[weapon] = row
end

track("m4a1", 3, 7, 14, nil, {
 magazines_ar15_pmag_10=2, magazines_20rnd_5_56x45mm_normal_magazine=4,
 magazines_30rnd_5_56x45mm_nato_magazine_kilo=6, magazines_30rnd_5_56x45mm_holger_magazine=9,
 magazines_ar15_pmag_40=20, magazines_ar15_surefire_60=32,
 foregrips_merc_foregrip=17,
})
track("ak_47", 4, 7, 23, nil, {magazines_40rnd_7_62x39mm_magazine_ak_47=15})
track("an_94", 3, 9, 18)
track("as_val", 4, nil, 18)
track("cr_56_amax", 4, 9, 17, nil, {barrels_fss_11_8_squall_cr_56=25})
track("fal", 6, 4, 24)
track("fr_5_56", 4, 11)
track("grau_5_56", 3, 8, 13, nil, {barrels_fss_20_8_nexus=24})
track("kilo_141", 3, 8, 16)
track("m13", 3, 10, 15, nil, {foregrips_merc_foregrip=19})
track("oden", 5, 8, 24)
track("ram_7", 4, 7, 21)
track("scar_h", 4, 9, 23)
track("legacy_Rifle", 4, 8, 16)
track("legacy_SMG", 3, 6, 14)

track("mp5", 3, 7, 16, 9, {smg_mp5_30_klassik=2, smg_mp5_klassik_stock=21})
track("mp7", 4, 6, 16, 10, {smg_mp7_20=2, smg_mp7_xrk_stock=23})
track("uzi", 4, 8, 15, 7, {smg_uzi_32=12, smg_uzi_unfolded_stock=18, smg_uzi_pro_barrel=26})
track("p90", 5, 9, nil, 13)
track("aug", 4, 8, 15, 6, {aug_burst_conversion=17, smg_aug_30=20, smg_aug_a2_barrel=25})
track("pp_19_bizon", 4, 10, nil, 6)
track("striker_45", 4, 7, 15, 9, {smg_striker_ump_stock=20, smg_striker_ump_barrel=26})
track("fennec", 3, 6, 22, 10)
track("iso", 4, 8, 17, 6, {smg_iso_30=18, smg_iso_50=32})
levels.m1911 = {m1911_classic_mag_7=2, m1911_extended_mag_10=16}

for id, requirements in {m13={19,31},kilo_141={18,29},grau_5_56={20,33},ram_7={18,30}} do
 levels[id].magazines_ar15_pmag_40=requirements[1]
 levels[id].magazines_ar15_surefire_60=requirements[2]
end
levels.ak_47.rialag_magazines_ak_magazines_45rd_7_62x39_ak_magazine=28
levels.m4a1.rialag_buffer_tube_stocks_gl_core_stock=10
levels.m4a1.rialag_buffer_tube_stocks_b5_systems_sopmod_stock=26
levels.m13.rialag_buffer_tube_stocks_gl_core_stock=8
levels.m13.rialag_buffer_tube_stocks_b5_systems_sopmod_stock=24

for weapon, requirement in {
 m4a1={2,11}, grau_5_56={2,10}, kilo_141={2,12}, ram_7={2,16},
 mp5={3,13}, mp7={3,12}, iso={2,14},
} do
 levels[weapon].rialag_foregrips_magpul_afg2 = requirement[1]
 levels[weapon].rialag_foregrips_magpul_rvg = requirement[2]
end

return levels
