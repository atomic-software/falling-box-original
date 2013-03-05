-- Averages an arbitrary number of angles (in radians).
function math.averageAngles(...)
    local x,y = 0,0
    for i=1,select('#',...) do local a= select(i,...) x, y = x+math.cos(a), y+math.sin(a) end
    return math.atan2(y, x)
end


-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end


-- Returns the angle between two points.
function math.angle(x1,y1, x2,y2) return math.atan2(x2-x1, y2-y1) end


-- Returns the closest multiple of 'size' (defaulting to 10).
function math.multiple(n, size) size = size or 10 return math.round(n/size)*size end


-- Clamps a number to within a certain range.
function math.clamp(low, n, high) return math.min(math.max(low, n), high) end


-- Linear interpolation between two numbers.
function lerp(a,b,t) return a+(b-a)*t end

-- Cosine interpolation between two numbers.
function cerp(a,b,t) local f=(1-math.cos(t*math.pi))*.5 return a*(1-f)+b*f end


-- Normalize two numbers.
function math.normalize(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end


-- Returns 'n' rounded to the nearest 'deci'th (defaulting whole numbers).
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end


-- Randomly returns either -1 or 1.
function math.rsign() return math.random(2) == 2 and 1 or -1 end


-- Returns 1 if number is positive, -1 if it's negative, or 0 if it's 0.
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end


-- Checks if two lines intersect (or line segments if seg is true)
-- Lines are given as four numbers (two coordinates)
function findIntersect(l1p1x,l1p1y, l1p2x,l1p2y, l2p1x,l2p1y, l2p2x,l2p2y, seg1, seg2)
    local a1,b1,a2,b2 = l1p2y-l1p1y, l1p1x-l1p2x, l2p2y-l2p1y, l2p1x-l2p2x
    local c1,c2 = a1*l1p1x+b1*l1p1y, a2*l2p1x+b2*l2p1y
    local det,x,y = a1*b2 - a2*b1
    if det==0 then return false, "The lines are parallel." end
    x,y = (b2*c1-b1*c2)/det, (a1*c2-a2*c1)/det
    if seg1 or seg2 then
        local min,max = math.min, math.max
        if seg1 and not (min(l1p1x,l1p2x) <= x and x <= max(l1p1x,l1p2x) and min(l1p1y,l1p2y) <= y and y <= max(l1p1y,l1p2y)) or
           seg2 and not (min(l2p1x,l2p2x) <= x and x <= max(l2p1x,l2p2x) and min(l2p1y,l2p2y) <= y and y <= max(l2p1y,l2p2y)) then
            return false, "The lines don't intersect."
        end
    end
    return x,y
end

-- Converts HSL to RGB. (input and output range: 0 - 255)
function HSL(h, s, l, a)
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

-- Collision detection function.
-- Checks if a and b overlap.
-- w and h mean width and height.
function CheckCollision(ax1,ay1,aw,ah, bx1,by1,bw,bh)

  local ax2,ay2,bx2,by2 = ax1 + aw, ay1 + ah, bx1 + bw, by1 + bh
  return ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1
end

function table.find(t,value)
    assert(t,'Table expected.')
    assert(value,'Value expected.')
    for i,v in pairs(t) do
        if v == value then return i end
    end
end

function shadowText(text,x,y,limit,align,color)
    align = align==nil and 'left' or align
    color = color==nil and {255,255,255} or color

    love.graphics.setColor(0,0,0,100)
    love.graphics.printf(text,x+2,y+2,limit,align,color)
    love.graphics.setColor(color)
    love.graphics.printf(text,x,y,limit,align,color)
end

function borderRect(x,y,width,height)
    color = {255,255,255}
    color[4] = 50 + (math.sin(gFX*3) + 1)*50
    love.graphics.setColor(color)
    love.graphics.rectangle('fill',x,y,width,height)
    color[4] = 255
    love.graphics.setColor(color)
    love.graphics.rectangle('line',x,y,width,height)
end