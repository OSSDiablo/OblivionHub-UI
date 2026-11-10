return function(Lib)
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local T = Lib.Theme
	local F = Lib.Fonts

	local KINDS = {
		"Toggle",
		"Button",
		"Slider",
		"Dropdown",
		"Input",
		"FeatureTile",
		"Keybind",
		"ColorPicker",
		"Stepper",
		"Menu",
	}

	local function new(class, props)
		local o = Instance.new(class)
		for k, v in props do
			if k ~= "Parent" then
				o[k] = v
			end
		end
		o.Parent = props.Parent
		return o
	end
	local function corner(o, r)
		return new("UICorner", { CornerRadius = UDim.new(0, r or 10), Parent = o })
	end
	local function stroke(o, col)
		local s = new("UIStroke", {
			Color = col or T.Stroke,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = o,
		})
		pcall(function()
			s.BorderStrokePosition = Enum.BorderStrokePosition.Inner
		end)
		return s
	end
	local function text(props)
		props.BackgroundTransparency = 1
		props.FontFace = props.FontFace or F.Medium
		props.TextColor3 = props.TextColor3 or T.Text
		props.TextSize = props.TextSize or 14
		props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
		props.TextTruncate = props.TextTruncate or Enum.TextTruncate.AtEnd
		return new("TextLabel", props)
	end

	local icons
	local function iconLabel(parent, name, size, col, props)
		if icons == nil then
			local ok, lib = pcall(function()
				return loadstring(
					game:HttpGet(
						"https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"
					)
				)()
			end)
			icons = ok and lib or false
		end
		local c = icons and (icons.Icons and icons.Icons[name] or icons[name])
		local o = new("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(size, size),
			ImageColor3 = col or T.Muted,
			Parent = parent,
		})
		if type(c) == "string" then
			o.Image = c
		elseif type(c) == "table" then
			local img = c.Image
			if type(img) == "number" then
				img = "rbxassetid://" .. img
			end
			o.Image = (icons.Spritesheets and icons.Spritesheets[tostring(img)]) or img
			if c.ImageRectPosition then
				o.ImageRectOffset = c.ImageRectPosition
				o.ImageRectSize = c.ImageRectSize
			end
		end
		for k, v in props or {} do
			o[k] = v
		end
		return o
	end

	local function fmt(n)
		local s = tostring(math.floor(n))
		return s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
	end

	return function(Window, opts)
		opts = opts or {}
		local tab = Window.Home
		if not tab then
			return nil
		end

		local features = 0
		local first = Window.Tabs and Window.Tabs[1]
		local mt = first and getmetatable(first)
		local proto = mt and type(mt.__index) == "table" and mt.__index
		if proto and not proto._showcaseWrapped then
			proto._showcaseWrapped = true
			for _, kind in KINDS do
				local base = proto[kind]
				if type(base) == "function" then
					local wrapped = function(self, ...)
						if self ~= tab then
							features += 1
						end
						return base(self, ...)
					end
					proto[kind] = wrapped
					proto["Create" .. kind] = wrapped
				end
			end
		end

		local root = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = opts.Order or 3,
			Parent = tab.List,
		})
		root:SetAttribute("NoDrag", true)
		for _, o in tab.List:GetChildren() do
			if o ~= root and o:IsA("GuiObject") and o.LayoutOrder >= root.LayoutOrder then
				o.LayoutOrder += 1
			end
		end
		new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = root })

		local head =
			new("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = 1, Parent = root })
		local headText = text({
			Position = UDim2.fromOffset(2, 6),
			Size = UDim2.new(0, 0, 0, 16),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = string.upper(opts.Section or "Oblivion"),
			TextSize = 12,
			TextColor3 = T.Muted,
			TextTruncate = Enum.TextTruncate.None,
			Parent = head,
		})
		local rule = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0, 14),
			Size = UDim2.new(1, -80, 0, 1),
			BackgroundColor3 = T.Stroke,
			BorderSizePixel = 0,
			Parent = head,
		})
		local function fitRule()
			local scale = Window.Scale and Window.Scale.Scale or 1
			rule.Size = UDim2.new(1, -(headText.AbsoluteSize.X / scale + 14), 0, 1)
		end
		headText:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitRule)
		task.defer(fitRule)

		local hero = new("Frame", {
			Size = UDim2.new(1, 0, 0, 92),
			BackgroundColor3 = T.Surface2,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			Parent = root,
		})
		corner(hero)
		stroke(hero)
		new("UIGradient", {
			Rotation = 0,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 0.35),
			}),
			Parent = hero,
		})
		local total = text({
			Position = UDim2.fromOffset(16, 14),
			Size = UDim2.new(1, -32, 0, 34),
			Text = "0",
			TextSize = 30,
			FontFace = F.Bold,
			Parent = hero,
		})
		text({
			Position = UDim2.fromOffset(16, 52),
			Size = UDim2.new(1, -32, 0, 18),
			Text = opts.Tagline or "commands and features, one script, every game.",
			TextSize = 13,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			Parent = hero,
		})
		local badge = new("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 14),
			Size = UDim2.fromOffset(0, 22),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			Parent = hero,
		})
		corner(badge, 11)
		new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = badge })
		text({
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = opts.Badge or "Universal",
			TextSize = 12,
			FontFace = F.Bold,
			TextColor3 = T.Background,
			TextTruncate = Enum.TextTruncate.None,
			Parent = badge,
		})

		local grid = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Parent = root,
		})
		new("UIGridLayout", {
			CellSize = UDim2.new(0.5, -4, 0, 62),
			CellPadding = UDim2.fromOffset(8, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = grid,
		})
		local tiles = {}
		local function tile(i, iconName, label)
			local b =
				new("Frame", { BackgroundColor3 = T.Surface2, BorderSizePixel = 0, LayoutOrder = i, Parent = grid })
			corner(b)
			stroke(b)
			iconLabel(b, iconName, 16, T.Muted, { Position = UDim2.fromOffset(14, 13) })
			text({
				Position = UDim2.fromOffset(36, 12),
				Size = UDim2.new(1, -50, 0, 16),
				Text = label,
				TextSize = 12,
				TextColor3 = T.Muted,
				FontFace = F.Regular,
				Parent = b,
			})
			local v = text({
				Position = UDim2.fromOffset(14, 34),
				Size = UDim2.new(1, -28, 0, 20),
				Text = "0",
				TextSize = 17,
				FontFace = F.Bold,
				Parent = b,
			})
			tiles[i] = v
			return v
		end
		tile(1, "terminal", "Commands")
		tile(2, "sparkles", "Features")
		tile(3, "replace", "Aliases")
		tile(4, "layout-grid", "Tabs")

		local chips = opts.Highlights or {}
		if #chips > 0 then
			local card = new("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = T.Surface2,
				BorderSizePixel = 0,
				LayoutOrder = 4,
				Parent = root,
			})
			corner(card)
			stroke(card)
			new("UIPadding", {
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14),
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 14),
				Parent = card,
			})
			new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
			local top = new(
				"Frame",
				{ Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = 1, Parent = card }
			)
			iconLabel(top, "zap", 14, T.Muted, { Position = UDim2.fromOffset(0, 1) })
			text({
				Position = UDim2.fromOffset(22, 0),
				Size = UDim2.new(1, -22, 1, 0),
				Text = "What's inside",
				TextSize = 12,
				TextColor3 = T.Muted,
				FontFace = F.Regular,
				Parent = top,
			})
			local flow = new("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = 2,
				Parent = card,
			})
			new("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Wraps = true,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = flow,
			})
			for i, name in chips do
				local chip = new("Frame", {
					Size = UDim2.fromOffset(0, 26),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = T.Surface3,
					BorderSizePixel = 0,
					LayoutOrder = i,
					Parent = flow,
				})
				corner(chip, 8)
				new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = chip })
				text({
					Size = UDim2.new(0, 0, 1, 0),
					AutomaticSize = Enum.AutomaticSize.X,
					Text = name,
					TextSize = 12,
					TextTruncate = Enum.TextTruncate.None,
					Parent = chip,
				})
			end
		end

		local shown = { 0, 0, 0, 0, 0 }
		local token = 0
		local function countTo(goal)
			token += 1
			local mine = token
			local from = table.clone(shown)
			local t0 = os.clock()
			local dur = 1.1
			local conn
			conn = RunService.RenderStepped:Connect(function()
				if mine ~= token or not root.Parent then
					conn:Disconnect()
					return
				end
				local a = math.clamp((os.clock() - t0) / dur, 0, 1)
				local e = 1 - (1 - a) ^ 4
				for i = 1, 5 do
					shown[i] = from[i] + (goal[i] - from[i]) * e
				end
				for i = 1, 4 do
					tiles[i].Text = fmt(shown[i])
				end
				total.Text = fmt(shown[5]) .. "+"
				if a >= 1 then
					conn:Disconnect()
				end
			end)
		end

		local api = {}
		function api:Refresh()
			local cmds, aliases = 0, 0
			local reg = type(opts.Commands) == "function" and opts.Commands() or opts.Commands
			if type(reg) == "table" then
				for _, c in reg do
					cmds += 1
					if type(c) == "table" and type(c.aliases) == "table" then
						aliases += #c.aliases
					end
				end
			elseif type(reg) == "number" then
				cmds = reg
			end
			local tabs = 0
			for _, t in Window.Tabs or {} do
				if t ~= tab then
					tabs += 1
				end
			end
			countTo({ cmds, features, aliases, tabs, cmds + features })
		end
		local seen = false
		task.spawn(function()
			while root.Parent do
				local open = Window.CurrentTab == tab and Window.Open ~= false
				if open and not seen then
					api:Refresh()
				end
				seen = open
				task.wait(0.5)
			end
		end)
		api._frame = root
		return api
	end
end
