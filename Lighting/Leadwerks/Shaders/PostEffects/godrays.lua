--Called once at start
function Script:Start()
	
	--Load this script's shaders
	self.shader = Shader:Load("Shaders/PostEffects/Utility/godrays.shader")
	
end

--Called each time the camera is rendered
function Script:Render(camera,context,buffer,depth,diffuse,normals,emission)

	local anylightsfound = false
	
	--Bind the scene image
	buffer:Enable()
	diffuse:Bind(0)
	
	--Send light info to shader
	if self.shader~=nil then		
		local world=camera.world
		
		--Directional lights
		for i=0,world:CountEntities(Object.DirectionalLightClass)-1 do
			local entity = world:GetEntity(i,Object.DirectionalLightClass)
			if entity:Hidden()==false then
				self.shader:Enable()
				self.shader:SetVec4("scenecolor",Vec4(1))			
				if anylightsfound==true then
					context:SetBlendMode(Blend.Light)
					self.shader:SetVec4("scenecolor",Vec4(0))
				end
				anylightsfound=true
				self.shader:SetVec4("lightcolor",entity:GetColor() * entity:GetIntensity())
				local lightdir = Transform:Vector(0,0,1,entity,camera)
				self.shader:SetVec3("lightvector",lightdir)
				local lightpos = camera:GetPosition(true) - Transform:Vector(0,0,1,entity,nil) * 100;
				lightpos = camera:Project(lightpos)
				lightpos.x = lightpos.x / buffer:GetWidth()
				lightpos.y = lightpos.y / buffer:GetHeight()
				self.shader:SetVec3("lightposition",lightpos)
				self.shader:SetFloat("maxraylength",1.0)
				context:DrawRect(0,0,buffer:GetWidth(),buffer:GetHeight())
				break
			end
		end
		
		--[[
		--Point lights
		for i=0,world:CountEntities(Object.PointLightClass)-1 do
			local entity = world:GetEntity(i,Object.PointLightClass)
			if entity:Hidden()==false then
				self.shader:Enable()
				self.shader:SetVec4("scenecolor",Vec4(1))			
				if anylightsfound==true then
					context:SetBlendMode(Blend.Light)
					self.shader:SetVec4("scenecolor",Vec4(0))
				end
				anylightsfound=true
				self.shader:SetVec4("lightcolor",entity:GetColor() * entity:GetIntensity())
				local lightpos = entity:GetPosition(true)
				lightpos = camera:Project(lightpos)
				local lightdir = Transform:Point(entity:GetPosition(true),nil,camera):Normalize()*-1
				self.shader:SetVec3("lightvector",lightdir)
				lightpos.x = lightpos.x / buffer:GetWidth()
				lightpos.y = lightpos.y / buffer:GetHeight()
				self.shader:SetVec3("lightposition",lightpos)
				self.shader:SetFloat("maxraylength",0.5)					
				context:DrawRect(0,0,buffer:GetWidth(),buffer:GetHeight())
			end
		end
		
		--Spot lights
		for i=0,world:CountEntities(Object.SpotLightClass)-1 do
			local entity = world:GetEntity(i,Object.SpotLightClass)
			if entity:Hidden()==false then
				self.shader:Enable()
				self.shader:SetVec4("scenecolor",Vec4(1))	
				if anylightsfound==true then
					context:SetBlendMode(Blend.Light)
					self.shader:SetVec4("scenecolor",Vec4(0))
				end				
				anylightsfound=true
				self.shader:SetVec4("lightcolor",entity:GetColor() * entity:GetIntensity())
				local lightdir = Transform:Vector(0,0,1,entity,camera)
				self.shader:SetVec3("lightvector",lightdir)
				local lightpos = entity:GetPosition(true)
				lightpos = camera:Project(lightpos)
				lightpos.x = lightpos.x / buffer:GetWidth()
				lightpos.y = lightpos.y / buffer:GetHeight()
				self.shader:SetVec3("lightposition",lightpos)
				self.shader:SetFloat("maxraylength",0.5)
				context:DrawRect(0,0,buffer:GetWidth(),buffer:GetHeight())
			end
		end
		]]
		
	end
	
	if anylightsfound then
		context:SetBlendMode(Blend.Solid)
	else
		context:DrawImage(diffuse,0,0,buffer:GetWidth(),buffer:GetHeight())
	end
	
end

--Called when the effect is detached or the camera is deleted
function Script:Detach()
	
	--Release shaders
	if self.shader~=nil then
		self.shader:Release()
		self.shader = nil	
	end
	
end