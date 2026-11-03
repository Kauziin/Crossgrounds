return function(t)
 local R=game.ReplicatedStorage.Crossgrounds
 local T=require(R.ProgressionTracks) local P=require(R.CareerPolicy)
 t.test('account track uses existing career curve and preserves permanent unlocks',function()
  local p=P.New() p.cycleXP=P.Threshold(31)
  local track=T.Account(p,'ctf','all')
  t.expect.equal(track.current,31) t.expect.equal(track.lower,P.Threshold(31))
  t.expect.equal(track.rows[31][1].id,'oden') t.expect.truthy(track.rows[31][1].available)
  p.permanent.ctf.ax_50=true
  local rows=T.Account(p,'ctf','all').rows[55] local found
  for _,r in rows do if r.id=='ax_50' then found=r.available end end
  t.expect.truthy(found)
 end)
 t.test('filters reuse catalog and keep multiple rewards at a level',function()
  local p=P.New() local both=T.Account(p,'all','all')
  t.expect.truthy(#both.rows[1]>=3)
  local arena=T.Account(p,'arena','appearance')
  for _,rewards in arena.rows do for _,r in rewards do t.expect.equal(r.mode,'arena') t.expect.equal(r.kind,'appearance') end end
  t.expect.equal(next(T.Account(p,'ctf','appearance').rows),nil)
 end)
 t.test('ODEN uses actual weapon XP and existing cosmetic rewards',function()
  local p=P.New() p.weapons.oden=200*9^2
  local track=T.Weapon(p,'oden','all')
  t.expect.equal(track.current,10) t.expect.equal(track.lower,200*9^2) t.expect.equal(track.upper,200*10^2)
  t.expect.truthy(track.rows[10][1].available) t.expect.equal(track.rows[10][1].finish,'forest')
  t.expect.equal(track.rows[2],nil)
  for _,rewards in track.rows do for _,r in rewards do t.expect.equal(r.kind,'finish') end end
  t.expect.equal(p.weapons.oden,200*9^2)
 end)
 t.test('unavailable profiles do not manufacture saved progression',function()
  local track=T.Account(nil,'ctf','all') t.expect.falsy(track.ready)
  t.expect.equal(track.rows[31][1].available,nil)
  t.expect.falsy(T.Guild({invites={}},nil).ready)
 end)
 t.test('guild requires confirmed membership and uses collective XP',function()
  local c={name='Fixture',tag='TEST',role='member',epoch='epoch',xp=20000,capacity=30,members={{userId=1,name='Fixture',epoch='epoch',contributionXP=1000}}}
  local track=T.Guild({clan=c}) t.expect.truthy(track.ready) t.expect.equal(track.current,3)
  t.expect.truthy(track.rows[3][1].available)
  c.role=nil t.expect.falsy(T.Guild({clan=c}).ready)
  c.role='member' t.expect.falsy(T.Guild({clan=c,pending=true}).ready)
  c.archived=true t.expect.falsy(T.Guild({clan=c}).ready)
 end)
 t.test('earned guild cosmetics remain owned after moving to a new guild',function()
  local p=P.New() p.cosmetics.cards.clan=true p.cosmetics.frames.clan=true p.cosmetics.titles.clan=true
  local c={name='Fixture',tag='TEST',role='member',epoch='new-epoch',xp=0,capacity=30,members={{userId=1,name='Fixture',epoch='new-epoch',contributionXP=0}}}
  local track=T.Guild({clan=c},p)
  t.expect.truthy(track.rows[3][1].claimed) t.expect.truthy(track.rows[3][1].available)
 end)

end
