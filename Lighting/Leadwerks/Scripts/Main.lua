--Create a window
window = Window:Create("Leadwerks",0,0,1280,720,Window.Titlebar)
if window == nil then
	print("Failed to create window.")
	return
end

--Create the graphics context
local context = Context:Create(window,0)

--Create a world
local world = World:Create()
world:SetAmbientLight(0,0,0,1)

--Create camera
local camera = Camera:Create()
camera:SetRotation(45,0,0)
camera:SetPosition(0,25,-25)
camera:SetClearColor(0.25,0.25,0.25,1)

--Create the ground
local ground = Model:Box(80,1,80)
ground:SetPosition(0,-0.5,0)

--Create lights
local lights = {}

local light = PointLight:Create()
light:SetColor(0.5,0.5,0.5,1)
light:SetRange(0.1,20)

local startpos = {}
local x, y, z
y=0
z=0
for x = 1, 5 do
	for z = 1, 5 do
		inst = light:Instance()
		inst:SetPosition((x - 3) * 5, 10, (z-3) * 5+10)
		inst.startpos = inst.position
		table.insert(lights,inst)
		startpos[inst] = inst.position
	end
end

light:Hide()

--Create models
local model = Model:Box()

local models = {}
local x, z
for x = 1, 11 do
	for y = 1, 8 do
		for z = 1, 11 do
			inst = model:Instance()
			inst:SetPosition((x - 6) * 2, y-1, (z - 6) * 2+10)
			table.insert(models,inst)
		end
	end
end

model:Hide()

while window:Closed()==false do	
	Time:Update()
	world:Update()
	world:Render()
	context:SetBlendMode(1)
	context:DrawText(Math:Round(Time:UPS()),2,2)
	context:Sync(false)	
end