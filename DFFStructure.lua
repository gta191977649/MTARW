EnumBlendMode = {
    NOBLEND      = 0x00,
    ZERO         = 0x01,
    ONE          = 0x02,
    SRCCOLOR     = 0x03,
    INVSRCCOLOR  = 0x04,
    SRCALPHA     = 0x05,
    INVSRCALPHA  = 0x06,
    DESTALPHA    = 0x07,
    INVDESTALPHA = 0x08,
    DESTCOLOR    = 0x09,
    INVDESTCOLOR = 0x0A,
    SRCALPHASAT  = 0x0B,
}
EnumFilterMode = {
	None				= 0x00,	-- Filtering is disabled
	Nearest				= 0x01,	-- Point sampled
	Linear				= 0x02,	-- Bilinear
	MipNearest			= 0x03,	-- Point sampled per pixel mip map
	MipLinear			= 0x04,	-- Bilinear per pixel mipmap
	LinearMipNearest	= 0x05,	-- MipMap interp point sampled
	LinearMipLinear		= 0x06,	-- Trilinear
}

EnumMaterialEffect = {
	None				= 0x00,	-- No Effect
	BumpMap				= 0x01, -- Bump Map
	EnvMap				= 0x02, -- Environment Map (Reflections)
	BumpEnvMap			= 0x03, -- Bump Map/Environment Map
	Dual				= 0x04, -- Dual Textures
	UVTransform			= 0x05, -- UV-Tranformation
	DualUVTransform		= 0x06, -- Dual Textures/UV-Transformation
}

EnumLightType = {
	Directional = 0x01,		-- Directional light source
	Ambient = 0x02,			-- Ambient light source
	Point = 0x80,			-- Point light source
	Spot = 0x81,			-- Spotlight
	SpotSoft = 0x82,		-- Spotlight, soft edges
}

EnumLightFlag = {
	Scene = 0x01,	--Lights all the atomics of the object.
	World = 0x02,	--Lights the entire world.
}

Enum2DFX = {
	Light = 0x00,
	ParticleEffect = 0x01,
	PedAttractor = 0x03,
	SunGlare = 0x04,
	EnterExit = 0x06,
	StreetSign = 0x07,
	TriggerPoint = 0x08,
	CovePoint = 0x09,
	Escalator = 0x0A
}

class "UVAnimDict" {	typeID = 0x2B,
	extend = "Section",
	struct = false,
	methodContinue = {
		read = function(self,readStream)
			self.struct = UVAnimDictStruct()
			self.struct:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
		end,
		getSize = function(self)
			return self.struct:getSize()
		end,
	}
}

class "UVAnimDictStruct" {
	extend = "Struct",
	animationCount = false,
	animations = false,
	methodContinue = {
		read = function(self,readStream)
			self.animationCount = readStream:read(uint32)
			self.animations = {}
			for i=1,self.animationCount do
				self.animations[i] = UVAnim()
				self.animations[i]:read(readStream)
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.animationCount,uint32)
		end,
		getSize = function(self)
			return 4
		end,
	}
}

class "UVAnim" {	typeID = 0x1B,
	extend = "Section",
	header = false,
	animType = false,
	frameCount = false,
	flags = false,
	duration = false,
	unused = false,
	name = false,
	nodeToUVChannel = false,
	data = false,
	methodContinue = {
		read = function(self,readStream)
			self.header = readStream:read(uint32)	--0x0100
			self.animType = readStream:read(uint32)
			self.frameCount = readStream:read(uint32)
			self.flags = readStream:read(uint32)
			self.duration = readStream:read(float)
			self.unused = readStream:read(uint32)
			self.name = readStream:read(char,32)
			self.nodeToUVChannel = {}
			for i=1,8 do
				self.nodeToUVChannel[i] = readStream:read(float)
			end
			self.data = {}
			for i=1,self.frameCount do
				self.data[i] = {}
				self.data[i].time = readStream:read(float)
				self.data[i].scale = {readStream:read(float),readStream:read(float),readStream:read(float)}
				self.data[i].position = {readStream:read(float),readStream:read(float),readStream:read(float)}
				self.data[i].previousFrame = readStream:read(int32)
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.header,uint32)
			writeStream:write(self.animType,uint32)
			writeStream:write(self.frameCount,uint32)
			writeStream:write(self.flags,uint32)
			writeStream:write(self.duration,float)
			writeStream:write(self.unused,uint32)
			writeStream:write(self.name,char,32)
			for i=1,8 do
				writeStream:write(self.nodeToUVChannel[i],float)
			end
			for i=1,self.frameCount do
				writeStream:write(self.data[i].time,float)
				writeStream:write(self.data[i].scale[1],float)
				writeStream:write(self.data[i].scale[2],float)
				writeStream:write(self.data[i].scale[3],float)
				writeStream:write(self.data[i].position[1],float)
				writeStream:write(self.data[i].position[2],float)
				writeStream:write(self.data[i].position[3],float)
				writeStream:write(self.data[i].previousFrame,int32)
			end
		end,
		getSize = function(self)
			return 4*6+32+4*8+4*8*self.frameCount
		end,
	}
}

class "ClumpStruct" {
	extend = "Struct",
	atomicCount = false,
	lightCount = false,
	cameraCount = false,
	init = function(self,version)
		self.atomicCount = 0
		self.lightCount = 0
		self.cameraCount = 0
		self.size = self:getSize(true)
		self.version = version
		self.type = ClumpStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.atomicCount = readStream:read(int32)
			self.lightCount = readStream:read(int32)
			self.cameraCount = readStream:read(int32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.atomicCount,int32)
			writeStream:write(self.lightCount,int32)
			writeStream:write(self.cameraCount,int32)
		end,
		getSize = function(self)
			return 12
		end,
	}
}

