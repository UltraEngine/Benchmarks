--------------------------------------------------------
--Bloom effect
--------------------------------------------------------

Script.downsample=2
Script.bluriterations=2

--Called once at start
function Script:Start()
	
	--Load this script's shaders
	self.shader={}
	self.shader.bloom = Shader:Load("Shaders/PostEffects/Utility/bloom.shader")
	self.shader.blurx = Shader:Load("Shaders/PostEffects/Utility/hblur.shader")
	self.shader.blury = Shader:Load("Shaders/PostEffects/Utility/vblur.shader")
	
end

--Called each time the camera is rendered
function Script:Render(camera,context,buffer,depth,diffuse,normals,emission)
	
	--Check if downsample buffers match current resolution
	if self.buffer~=nil then
			if self.buffer[0]:GetWidth()~=Math:Round(self.w/self.downsample) or self.buffer[0]:GetHeight()~=Math:Round(self.h/self.downsample) then
				self.buffer[0]:Release()
				self.buffer[1]:Release()
				self.buffer=nil
			end
	end
	
	--Create downsample buffers if they don't exist
	if self.buffer==nil then
			self.buffer={}	
			self.w=buffer:GetWidth()
			self.h=buffer:GetHeight()
			self.buffer[0]=Buffer:Create(Math:Round(self.w/self.downsample),Math:Round(self.h/self.downsample),1,0)
			self.buffer[1]=Buffer:Create(Math:Round(self.w/self.downsample),Math:Round(self.h/self.downsample),1,0)
			self.buffer[0]:GetColorTexture():SetFilter(Texture.Smooth)
			self.buffer[1]:GetColorTexture():SetFilter(Texture.Smooth)
	end
	
	local image = diffuse
	local i
	
	for i=1,self.bluriterations do
		
		--Perform horizontal blur
		self.buffer[0]:Enable()
		if self.shader.blurx then self.shader.blurx:Enable() end
		context:DrawImage(image,0,0,self.buffer[0]:GetWidth(),self.buffer[0]:GetHeight())
		
		--Perform vertical blur
		self.buffer[1]:Enable()
		if self.shader.blury then self.shader.blury:Enable() end
		context:DrawImage(self.buffer[0]:GetColorTexture(),0,0,self.buffer[1]:GetWidth(),self.buffer[1]:GetHeight())
		image = self.buffer[1]:GetColorTexture()
		
	end
	
	--Bind the downsampled image
	buffer:Enable()
	diffuse:Bind(0)
	image:Bind(1)
	
	--Enable the shader and draw the diffuse image onscreen
	if self.shader.bloom then self.shader.bloom:Enable() end
	context:DrawRect(0,0,buffer:GetWidth(),buffer:GetHeight())
	
end

--Called when the effect is detached or the camera is deleted
function Script:Detach()
	
	local index,o
	
	--Release shaders
	for index,o in pairs(self.shader) do
		o:Release()
	end
	self.shader = nil	
	
	--Release buffers
	if self.buffer~=nil then
		for index,o in ipairs(self.buffer) do
			o:Release()
		end
		self.buffer = nil	      
	end
	
end