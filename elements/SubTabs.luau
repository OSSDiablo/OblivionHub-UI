return function(Lib)
	local TweenService = game:GetService("TweenService")
	local T = Lib.Theme
	local F = Lib.Fonts
	local touch = Lib.Touch

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
	local function tween(o, p, d)
		TweenService:Create(o, TweenInfo.new(d or 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), p):Play()
	end

	local anchors = {
		Left = { 0, Enum.HorizontalAlignment.Left },
		Center = { 0.5, Enum.HorizontalAlignment.Center },
		Right = { 1, Enum.HorizontalAlignment.Right },
	}

	return function(tab, opts)
		opts = opts or {}
		local names = opts.Tabs or {}
		local align = anchors[opts.Align or "Right"] or anchors.Right
		local h = touch and 36 or 32

		local root = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = tab:_nextOrder(),
			Parent = tab.List,
		})
		root:SetAttribute("NoDrag", true)
		new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = root })

		local row = new("Frame", {
			Size = UDim2.new(1, 0, 0, h),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = root,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = align[2],
			Parent = row,
		})

		local box = new("Frame", {
			Size = UDim2.fromOffset(0, h),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = T.Surface2,
			BorderSizePixel = 0,
			Parent = row,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 10), Parent = box })
		local bs = new("UIStroke", { Color = T.Stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = box })
		pcall(function()
			bs.BorderStrokePosition = Enum.BorderStrokePosition.Inner
		end)
		new("UIPadding", {
			PaddingLeft = UDim.new(0, 3),
			PaddingRight = UDim.new(0, 3),
			PaddingTop = UDim.new(0, 3),
			PaddingBottom = UDim.new(0, 3),
			Parent = box,
		})

		local pill = new("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			ZIndex = 1,
			Parent = box,
		})
		new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = pill })

		local strip = new("Frame", {
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			ZIndex = 2,
			Parent = box,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = strip,
		})

		local api = { Pages = {}, Current = nil, _frame = root }
		local buttons = {}

		local function place(animate)
			local b = buttons[api.Current]
			if not b then
				return
			end
			local x = b.AbsolutePosition.X - strip.AbsolutePosition.X
			local goal = { Position = UDim2.fromOffset(x, 0), Size = UDim2.new(0, b.AbsoluteSize.X, 1, 0) }
			if animate then
				tween(pill, goal)
			else
				pill.Position, pill.Size = goal.Position, goal.Size
			end
		end

		function api:Select(i, silent)
			if type(i) == "string" then
				i = table.find(names, i)
			end
			if not i or not buttons[i] then
				return
			end
			local first = api.Current == nil
			api.Current = i
			for j, b in buttons do
				tween(b, { TextColor3 = j == i and T.Background or T.Muted }, 0.18)
				api.Pages[j].List.Visible = j == i
			end
			place(not first)
			if not silent and opts.Callback then
				task.spawn(opts.Callback, i, names[i])
			end
		end

		for i, name in names do
			local b = new("TextButton", {
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = name,
				TextColor3 = T.Muted,
				TextSize = 13,
				FontFace = F.Medium,
				LayoutOrder = i,
				ZIndex = 3,
				Parent = strip,
			})
			new("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16), Parent = b })
			b.MouseButton1Click:Connect(function()
				if api.Current ~= i then
					api:Select(i)
				end
			end)
			b:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				if api.Current == i then
					place(false)
				end
			end)
			buttons[i] = b

			local list = new("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Visible = false,
				LayoutOrder = 2,
				Parent = root,
			})
			new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })
			local n = 0
			api.Pages[i] = {
				List = list,
				Name = name,
				_nextOrder = function()
					n += 1
					return n
				end,
			}
		end
		api:Select(opts.Default or 1, true)
		task.defer(place, false)

		function api:Destroy()
			root:Destroy()
		end
		return api
	end
end