class "Clump" {	typeID = 0x10,
	extend = "Section",
	struct = false,
	frameList = false,
	geometryList = false,
	atomics = false,
	indexStructs = false,
	lights = false,
	extension = false,
	init = function(self,version)
		self.struct = ClumpStruct():init(version)
		self.frameList = FrameList():init(version)
		self.geometryList = GeometryList():init(version)
		self.extension = Extension():init(version)
		self.atomics = {}
		self.indexStructs = {}
		self.lights = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = Clump.typeID
		return self
	end,
	createAtomic = function(self)
		local atomic = Atomic():init(self.version)
		self.struct.atomicCount = self.struct.atomicCount+1
		self.atomics[self.struct.atomicCount] = atomic
		self.size = self:getSize(true)
		return atomic
	end,
	addComponent = function(self)
		self:createAtomic()
		self.frameList:createFrame()
		self.geometryList:createGeometry()
		self.size = self:getSize(true)
	end,
	methodContinue = {
		read = function(self,readStream)
			self.struct = ClumpStruct()
			self.struct:read(readStream)
			--Read Frame List
			self.frameList = FrameList()
			self.frameList:read(readStream)
			--Read Geometry List
			self.geometryList = GeometryList()
			self.geometryList:read(readStream)
			--Read Atomics
			self.atomics = {}
			for i=1,self.struct.atomicCount do
				--print("Reading Atomic",i,readStream.readingPos)
				self.atomics[i] = Atomic()
				self.atomics[i]:read(readStream)
			end
			local nextSection
			repeat
				nextSection = Section()
				nextSection:read(readStream)
				if nextSection.type == Struct.typeID then
					recastClass(nextSection,IndexStruct)
					nextSection:read(readStream)
					if not self.indexStructs then self.indexStructs = {} end
					self.indexStructs[#self.indexStructs+1] = nextSection
				elseif nextSection.type == Light.typeID then
					recastClass(nextSection,Light)
					nextSection:read(readStream)
					if not self.lights then self.lights = {} end
					self.lights[#self.lights+1] = nextSection
				end
			until nextSection.type == ClumpExtension.typeID
			--Read Extension
			recastClass(nextSection,ClumpExtension)
			self.extension = nextSection
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			--Write Frame List
			self.frameList:write(writeStream)
			--Write Geometry List
			self.geometryList:write(writeStream)
			--Write Atomics
			for i=1,self.struct.atomicCount do
				--print("Write Atomic",i)
				self.atomics[i]:write(writeStream)
			end
			--Write Lights
			if self.indexStructs then
				for i=1,#self.indexStructs do
					if self.lights[i] then
						self.indexStructs[i]:write(writeStream)
						self.lights[i]:write(writeStream)
					end
				end
			end
			--Write Extension
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			local size = self.struct:getSize()+self.frameList:getSize()+self.geometryList:getSize()
			for i=1,self.struct.atomicCount do
				size = size+self.atomics[i]:getSize()
			end
			size = size+self.extension:getSize()
			return size
		end,
	}
}

class "IndexStruct" {
	extend = "Struct",
	index = false,
	methodContinue = {
		read = function(self,readStream)
			self.index = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.index,uint32)
		end,
		getSize = function(self)
			return 4
		end
	}
}

class "LightStruct" {
	extend = "Struct",
	frameIndex = false,
	radius = false,
	red = false,
	green = false,
	blue = false,
	direction = false,
	flags = false,
	lightType = false,
	methodContinue = {
		read = function(self,readStream)
			self.radius = readStream:read(float)
			self.red = readStream:read(float)
			self.green = readStream:read(float)
			self.blue = readStream:read(float)
			self.direction = readStream:read(float)
			self.flags = readStream:read(uint16)
			self.lightType = readStream:read(uint16)
		end,
		write = function(self,writeStream)
			writeStream:write(self.radius,float)
			writeStream:write(self.red,float)
			writeStream:write(self.green,float)
			writeStream:write(self.blue,float)
			writeStream:write(self.direction,float)
			writeStream:write(self.flags,uint16)
			writeStream:write(self.lightType,uint16)
		end,
		getSize = function(self)
			return 24
		end,
	}
}

class "Light" {	typeID = 0x12,
	extend = "Section",
	struct = false,
	extension = false,
	methodContinue = {
		read = function(self,readStream)
			self.struct = LightStruct()
			self.struct:read(readStream)
			self.extension = Extension()
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			return self.struct:getSize()+self.extension:getSize()
		end,
	}
}

class "ClumpExtension" {
	extend = "Extension",
	collisionSection = false,
	init = function(self,version)
		self.size = self:getSize(true)
		self.version = version
		self.type = ClumpExtension.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			if self.size > 0 then
				self.collisionSection = COLSection()
				self.collisionSection:read(readStream)
			end
		end,
		write = function(self,writeStream)
			if self.collisionSection then
				self.collisionSection:write(writeStream)
			end
		end,
		getSize = function(self)
			if self.collisionSection then
				return self.collisionSection:getSize()
			end
			return 0
		end,
	}
}

class "FrameListStruct" {
	extend = "Struct",
	frameCount = false,
	frameInfo = false,
	init = function(self,version)
		self.frameCount = 0
		self.frameInfo = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = FrameListStruct.typeID
		return self
	end,
	createFrameInfo = function(self)
		self.frameInfo[#self.frameInfo+1] = {
			rotationMatrix = {	--By Default
				{1,0,0},
				{0,1,0},
				{0,0,1},
			},
			positionVector = {0,0,0},
			parentFrame = 0,	--Compatible to lua array
			matrixFlags = 0x00020003,
		}
		self.size = self:getSize(true)
		return #self.frameInfo
	end,
	setFrameInfoParentFrame = function(self,frameInfoID,parentFrameID)
		if not self.frameInfo[frameInfoID] then error("Bad argument @setFrameInfoParentFrame, frame info index out of range, total "..#self.frameInfo.." got "..frameInfoID) end
		self.frameInfo[frameInfoID].parentFrame = parentFrameID
		return self
	end,
	setFrameInfoPosition = function(self,x,y,z)
		if not self.frameInfo[frameInfoID] then error("Bad argument @setFrameInfoParentFrame, frame info index out of range, total "..#self.frameInfo.." got "..frameInfoID) end
		self.frameInfo[frameInfoID].positionVector[1] = x
		self.frameInfo[frameInfoID].positionVector[2] = y
		self.frameInfo[frameInfoID].positionVector[3] = z
		return self
	end,
	setFrameInfoRotation = function(self,rx,ry,rz)
		if not self.frameInfo[frameInfoID] then error("Bad argument @setFrameInfoParentFrame, frame info index out of range, total "..#self.frameInfo.." got "..frameInfoID) end
		local rotMatrix = self.frameInfo[frameInfoID].rotationMatrix
		local rx = math.rad(rx)
		local ry = math.rad(ry)
		local rz = math.rad(rz)
		local cX = math.cos(rx)
		local sX = math.sin(rx)
		local cY = math.cos(ry)
		local sY = math.sin(ry)
		local cZ = math.cos(rz)
		local sZ = math.sin(rz)
		rotMatrix[1][1] = cZ * cY - (sZ * sX) * sY
		rotMatrix[1][2] = (cZ * sX) * sY + sZ * cY
		rotMatrix[1][3] = -cX * sY
		rotMatrix[2][1] = -sZ * cX
		rotMatrix[2][2] = cZ * cX
		rotMatrix[2][3] = sX
		rotMatrix[3][1] = (sZ * sX) * cY + cZ * sY
		rotMatrix[3][2] = sZ * sY - (cZ * sX) * cY
		rotMatrix[3][3] = cX * cY
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.frameCount = readStream:read(uint32)
			if not self.frameInfo then self.frameInfo = {} end
			for i=1,self.frameCount do
				self.frameInfo[i] = {
					rotationMatrix = {
						{readStream:read(float),readStream:read(float),readStream:read(float)},
						{readStream:read(float),readStream:read(float),readStream:read(float)},
						{readStream:read(float),readStream:read(float),readStream:read(float)},
					},
					positionVector = {
						readStream:read(float),readStream:read(float),readStream:read(float),
					},
					parentFrame = readStream:read(uint32)+1,	--Compatible to lua array
					matrixFlags = readStream:read(uint32),
				}
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.frameCount,uint32)
			for i=1,self.frameCount do
				local fInfo = self.frameInfo[i]
				for x=1,3 do for y=1,3 do
					writeStream:write(fInfo.rotationMatrix[x][y],float)
				end end
				writeStream:write(fInfo.positionVector[1],float)
				writeStream:write(fInfo.positionVector[2],float)
				writeStream:write(fInfo.positionVector[3],float)
				writeStream:write(fInfo.parentFrame-1,uint32)	--Compatible to lua array
				writeStream:write(fInfo.matrixFlags,uint32)
			end
		end,
		getSize = function(self)
			return 4+(9*4+3*4+4+4)*#self.frameInfo
		end,
	}
}

class "FrameList" {	typeID = 0x0E,
	extend = "Section",
	struct = false,
	frames = false,
	init = function(self,version)
		self.struct = FrameListStruct():init(version)
		self.frames = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = FrameList.typeID
		return self
	end,
	createFrame = function(self,name)
		local FrameListExtension = FrameListExtension():init(self.version)
		FrameListExtension.frame:setName(name or "unnamed")
		FrameListExtension:update()
		self.struct:createFrameInfo()
		self.struct.frameCount = self.struct.frameCount+1
		self.frames[self.struct.frameCount] = FrameListExtension
		self.size = self:getSize(true)
		return FrameListExtension
	end,
	methodContinue = {
		read = function(self,readStream)
			--Read Struct
			self.struct = FrameListStruct()
			self.struct:read(readStream)
			--Read Frames
			self.frames = {}
			for i=1,self.struct.frameCount do
				self.frames[i] = FrameListExtension()
				self.frames[i]:read(readStream)
			end
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			for i=1,self.struct.frameCount do
				self.frames[i]:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = self.struct:getSize()
			for i=1,self.struct.frameCount do
				size = size+self.frames[i]:getSize()
			end
			return size
		end,
	}
}

class "FrameListExtension" {
	extend = "Extension",
	frame = false,
	HAnimPLG = false,
	init = function(self,version)
		self.frame = Frame():init(version)
		self.size = self:getSize(true)
		self.version = version
		self.type = FrameListExtension.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			if self.size ~= 0 then
				local section = Section()
				section:read(readStream)
				if section.type == HAnimPLG.typeID then
					recastClass(section,HAnimPLG)
					self.HAnimPLG = section
					self.HAnimPLG:read(readStream)
					section = Section()
				end
				recastClass(section,Frame)
				self.frame = section
				self.frame:read(readStream)
			end
		end,
		write = function(self,writeStream)
			if self.HAnimPLG then
				self.HAnimPLG:write(writeStream)
			end
			iprint(self.frame)
			if self.frame then
				self.frame:write(writeStream)
			end
		end,
		getSize = function(self)
			return self.frame:getSize()
		end,
	},
}

