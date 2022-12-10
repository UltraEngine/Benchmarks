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
world:SetAmbientLight(1,1,1,1)

--Create camera
local camera = Camera:Create()
camera:SetPosition(0,0,-64)
camera:SetClearColor(0.25,0.25,0.25,1)

--Load model
local model = Model:Box()
model:SetPosition(-63,-63,0)

local models = {}
table.insert(models,model)

--Create instances
local x,z
for x=1,64 do
	for z=1,64 do
		if x~=1 or z ~= 1 then
			copy = model:Copy()
			copy:SetPosition((x-33)*2+1,(z-33)*2+1,0)
			copy:SetColor(Math:Random(0,1),Math:Random(0,1),Math:Random(0,1))
			table.insert(models,copy)
		end
	end
end

while window:Closed()==false do	
	Time:Update()
	world:Update()
	world:Render()
	context:SetBlendMode(1)
	context:DrawText(Math:Round(Time:UPS()),2,2)
	context:Sync(false)	
end