-- Exact ray distance to a rounded OBB; used for rewound sphere shots, not expanded-box corners.
return function(origin,direction,range,cf,size,radius)
 local o=cf:PointToObjectSpace(origin) local d=cf:VectorToObjectSpace(direction.Unit)
 local half=size*.5 local axes={Vector3.xAxis,Vector3.yAxis,Vector3.zAxis}
 local breaks={0,range}
 for _,axis in axes do local v=d:Dot(axis)
  if math.abs(v)>1e-9 then for _,sign in {-1,1}do local t=(sign*half:Dot(axis)-o:Dot(axis))/v if t>0 and t<range then table.insert(breaks,t)end end end
 end
 table.sort(breaks)
 for i=1,#breaks-1 do
  local lo,hi=breaks[i],breaks[i+1] local mid=(lo+hi)*.5 local a,b,c=0,0,-radius*radius
  for _,axis in axes do
   local p,v,h=o:Dot(axis),d:Dot(axis),half:Dot(axis)
   local at=p+v*mid local q
   if at < -h then q=p+h elseif at>h then q=p-h end
   if q then a+=v*v b+=2*q*v c+=q*q end
  end
  local t
  if a*lo*lo+b*lo+c<=1e-8 then t=lo
  elseif a>1e-12 then local disc=b*b-4*a*c if disc>=0 then local root=(-b-math.sqrt(disc))/(2*a) if root>=lo-1e-7 and root<=hi+1e-7 then t=math.max(lo,root)end end end
  if t then
   local point=o+d*t local nearest=Vector3.new(math.clamp(point.X,-half.X,half.X),math.clamp(point.Y,-half.Y,half.Y),math.clamp(point.Z,-half.Z,half.Z))
   local normal=point-nearest
   return t,cf:VectorToWorldSpace(normal.Magnitude>1e-7 and normal.Unit or -d)
  end
 end
end