class "Frame" {	typeID = 0x253F2FE,
	extend = "Section",
	name = false,
	init = function(self,version)
		self.name = ""
		self.size = self:getSize(true)
		self.version = version
		self.type = Frame.typeID
		return self
	end,
	setName = function(self,name)
		self.name = name
		self.size = self:getSize(true)
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.name = readStream:read(char,self.size)
		end,
		write = function(self,writeStream)
			writeStream:write(self.name,char,self.size)
		end,
		getSize = function(self)
			return #self.name
		end,
	},
}

class "GeometryListStruct" {
	extend = "Struct",
	init = function(self,version)
		self.geometryCount = 0
		self.size = self:getSize(true)
		self.version = version
		self.type = GeometryListStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.geometryCount = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.geometryCount,uint32)
		end,
		getSize = function(self)
			return 4
		end,
	}
}

class "GeometryList" {	typeID = 0x1A,
	extend = "Section",
	struct = false,
	geometries = false,
	init = function(self,version)
		self.struct = GeometryListStruct():init(version)
		self.geometries = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = GeometryList.typeID
		return self
	end,
	createGeometry = function(self)
		local geometry = Geometry():init(self.version)
		self.struct.geometryCount = self.struct.geometryCount+1
		self.geometries[self.struct.geometryCount] = geometry
		self.size = self:getSize(true)
		return geometry
	end,
	methodContinue = {
		read = function(self,readStream)
			self.struct = GeometryListStruct()
			self.struct:read(readStream)
			self.geometries = {}
			--Read Geometries
			for i=1,self.struct.geometryCount do
				--print("Reading Geometry",i)
				self.geometries[i] = Geometry()
				self.geometries[i]:read(readStream)
			end
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			for i=1,self.struct.geometryCount do
				self.geometries[i]:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = self.struct:getSize()
			for i=1,self.struct.geometryCount do
				size = size+self.geometries[i]:getSize()
			end
			return size
		end,
	}
}

class "GeometryStruct" {
	extend = "Struct",
	flags = false,
	trangleCount = false,
	vertexCount = false,
	morphTargetCount = false,
	--Data
	vertexColors = false,
	texCoords = false,
	triangles = false,
	vertices = false,
	normals = false,
	boundingSphere = false,
	hasVertices = false,
	hasNormals = false,
	--Casted From flags
	bTristrip = false,
	bPosition = false,
	bTextured = false,
	bVertexColor = false,
	bNormal = false,
	bLight = false,
	bModulateMaterialColor = false,
	bTextured2 = false,
	bNative = false,
	TextureCount = false,
	--
	init = function(self,version)
		self.flags = 0
		self.triangleCount = 0
		self.vertexCount = 0
		self.morphTargetCount = 1
		self.boundingSphere = {0,0,0,0}
		self.hasVertices = false
		self.hasNormals = false
		self.size = self:getSize(true)
		self.version = version
		self.type = GeometryStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.flags = readStream:read(uint32)
			--Extract Flags
			self.bTristrip = bExtract(self.flags,0) == 1
			self.bPosition = bExtract(self.flags,1) == 1
			self.bTextured = bExtract(self.flags,2) == 1
			self.bVertexColor = bExtract(self.flags,3) == 1
			self.bNormal = bExtract(self.flags,4) == 1
			self.bLight = bExtract(self.flags,5) == 1
			self.bModulateMaterialColor = bExtract(self.flags,6) == 1
			self.bTextured2 = bExtract(self.flags,7) == 1
			self.bNative = bExtract(self.flags,24) == 1
			self.TextureCount = bExtract(self.flags,16,8)
			--Read triangle count
			self.triangleCount = readStream:read(uint32)
			self.vertexCount = readStream:read(uint32)
			self.morphTargetCount = readStream:read(uint32)
			
