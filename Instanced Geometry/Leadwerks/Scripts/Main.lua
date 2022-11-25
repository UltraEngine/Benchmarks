--Create a window
window = Window:Create("Leadwerks",0,0,1280,720,Window.Titlebar)
if window == nil then
	print("Failed to create window.")
	return
end

local count = 32

--Create the graphics context
local context = Context:Create(window,0)

--Create a world
local world = World:Create()
world:SetAmbientLight(1,1,1,1)

--Create camera
local camera = Camera:Create()
camera:SetPosition(0,0,-count*2)
camera:SetClearColor(0.25,0.25,0.25,1)

--Create box
local box = Model:Box()
box:SetColor(0.125,0.125,0.125,1)

--Boxes
local boxes = {}
local x,y,z
for x=1,count do
	for y=1,count do
		for z=1,count do
			inst = box:Instance()
			inst:SetPosition((x-1-math.floor(count/2))*2,(y-1-math.floor(count/2))*2,(z-1-math.floor(count/2))*2)
			table.insert(boxes,inst)
		end
	end
end

box:Hide()

while window:Closed()==false do	
	Time:Update()
	world:Update()
	world:Render()
	context:SetBlendMode(1)
	context:DrawText(Math:Round(Time:UPS()),2,2)
	context:Sync(false)	
end