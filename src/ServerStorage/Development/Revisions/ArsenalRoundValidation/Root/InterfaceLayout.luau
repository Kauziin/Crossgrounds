local Layout={}
function Layout.Settings(width,height,binding)
 local compact=width<960 or height<500
 local top=height<360 and 28 or 38
 local paneHeight=math.max(48,height-top-18)
 local content=compact and 44 or 78
 local inputY=content
 if binding then content+=36 end
 content=math.min(content,paneHeight-12)
 return {Compact=compact,Top=top,Height=paneHeight,ContentY=content,ContentHeight=math.max(1,paneHeight-content-8),InputY=inputY,DescriptionVisible=not compact}
end
function Layout.MobileScale(isMobile,preference)
 if not isMobile then return 1 end
 if typeof(preference)~='number' or preference~=preference or math.abs(preference)==math.huge then preference=.6 end
 return math.clamp(preference,.35,1)
end
return Layout