			if not self.bNative then
				if self.bVertexColor then
					--R,G,B,A
					self.vertexColor = {}
					for vertices=1, self.vertexCount do
						self.vertexColor[vertices] = {readStream:read(uint8),readStream:read(uint8),readStream:read(uint8),readStream:read(uint8)}
					end
				end
				self.texCoords = {}
				for i=1,(self.TextureCount ~= 0 and self.TextureCount or ((self.bTextured and 1 or 0)+(self.bTextured2 and 1 or 0)) ) do
					--U,V
					self.texCoords[i] = {}
					for vertices=1, self.vertexCount do
						self.texCoords[i][vertices] = {readStream:read(float),readStream:read(float)}
					end
				end
				self.triangles = {}
				for i=1,self.triangleCount do
					--Vertex2, Vertex1, MaterialID, Vertex3
					self.triangles[i] = {readStream:read(uint16),readStream:read(uint16),readStream:read(uint16),readStream:read(uint16)}
				end
			end
			for i=1,self.morphTargetCount do	--morphTargetCount should be 1
				--X,Y,Z,Radius
				self.boundingSphere = {readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)}
				self.hasVertices = readStream:read(uint32) ~= 0
				self.hasNormals = readStream:read(uint32) ~= 0
				if self.hasVertices then
					self.vertices = {}
					for vertex=1,self.vertexCount do
						self.vertices[vertex] = {readStream:read(float),readStream:read(float),readStream:read(float)}
					end
				end
				if self.hasNormals then
					self.normals = {}
					for vertex=1,self.vertexCount do
						self.normals[vertex] = {readStream:read(float),readStream:read(float),readStream:read(float)}
					end
				end
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.flags,uint32)
			writeStream:write(self.triangleCount,uint32)
			writeStream:write(self.vertexCount,uint32)
			writeStream:write(self.morphTargetCount,uint32)
			if not self.bNative then
				if self.bVertexColor then
					--R,G,B,A
					for vertices=1, self.vertexCount do
						writeStream:write(self.vertexColor[vertices][1],uint8)
						writeStream:write(self.vertexColor[vertices][2],uint8)
						writeStream:write(self.vertexColor[vertices][3],uint8)
						writeStream:write(self.vertexColor[vertices][4],uint8)
					end
				end
				for i=1,(self.TextureCount ~= 0 and self.TextureCount or ((self.bTextured and 1 or 0)+(self.bTextured2 and 1 or 0)) ) do
					--U,V
					for vertices=1, self.vertexCount do
						writeStream:write(self.texCoords[i][vertices][1],float)
						writeStream:write(self.texCoords[i][vertices][2],float)
					end
				end
				for i=1,self.triangleCount do
					--Vertex2, Vertex1, MaterialID, Vertex3
					writeStream:write(self.triangles[i][1],uint16)
					writeStream:write(self.triangles[i][2],uint16)
					writeStream:write(self.triangles[i][3],uint16)
					writeStream:write(self.triangles[i][4],uint16)
				end
			end
			for i=1,self.morphTargetCount do	--morphTargetCount should be 1
				--X,Y,Z,Radius
				writeStream:write(self.boundingSphere[1],float)
				writeStream:write(self.boundingSphere[2],float)
				writeStream:write(self.boundingSphere[3],float)
				writeStream:write(self.boundingSphere[4],float)
				writeStream:write(self.hasVertices and 1 or 0,uint32)
				writeStream:write(self.hasNormals and 1 or 0,uint32)
				if self.hasVertices then
					for vertex=1,self.vertexCount do
						writeStream:write(self.vertices[vertex][1],float)
						writeStream:write(self.vertices[vertex][2],float)
						writeStream:write(self.vertices[vertex][3],float)
					end
				end
				if self.hasNormals then
					for vertex=1,self.vertexCount do
						writeStream:write(self.normals[vertex][1],float)
						writeStream:write(self.normals[vertex][2],float)
						writeStream:write(self.normals[vertex][3],float)
					end
				end
			end
		end,
		getSize = function(self)
			local size = 4*4
			if not self.bNative then
				if self.bVertexColor then
					size = size+3*1*self.vertexCount
				end
				for i=1,(self.TextureCount ~= 0 and self.TextureCount or ((self.bTextured and 1 or 0)+(self.bTextured2 and 1 or 0)) ) do
					--U,V
					size = size+4*2*self.vertexCount
				end
				size = size+2*4*self.triangleCount
			end
			for i=1,self.morphTargetCount do	--morphTargetCount should be 1
				--X,Y,Z,Radius
				size = size+4*6
				if self.hasVertices then
					size = size+4*3*self.vertexCount
				end
				if self.hasNormals then
					size = size+4*3*self.vertexCount
				end
			end
			return size
		end,
	}
}

class "Geometry" {	typeID = 0x0F,
	extend = "Section",
	struct = false,
	materialList = false,
	extension = false,
	init = function(self,version)
		self.struct = GeometryStruct():init(version)
		self.materialList = MaterialList():init(version)
		self.extension = GeometryExtension():init(version)
		self.size = self:getSize(true)
		self.version = version
		self.type = Geometry.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.struct = GeometryStruct()
			self.struct:read(readStream)
			--Read Material List
			self.materialList = MaterialList()
			self.materialList:read(readStream)
			--Read Extension
			self.extension = GeometryExtension()
			self.extension.parent = self
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			self.materialList:write(writeStream)
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			return self.struct:getSize()+self.materialList:getSize()+self.extension:getSize()
		end,
	}
}

class "GeometryExtension" {
	extend = "Extension",
	binMeshPLG = false,
	breakable = false,
	nightVertexColor = false,
	effect2D = false,
	skinPLG = false,
	init = function(self,version)
		self.size = self:getSize(true)
		self.version = version
		self.type = GeometryExtension.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			local nextSection
			local readSize = 0
			repeat
				nextSection = Section()
				nextSection:read(readStream)
				if nextSection.type == BinMeshPLG.typeID then
					recastClass(nextSection,BinMeshPLG)
					self.binMeshPLG = nextSection
				elseif nextSection.type == Breakable.typeID then
					recastClass(nextSection,Breakable)
					self.breakable = nextSection
				elseif nextSection.type == NightVertexColor.typeID then
					recastClass(nextSection,NightVertexColor)
					self.nightVertexColor = nextSection
				elseif nextSection.type == Effect2D.typeID then
					recastClass(nextSection,Effect2D)
					self.effect2D = nextSection
				elseif nextSection.type == SkinPLG.typeID then
					recastClass(nextSection,SkinPLG)
					self.skinPLG = nextSection
				else
					error("Unsupported Geometry Plugin "..nextSection.type)
				end
				nextSection.parent = self
				nextSection:read(readStream)
				readSize = readSize+nextSection.size+12
			until readSize >= self.size
		end,
		write = function(self,writeStream)
			if self.binMeshPLG then
				self.binMeshPLG:write(writeStream)
			end
			if self.skinPLG then
				self.skinPLG:write(writeStream)
			end
			if self.breakable then
				self.breakable:write(writeStream)
			end
			if self.nightVertexColor then
				self.nightVertexColor:write(writeStream)
			end
			if self.effect2D then
				self.effect2D:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = 0
			if self.binMeshPLG then
				size = size+self.binMeshPLG:getSize()
			end
			if self.breakable then
				size = size+self.breakable:getSize()
			end
			if self.nightVertexColor then
				size = size+self.nightVertexColor:getSize()
			end
			if self.effect2D then
				size = size+self.effect2D:getSize()
			end
			return size
		end,
	}
}

class "NightVertexColor" {	typeID = 0x253F2F9,
	extend = "Section",
	hasColor = false,
	colors = false,
	methodContinue = {
		read = function(self,readStream)
			self.hasColor = readStream:read(uint32)
			self.colors = {}
			for i=1,(self.size-4)/4 do
				self.colors[i] = {readStream:read(uint8),readStream:read(uint8),readStream:read(uint8),readStream:read(uint8)}
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.hasColor,uint32)
			for i=1,#self.colors do
				writeStream:write(self.colors[i][1],uint8)
				writeStream:write(self.colors[i][2],uint8)
				writeStream:write(self.colors[i][3],uint8)
				writeStream:write(self.colors[i][4],uint8)
			end
		end,
		getSize = function(self)
			return 4*#self.colors
		end,
	}
}

class "MaterialListStruct" {
	extend = "Struct",
	materialCount = false,
	materialIndices = false,
	init = function(self,version)
		self.materialCount = 0
		self.materialIndices = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = MaterialListStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.materialCount = readStream:read(uint32)
			self.materialIndices = {}
			for i=1,self.materialCount do
				--For material, -1; For a pointer of existing material, other index value.
				self.materialIndices[i] = readStream:read(int32)
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.materialCount,uint32)
			for i=1,self.materialCount do
				writeStream:write(self.materialIndices[i],int32)
			end
		end,
		getSize = function(self)
			return 4+4*self.materialCount
		end,
	}
}

