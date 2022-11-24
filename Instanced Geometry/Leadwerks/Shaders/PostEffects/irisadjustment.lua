--------------------------------------------------------
--Iris adjustment effect by Josh
--------------------------------------------------------

--Called once at start
function Script:Start()
	
	--Load this script's shader
	self.shader = Shader:Load("Shaders/PostEffects/Utility/irisadjustment.shader")
	
end

--Called each time the camera is rendered
function Script:Render(camera,context,buffer,depth,diffuse,normals,emission)
	local index,o,image,w,h
	
	--Check if downsample buffers match current resolution
	if self.buffer~=nil then
			if buffer:GetWidth()~=self.width or buffer:GetHeight()~=self.height then
				for index,o in pairs(self.buffer) do
					o:Release()
				end
				self.buffer=nil
			end
	end
	
	--Create downsample buffers if they don't exist
	if self.buffer==nil then
		self.buffer={}
		w = buffer:GetWidth()
		h = buffer:GetHeight()
		self.width = w
		self.height = h
		while (w>2 or h>2) do
			w=math.max(Math:Round(w/2),2)
			h=math.max(Math:Round(h/2),2)
			o=Buffer:Create(w,h,1,0)
			o:GetColorTexture():SetFilter(Texture.Smooth)
			table.insert(self.buffer,o)
		end
	end
	
	--Downsample image
	image = diffuse
	context:SetBlendMode(Blend.Alpha)
	context:SetColor(1,1,1,0.1 / Time:GetSpeed())
	if self.buffer~=nil then
		for index,o in ipairs(self.buffer) do
			o:Enable()
			context:DrawImage(image,0,0,o:GetWidth(),o:GetHeight())
			image = o:GetColorTexture()
			context:SetBlendMode(Blend.Solid)
			context:SetColor(1,1,1,1)
		end
	end
	
	--Enable the shader and draw the diffuse image onscreen
	buffer:Enable()
	diffuse:Bind(0)
	image:Bind(1)
	if self.shader then self.shader:Enable() end
	context:DrawRect(0,0,buffer:GetWidth(),buffer:GetHeight())
end

--Called when the effect is detached or the camera is deleted
function Script:Detach()
	local index,o
	
	--Release shaders
	if self.shader~=nil then
		self.shader:Release()
		self.shader = nil
	end
	
	--Release buffers
	if self.buffer~=nil then
		for index,o in pairs(self.buffer) do
			o:Release()
		end
		self.buffer = nil
	end
end