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
world:SetAmbientLight(1,1,1)

--Create camera
local camera = Camera:Create()
camera:Turn(45,0,0)
camera:SetPosition(0,10,-20)
camera:SetClearColor(0.25,0.25,0.25,1)

--Load model
local model = Model:Load("Models/merc.mdl")
model:SetPosition(-33,0,-33)

local models = {}
table.insert(models,model)

--Create instances
local x,z
for x=1,32 do
	for z=1,32 do
		inst = model:Instance()
		inst:SetPosition((x-17),0,(z-17))
		table.insert(models,inst)
	end
end

--Animate
for k,v in ipairs(models) do
	v:PlayAnimation(0,0.1)
end

while window:Closed()==false do	
	Time:Update()
	world:Update()
	world:Render()
	context:SetBlendMode(1)
	context:DrawText(Math:Round(Time:UPS()),2,2)
	context:Sync(false)	
end