class "MaterialList" {	typeID = 0x08,
	extend = "Section",
	struct = false,
	materials = false,
	init = function(self,version)
		self.struct = MaterialListStruct():init(version)
		self.materials = {}
		self.size = self:getSize(true)
		self.version = version
		self.type = MaterialList.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			--Read Material List Struct
			self.struct = MaterialListStruct()
			self.struct:read(readStream)
			--Read Materials
			self.materials = {}
			for matIndex=1,self.struct.materialCount do
				--print("Reading Material",matIndex,readStream.readingPos)
				self.materials[matIndex] = Material()
				self.materials[matIndex]:read(readStream)
			end
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			for matIndex=1,self.struct.materialCount do
				self.materials[matIndex]:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = self.struct:getSize()
			for matIndex=1,self.struct.materialCount do
				size = size+self.materials[matIndex]:getSize()
			end
			return size
		end,
	}
}

class "MaterialStruct" {
	extend = "Struct",
	flags = false,
	color = false,
	unused = false,
	isTextured = false,
	ambient = false,
	specular = false,
	diffuse = false,
	init = function(self,version)
		self.flags = 0
		self.color = {255,255,255,255}
		self.unused = 0
		self.isTextured = 0
		self.ambient = 1
		self.specular = 1
		self.diffuse = 1
		self.size = self:getSize(true)
		self.version = version
		self.type = MaterialStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.flags = readStream:read(uint32)
			self.color = {readStream:read(uint8),readStream:read(uint8),readStream:read(uint8),readStream:read(uint8)}
			self.unused = readStream:read(uint32)
			self.isTextured = readStream:read(uint32) == 1
			self.ambient = readStream:read(float)
			self.specular = readStream:read(float)
			self.diffuse = readStream:read(float)
		end,
		write = function(self,writeStream)
			writeStream:write(self.flags,uint32)
			writeStream:write(self.color[1],uint8)
			writeStream:write(self.color[2],uint8)
			writeStream:write(self.color[3],uint8)
			writeStream:write(self.color[4],uint8)
			writeStream:write(self.unused,uint32)
			writeStream:write(self.isTextured and 1 or 0,uint32)
			writeStream:write(self.ambient,float)
			writeStream:write(self.specular,float)
			writeStream:write(self.diffuse,float)
		end,
		getSize = function(self)
			return 28	-- 4+1*4+4+4+4*3
		end,
	}
}

class "MaterialExtension" {
	extend = "Extension",
	materialEffect = false,
	reflectionMaterial = false,
	specularMaterial = false,
	uvAnimation = false,
	init = function(self,version)
		self.size = self:getSize(true)
		self.version = version
		self.type = MaterialExtension.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			--Custom Section: Reflection Material
			local readSize = 0
			while self.size > readSize do
				local section = Section()
				section:read(readStream)
				if section.type == ReflectionMaterial.typeID then
					recastClass(section,ReflectionMaterial)
					self.reflectionMaterial = section
					section:read(readStream)
				elseif section.type == SpecularMaterial.typeID then
					recastClass(section,SpecularMaterial)
					self.specularMaterial = section
					section:read(readStream)
				elseif section.type == MaterialEffectPLG.typeID then
					recastClass(section,MaterialEffectPLG)
					self.materialEffect = section
					section:read(readStream)
				elseif section.type == UVAnimPLG.typeID then
					recastClass(section,UVAnimPLG)
					self.uvAnimation = section
					section:read(readStream)
				end
				readSize = readSize+section.size+12
			end
		end,
		write = function(self,writeStream)
			if self.reflectionMaterial then
				self.reflectionMaterial:write(writeStream)
			end
			if self.specularMaterial then
				self.specularMaterial:write(writeStream)
			end
			if self.materialEffect then
				self.materialEffect:write(writeStream)
			end
		end,
		getSize = function(self)
			return self.reflectionMaterial:getSize()+(self.specularMaterial and self.specularMaterial:getSize() or 0)
		end,
	}
}

class "Material" {	typeID = 0x07,
	extend = "Section",
	struct = false,
	texture = false,
	extension = false,
	init = function(self,ver)
		self.struct = MaterialStruct():init(version)
		self.extension = MaterialExtension():init(version)
		self.size = self:getSize(true)
		self.version = version
		self.type = Material.typeID
	end,
	methodContinue = {
		read = function(self,readStream)
			--Read Material Struct
			self.struct = MaterialStruct()
			self.struct:read(readStream)
			if self.struct.isTextured then
				--Read Texture
				self.texture = Texture()
				self.texture:read(readStream)
			end
			--Read Extension
			self.extension = MaterialExtension()
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			if self.struct.isTextured then
				self.texture:write(writeStream)
			end
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			return self.struct:getSize()+(self.struct.isTextured and self.texture:getSize() or 0)+self.extension:getSize()
		end,
	}
}

class "ReflectionMaterial" {	typeID = 0x0253F2FC,
	extend = "Section",
	envMapScaleX = false,
	envMapScaleY = false,
	envMapOffsetX = false,
	envMapOffsetY = false,
	reflectionIntensity = false,
	envTexturePtr = false,
	methodContinue = {
		read = function(self,readStream)
			self.envMapScaleX = readStream:read(float)
			self.envMapScaleY = readStream:read(float)
			self.envMapOffsetX = readStream:read(float)
			self.envMapOffsetY = readStream:read(float)
			self.reflectionIntensity = readStream:read(float)
			self.envTexturePtr = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.envMapScaleX,float)
			writeStream:write(self.envMapScaleY,float)
			writeStream:write(self.envMapOffsetX,float)
			writeStream:write(self.envMapOffsetY,float)
			writeStream:write(self.reflectionIntensity,float)
			writeStream:write(self.envTexturePtr,uint32)
		end,
		getSize = function(self)
			return 24
		end,
	}
}

class "SpecularMaterial" {	typeID = 0x0253F2F6,
	extend = "Section",
	specularLevel = false,
	textureName = false,
	methodContinue = {
		read = function(self,readStream)
			self.specularLevel = readStream:read(float)
			self.textureName = readStream:read(char,24)
		end,
		write = function(self,writeStream)
			writeStream:write(self.specularLevel,float)
			writeStream:write(self.textureName,char,24)
		end,
		getSize = function(self)
			return 28
		end,
	}
}

class "TextureStruct" {
	extend = "Struct",
	flags = false,
	--Casted From Flags (Read Only)
	filter = false,
	UAddressing = false,
	VAddressing = false,
	hasMipmaps = false,
	--
	init = function(self,ver)
		self.flags = 0
		self.size = self:getSize(true)
		self.version = version
		self.type = TextureStruct.typeID
	end,
	methodContinue = {
		read = function(self,readStream)
			self.flags = readStream:read(uint32)
			--Casted From Flags (Read Only)
			self.filter = bExtract(self.flags,24,8)
			self.UAddressing = bExtract(self.flags,24,4)
			self.VAddressing = bExtract(self.flags,20,4)
			self.hasMipmaps = bExtract(self.flags,19) == 1
			--
		end,
		write = function(self,writeStream)
			writeStream:write(self.flags,uint32)
		end,
		getSize = function(self)
			return 4
		end,
	}
}

class "Texture" {	typeID = 0x06,
	extend = "Section",
	struct = false,
	textureName = false,
	maskName = false,
	extension = false,
	init = function(self,ver)
		self.struct = TextureStruct():init(version)
		self.textureName = String():init(version)
		self.maskName = String():init(version)
		self.extension = Extension():init(version)
		self.size = self:getSize(true)
		self.version = version
		self.type = Texture.typeID
	end,
	methodContinue = {
		read = function(self,readStream)
			--Read Texture Struct
			self.struct = TextureStruct()
			self.struct:read(readStream)
			--Read Texture Name
			self.textureName = String()
			self.textureName:read(readStream)
			--Read Mask Name
			self.maskName = String()
			self.maskName:read(readStream)
			--Read Extension
			self.extension = Extension()
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			self.textureName:write(writeStream)
			self.maskName:write(writeStream)
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			return self.struct:getSize()+self.textureName:getSize()+self.maskName:getSize()+self.extension:getSize()
		end,
	}
}

