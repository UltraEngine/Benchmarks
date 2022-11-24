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
world:SetAmbientLight(Vec4(0.25,0.25,0.25,1))

--Create camera
local camera = Camera:Create()
camera:SetRotation(90,0,0)
camera:SetPosition(0,64,0)

--[[
camera:SetClearColor(0.25,0.25,0.25,1)

print(0)

--Create the ground
local ground = Model:Box(320,1,320)
ground:SetPosition(0,-0.5,0)

--Load model
local model = PointLight:Create()
model:SetShadowMode(0)
model:SetPosition(-63,-63,0)
model:SetRange(10)

local models = {}
table.insert(models,model)

print(1)

--Create instances
local x,z
for x=1,32 do
	for z=1,32 do
		if x ~= 1 or z ~= 1 then
			copy = model:Instantiate()
			copy:SetPosition((x-17+0.5)*10,1,(z-17+0.5)*10)
			copy:SetColor(Math:Random(0,1),Math:Random(0,1),Math:Random(0,1))
			table.insert(models,copy)
		end
	end
end

]]

while window:Closed()==false do	
	Time:Update()
	world:Update()
	world:Render()
	context:SetBlendMode(1)
	context:DrawText(Math:Round(Time:UPS()),2,2)
	context:Sync(false)	
end