class "String" {	typeID = 0x02,
	extend = "Section",
	string = false,
	init = function(self,ver)
		self.string = ""
		self.size = self:getSize(true)
		self.version = version
		self.type = String.typeID
	end,
	methodContinue = {
		read = function(self,readStream)
			self.string = readStream:read(char,self.size)
		end,
		write = function(self,writeStream)
			local diff = self.size-#self.string --Diff
			writeStream:write(self.string,bytes,#self.string)
			writeStream:write(string.rep("\0",diff),bytes,diff)
		end,
		getSize = function(self)
			return self.size
		end,
	}
}

class "BinMeshPLG" {	typeID = 0x50E,
	extend = "Section",
	faceType = false,
	materialSplitCount = false,
	faceCount = false,
	materialSplits = false,
	methodContinue = {
		read = function(self,readStream)
			self.faceType = readStream:read(uint32)
			self.materialSplitCount = readStream:read(uint32)
			self.faceCount = readStream:read(uint32)
			self.materialSplits = {}
			for i=1,self.materialSplitCount do
				--Faces, MaterialIndex
				self.materialSplits[i] = {readStream:read(uint32),readStream:read(uint32)}
				self.materialSplits[i][3] = {}
				for faceIndex=1, self.materialSplits[i][1] do
					self.materialSplits[i][3][faceIndex] = readStream:read(uint32)	--Face Index
				end
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.faceType,uint32)
			writeStream:write(self.materialSplitCount,uint32)
			writeStream:write(self.faceCount,uint32)
			for i=1,self.materialSplitCount do
				--Faces, MaterialIndex
				writeStream:write(self.materialSplits[i][1],uint32)
				writeStream:write(self.materialSplits[i][2],uint32)
				for faceIndex=1,self.materialSplits[i][1] do
					writeStream:write(self.materialSplits[i][3][faceIndex],uint32)	--Face Index
				end
			end
		end,
		getSize = function(self)
			local size = 4*3
			for i=1,self.materialSplitCount do
				size = size+8+self.materialSplits[i][1]*4
			end
			return size
		end,
	}
}

class "Breakable" {	typeID = 0x0253F2FD,
	extend = "Section",
	flags = false,
	positionRule = false,
	vertexCount = false,
	offsetVerteices = false,		--Unused
	offsetCoords = false,			--Unused
	offsetVetrexColor = false,		--Unused
	triangleCount = false,
	offsetVertexIndices = false,	--Unused
	offsetMaterialIndices = false,	--Unused
	materialCount = false,
	offsetTextures = false,			--Unused
	offsetTextureNames = false,		--Unused
	offsetTextureMasks = false,		--Unused
	offsetAmbientColors = false,	--Unused
	
	vertices = false,
	triangles = false,
	texCoords = false,
	triangleMaterials = false,
	materialTextureNames = false,
	materialTextureMasks = false,
	materialAmbientColor = false,

	methodContinue = {
		read = function(self,readStream)
			self.flags = readStream:read(uint32)
			if self.flags ~= 0 then
				self.positionRule = readStream:read(uint32)
				self.vertexCount = readStream:read(uint32)
				self.offsetVerteices = readStream:read(uint32)			--Unused
				self.offsetCoords = readStream:read(uint32)				--Unused
				self.offsetVetrexLight = readStream:read(uint32)	--Unused
				self.triangleCount = readStream:read(uint32)
				self.offsetVertexIndices = readStream:read(uint32)		--Unused
				self.offsetMaterialIndices = readStream:read(uint32)	--Unused
				self.materialCount = readStream:read(uint32)
				self.offsetTextures = readStream:read(uint32)			--Unused
				self.offsetTextureNames = readStream:read(uint32)		--Unused
				self.offsetTextureMasks = readStream:read(uint32)		--Unused
				self.offsetAmbientColors = readStream:read(uint32)		--Unused
				
				self.vertices = {}
				for i=1,self.vertexCount do
					--x,y,z
					self.vertices[i] = {readStream:read(float),readStream:read(float),readStream:read(float)}
				end
				self.texCoords = {}
				for i=1,self.vertexCount do
					--u,v
					self.texCoords[i] = {readStream:read(float),readStream:read(float)}
				end
				self.vertexColor = {}
				for i=1,self.vertexCount do
					--r,g,b,a
					self.vertexColor[i] = {readStream:read(uint8),readStream:read(uint8),readStream:read(uint8),readStream:read(uint8)}
				end
				self.triangles = {}
				for i=1,self.triangleCount do
					self.triangles[i] = {readStream:read(uint16),readStream:read(uint16),readStream:read(uint16)}
				end
				self.tiangleMaterials = {}
				for i=1,self.triangleCount do
					self.tiangleMaterials[i] = readStream:read(uint16)
				end
				self.materialTextureNames = {}
				for i=1,self.materialCount do
					self.materialTextureNames[i] = readStream:read(char,32)
				end
				self.materialTextureMasks = {}
				for i=1,self.materialCount do
					self.materialTextureMasks[i] = readStream:read(char,32)
				end
				self.ambientColor = {}
				for i=1,self.materialCount do
					self.ambientColor[i] = {readStream:read(float),readStream:read(float),readStream:read(float)}
				end
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.flags,uint32)
			if self.flags ~= 0 then
				writeStream:write(self.positionRule,uint32)
				writeStream:write(self.vertexCount,uint32)
				writeStream:write(self.offsetVerteices,uint32)
				writeStream:write(self.offsetCoords,uint32)
				writeStream:write(self.offsetVetrexLight,uint32)
				writeStream:write(self.triangleCount,uint32)
				writeStream:write(self.offsetVertexIndices,uint32)
				writeStream:write(self.offsetMaterialIndices,uint32)
				writeStream:write(self.materialCount,uint32)
				writeStream:write(self.offsetTextures,uint32)
				writeStream:write(self.offsetTextureNames,uint32)
				writeStream:write(self.offsetTextureMasks,uint32)
				writeStream:write(self.offsetAmbientColors,uint32)
				
				for i=1,self.vertexCount do
					--x,y,z
					writeStream:write(self.vertices[i][1],float)
					writeStream:write(self.vertices[i][2],float)
					writeStream:write(self.vertices[i][3],float)
				end
				for i=1,self.vertexCount do
					--u,v
					writeStream:write(self.texCoords[i][1],float)
					writeStream:write(self.texCoords[i][2],float)
				end
				for i=1,self.vertexCount do
					--r,g,b,a
					writeStream:write(self.vertexColor[i][1],uint8)
					writeStream:write(self.vertexColor[i][2],uint8)
					writeStream:write(self.vertexColor[i][3],uint8)
					writeStream:write(self.vertexColor[i][4],uint8)
				end
				for i=1,self.triangleCount do
					writeStream:write(self.triangles[i][1],uint16)
					writeStream:write(self.triangles[i][2],uint16)
					writeStream:write(self.triangles[i][3],uint16)
				end
				for i=1,self.triangleCount do
					writeStream:write(self.tiangleMaterials[i],uint16)
				end
				for i=1,self.materialCount do
					writeStream:write(self.materialTextureNames[i],char,32)
				end
				for i=1,self.materialCount do
					writeStream:write(self.materialTextureMasks[i],char,32)
				end
				for i=1,self.materialCount do	--Normalized to [0,1]
					writeStream:write(self.ambientColor[i][1],float)
					writeStream:write(self.ambientColor[i][2],float)
					writeStream:write(self.ambientColor[i][3],float)
				end
			end
		end,
		getSize = function(self)
			if self.flags == 0 then
				return 4
			else
				return 14*4+self.vertexCount*8*4+self.materialCount*32*2+self.materialCount*3*4
			end
		end,
	}
}

class "AtomicStruct" {
	extend = "Struct",
	frameIndex = false,			-- Index of the frame within the clump's frame list.
	geometryIndex = false,		-- Index of the geometry within the clump's frame list.
	flags = false,				-- Flags
	unused = false,				-- Unused
	--Casted From flags
	atomicCollisionTest = false,	--Unused
	atomicRender = false,			--The atomic is rendered if it is in the view frustum. It's set to TRUE for all models by default.
	--
	init = function(self,version)
		self.frameIndex = 0
		self.geometryIndex = 0
		self.flags = 5
		self.unused = 0
		self.size = self:getSize(true)
		self.version = version
		self.type = AtomicStruct.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.frameIndex = readStream:read(uint32)
			self.geometryIndex = readStream:read(uint32)
			self.flags = readStream:read(uint32)
			self.unused = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.frameIndex,uint32)
			writeStream:write(self.geometryIndex,uint32)
			writeStream:write(self.flags,uint32)
			writeStream:write(self.unused,uint32)
		end,
		getSize = function(self)
			return 16
		end,
	}
}

class "AtomicExtension" {
	extend = "Extension",
	pipline = false,
	materialEffect = false,
	init = function(self,version)
		self.size = self:getSize(true)
		self.version = version
		self.type = AtomicExtension.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			local nextSection
			local readSize = 0
			repeat
				nextSection = Section()
				nextSection:read(readStream)
				if nextSection.type == Pipline.typeID then
					recastClass(nextSection,Pipline)
					self.pipline = nextSection
				elseif nextSection.type == MaterialEffectPLG.typeID then
					recastClass(nextSection,MaterialEffectPLG)
					self.materialEffect = nextSection
				else
					error("Unsupported Automic Plugin "..nextSection.type)
				end
				nextSection.parent = self
				nextSection:read(readStream)
				readSize = readSize+nextSection.size+12
			until readSize >= self.size
		end,
		write = function(self,writeStream)
			if self.pipline then
				self.pipline:write(writeStream)
			end
			if self.materialEffect then
				self.materialEffect:write(writeStream)
			end
		end,
		getSize = function(self)
			local size = 0
			if self.pipline then
				size = size+self.pipline:getSize()
			end
			if self.materialEffect then
				size = size+self.materialEffect:getSize()
			end
			return size
		end,
	}
}

class "Atomic" {	typeID = 0x14,
	extend = "Section",
	struct = false,
	extension = false,
	init = function(self,version)
		self.struct = AtomicStruct():init(version)
		self.extension = AtomicExtension():init(version)
		self.size = self:getSize(true)
		self.version = version
		self.type = Atomic.typeID
		return self
	end,
	methodContinue = {
		read = function(self,readStream)
			self.struct = AtomicStruct()
			self.struct:read(readStream)
			self.extension = AtomicExtension()
			self.extension:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
			self.extension:write(writeStream)
		end,
		getSize = function(self)
			return self.struct:getSize()+self.extension:getSize()
		end,
	}
}

class "Pipline" {	typeID = 0x1F,	--Right To Render
	extend = "Section",
	pluginIdentifier = false,
	extraData = false,
	methodContinue = {
		read = function(self,readStream)
			self.pluginIdentifier = readStream:read(uint32)
			self.extraData = readStream:read(uint32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.pluginIdentifier,uint32)
			writeStream:write(self.extraData,uint32)
		end,
		getSize = function(self)
			return 8
		end,
	}
}

class "MaterialEffectPLG" {	typeID = 0x120,
	extend = "Section",
	effectType = false,
	
	--0x02
	texture = false,
	unused = false,
	reflectionCoefficient = false,
	useFrameBufferAlphaChannel = false,
	useEnvMap = false,
	endPadding = false,
	--0x05
	unused = false,
	endPadding = false,
	
	methodContinue = {
		read = function(self,readStream)
			self.effectType = readStream:read(uint32)
			if self.effectType == 0x00 or self.effectType == 0x01 then
				--Nothing
			elseif self.effectType == 0x02 then
				self.unused = readStream:read(uint32)
				self.reflectionCoefficient = readStream:read(float)
				self.useFrameBufferAlphaChannel = readStream:read(uint32) == 1
				self.useEnvMap = readStream:read(uint32) == 1
				if self.useEnvMap then
					self.texture = Texture()
					self.texture:read(readStream)
				end
				self.endPadding = readStream:read(uint32)
			elseif self.effectType == 0x05 then
				self.unused = readStream:read(uint32)
				self.endPadding = readStream:read(uint32)
			else
				print("Bad effectType @MaterialEffectPLG, effect ID "..self.effectType.." is not implemented")
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.effectType,uint32)
			if self.effectType == 0x00 or self.effectType == 0x01 then
				--Nothing
			elseif self.effectType == 0x02 then
				writeStream:write(self.unused,uint32)
				writeStream:write(self.reflectionCoefficient,float)
				writeStream:write(self.useFrameBufferAlphaChannel and 1 or 0,uint32)
				writeStream:write(self.useEnvMap and 1 or 0,uint32)
				if self.useEnvMap then
					self.texture:write(writeStream)
				end
				writeStream:write(self.endPadding,uint32)
			elseif self.effectType == 0x05 then
				writeStream:write(self.unused,uint32)
				writeStream:write(self.endPadding,uint32)
			else
				print("Bad effectType @MaterialEffectPLG, effect ID "..self.effectType.." is not implemented")
			end
		end,
		getSize = function(self)
			local size = 4
			if self.effectType == 0x00 or self.effectType == 0x01 then
				--Nothing
			elseif self.effectType == 0x02 then
				size = size+4*5+(self.useEnvMap and self.texture:getSize() or 0)+4
			elseif self.effectType == 0x05 then
				size = size+8+4
			end
			return size
		end,
	}
}

class "UVAnimPLGStruct" {
	extend = "Struct",
	unused = false,
	name = false,
	methodContinue = {
		read = function(self,readStream)
			self.unused = readStream:read(uint32)
			self.name = readStream:read(char,32)
		end,
		write = function(self,writeStream)
			writeStream:write(self.unused,uint32)
			writeStream:write(self.name,char,32)
		end,
		getSize = function(self)
			return 36
		end,
	}
}

class "UVAnimPLG" {	typeID = 0x135,
	extend = "Section",
	struct = false,
	methodContinue = {
		read = function(self,readStream)
			self.struct = UVAnimPLGStruct()
			self.struct:read(readStream)
		end,
		write = function(self,writeStream)
			self.struct:write(writeStream)
		end,
		getSize = function(self)
			return self.struct:getSize()
		end,
	}
}

class "HAnimPLG" {	typeID = 0x11E,
	extend = "Section",
	animVersion = 0x100,	--By Default
	nodeID = false,
	nodeCount = false,
	flags = false,
	keyFrameSize = 36,		--By Default
	nodes = false,
	methodContinue = {
		read = function(self,readStream)
			self.animVersion = readStream:read(uint32)
			self.nodeID = readStream:read(uint32)
			self.nodeCount = readStream:read(uint32)
			if self.nodeCount ~= 0 then	--Root Bone
				self.flags = readStream:read(uint32)
				self.keyFrameSize = readStream:read(uint32)
				self.nodes = {}
				for i=1,self.nodeCount do
					self.nodes[i] = {
						nodeID = readStream:read(uint32),		--Identify
						nodeIndex = readStream:read(uint32),	--Index in array
						flags = readStream:read(uint32),
					}
				end
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.animVersion,uint32)
			writeStream:write(self.nodeID,uint32)
			writeStream:write(self.nodeCount,uint32)
			if self.nodeCount ~= 0 then	--Root Bone
				writeStream:write(self.flags,uint32)
				writeStream:write(self.keyFrameSize,uint32)
				for i=1,self.nodeCount do
					writeStream:write(self.nodes[i].nodeID,uint32)
					writeStream:write(self.nodes[i].nodeIndex,uint32)
					writeStream:write(self.nodes[i].flags,uint32)
				end
			end
		end,
		getSize = function(self)
			local size = 3*4
			if self.nodeCount ~= 0 then	--Root Bone
				size = size+8+self.nodeCount*4
			end
			return size
		end,
	}
}

class "SkinPLG" {	typeID = 0x116,
	extend = "Section",
	boneCount = false,
	usedBoneCount = false,
	maxVertexWeights = false,
	usedBoneIndice = false,
	boneVertices = false,
	boneVertexWeights = false,
	bones = false,
	methodContinue = {
		read = function(self,readStream)
			self.boneCount = readStream:read(uint8)
			self.usedBoneCount = readStream:read(uint8)
			self.maxVertexWeights = readStream:read(uint8)
			readStream:read(uint8)	--Padding
			self.usedBoneIndice = {}
			for i=1,self.usedBoneCount do
				self.usedBoneIndice[i] = readStream:read(uint8)
			end
			self.boneVertices = {}
			for i=1,self.parent.parent.struct.vertexCount do
				self.boneVertices[i] = {readStream:read(uint8),readStream:read(uint8),readStream:read(uint8),readStream:read(uint8)}
				
			end
			self.boneVertexWeights = {}
			for i=1,self.parent.parent.struct.vertexCount do
				self.boneVertexWeights[i] = {readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)}
			
			end
			self.bones = {}
			for i=1,self.boneCount do
				if self.version ~= 0x1803FFFF then
					readStream:read(uint32)
				end
				self.bones[i] = {
					{readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)},
					{readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)},
					{readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)},
					{readStream:read(float),readStream:read(float),readStream:read(float),readStream:read(float)},
				}
			end
			if self.version == 0x1803FFFF then
				readStream:read(uint32)	--unused
				readStream:read(uint32)	--unused
				readStream:read(uint32)	--unused
			end
		end,
		write = function(self,writeStream)
			writeStream:write(self.boneCount,uint8)
			writeStream:write(self.usedBoneCount,uint8)
			writeStream:write(self.maxVertexWeights,uint8)
			writeStream:write(0,uint8)	--Padding
			for i=1,self.usedBoneCount do
				writeStream:write(self.usedBoneIndice[i],uint8)
			end
			for i=1,self.parent.parent.struct.vertexCount do
				writeStream:write(self.boneVertices[i][1],uint8)
				writeStream:write(self.boneVertices[i][2],uint8)
				writeStream:write(self.boneVertices[i][3],uint8)
				writeStream:write(self.boneVertices[i][4],uint8)
				
			end
			for i=1,self.parent.parent.struct.vertexCount do
				writeStream:write(self.boneVertexWeights[i][1],float)
				writeStream:write(self.boneVertexWeights[i][2],float)
				writeStream:write(self.boneVertexWeights[i][3],float)
				writeStream:write(self.boneVertexWeights[i][4],float)
			end
			for i=1,self.boneCount do
				if self.version ~= 0x1803FFFF then
					writeStream:write(0xDEADDEAD,uint32)
				end
				local boneTransform = self.bones[i]
				writeStream:write(boneTransform[1][1],float)
				writeStream:write(boneTransform[1][2],float)
				writeStream:write(boneTransform[1][3],float)
				writeStream:write(boneTransform[1][4],float)
				writeStream:write(boneTransform[2][1],float)
				writeStream:write(boneTransform[2][2],float)
				writeStream:write(boneTransform[2][3],float)
				writeStream:write(boneTransform[2][4],float)
				writeStream:write(boneTransform[3][1],float)
				writeStream:write(boneTransform[3][2],float)
				writeStream:write(boneTransform[3][3],float)
				writeStream:write(boneTransform[3][4],float)
				writeStream:write(boneTransform[4][1],float)
				writeStream:write(boneTransform[4][2],float)
				writeStream:write(boneTransform[4][3],float)
				writeStream:write(boneTransform[4][4],float)
			end
			if self.version == 0x1803FFFF then
				writeStream:write(0,uint32)	--unused
				writeStream:write(0,uint32)	--unused
				writeStream:write(0,uint32)	--unused
			end
		end,
		getSize = function(self)
			local size = 4+self.usedBoneCount+self.parent.parent.struct.vertexCount*5
			if size.version == 0x1803FFFF then
				size = size+self.boneCount*16*4+3*4
			else
				size = size+self.boneCount*17*4
			end
			return size
		end,
	}
}

class "COLSection" {	typeID = 0x253F2FA,
	extend = "Section",
	collisionRaw = false,
	methodContinue = {
		read = function(self,readStream)
			self.collisionRaw = readStream:read(bytes,self.size)
		end,
		write = function(self,writeStream)
			writeStream:write(self.collisionRaw,bytes,#self.collisionRaw)
		end,
		getSize = function(self)
			return #self.collisionRaw
		end,
	}
}

class "DFFIO" {
	uvAnimDict = false,
	clumps = false,
	readStream = false,
	writeStream = false,
	version = false,
	load = function(self,pathOrRaw)
		if fileExists(pathOrRaw) then
			local f = fileOpen(pathOrRaw)
			if f then
				pathOrRaw = fileRead(f,fileGetSize(f))
				fileClose(f)
			end
		end
		self.readStream = ReadStream(pathOrRaw)
		self.clumps = {}
		while self.readStream.readingPos+12 < #pathOrRaw do
			local nextSection = Section()
			nextSection:read(self.readStream)
			self.version = nextSection.version
			if nextSection.type == UVAnimDict.typeID then
				recastClass(nextSection,UVAnimDict)
				self.uvAnimDict = nextSection
				nextSection:read(self.readStream)
			elseif nextSection.type == Clump.typeID then
				recastClass(nextSection,Clump)
				self.clumps[#self.clumps+1] = nextSection
				nextSection:read(self.readStream)
			else
				break	--Read End
			end
		end
	end,
	createClump = function(self,version)
		self.clumps[#self.clumps+1] = Clump()
		self.clumps[#self.clumps+1]:init(version or 0x1803FFFF)
	end,
	save = function(self,fileName)
		self.writeStream = WriteStream()
		for i=1,#self.clumps do
			self.clumps[i]:write(self.writeStream)
		end
		local str = self.writeStream:save()
		if fileName then
			if fileExists(fileName) then fileDelete(fileName) end
			local f = fileCreate(fileName)
			fileWrite(f,str)
			fileClose(f)
			return true
		end
		return str
	end,
}
