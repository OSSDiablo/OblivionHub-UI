return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local card = K.card(tab, nil, { Name = "RarityLadder" })
		K.pad(card, P, P, P, P)
		K.list(card, nil, 12)

		local head, _, right = K.head(card, opts.Icon, opts.Name or opts.Title or "Minimum rarity")
		head.Size = UDim2.new(1, 0, 0, 20)
		head.LayoutOrder = 1
		local meta = K.muted({
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "",
			RichText = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.None,
			Parent = right,
		})

		local cellH = K.Touch and 36 or 32
		local grid = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = card,
		})
		local layout = new("UIGridLayout", {
			CellPadding = UDim2.fromOffset(6, 6),
			CellSize = UDim2.new(0.25, -4.5, 0, cellH),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = grid,
		})
		local function fit()
			local w = grid.AbsoluteSize.X
			local cols = (w > 0 and w < 360) and 3 or 4
			layout.CellSize = UDim2.new(1 / cols, -6 * (cols - 1) / cols, 0, cellH)
		end
		grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
		task.defer(fit)

		local api = { Frame = card }
		local save = K.flag(tab, opts, api, "Dropdown")
		local list, colors, selected = {}, {}, nil
		local nodes = {}

		local function colorOf(name)
			local c = colors[name]
			return typeof(c) == "Color3" and c or T.Accent
		end

		local function indexOf(name)
			return name and table.find(list, name)
		end

		local function paint(instant)
			local si = indexOf(selected) or 1
			local d = instant and 0 or 0.2
			for i, name in list do
				local nd = nodes[name]
				if nd then
					local lit = i >= si
					local sel = i == si
					tween(nd.Stroke, { Color = sel and T.Accent or (nd.Hover and T.StrokeHover or T.Stroke) }, d)
					tween(nd.Dot, { BackgroundTransparency = lit and 0 or 0.75 }, d)
					tween(nd.Label, { TextColor3 = lit and T.Text or T.Muted }, d)
				end
			end
			if selected then
				meta.Text = string.format('<font color="#%s">%s</font> and up', T.Text:ToHex(), selected)
			else
				meta.Text = ""
			end
		end

		local function pick(name, fire)
			if not indexOf(name) then
				return
			end
			local changed = name ~= selected
			selected = name
			paint(false)
			if fire and changed then
				if type(opts.Callback) == "function" then
					task.spawn(opts.Callback, name)
				end
				save()
			end
		end

		local function build()
			for _, nd in nodes do
				nd.Btn:Destroy()
			end
			nodes = {}
			for i, name in list do
				local btn = new("TextButton", {
					BackgroundColor3 = T.Background,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Text = "",
					LayoutOrder = i,
					Parent = grid,
				})
				K.corner(btn, 8)
				local s = K.stroke(btn)
				local dot = new("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 10, 0.5, 0),
					Size = UDim2.fromOffset(6, 6),
					BackgroundColor3 = colorOf(name),
					BorderSizePixel = 0,
					Parent = btn,
				})
				K.corner(dot, UDim.new(1, 0))
				local label = K.text({
					Position = UDim2.fromOffset(24, 0),
					Size = UDim2.new(1, -32, 1, 0),
					Text = name,
					TextSize = 13,
					TextColor3 = T.Muted,
					Parent = btn,
				})
				local nd = { Btn = btn, Stroke = s, Dot = dot, Label = label, Hover = false }
				btn.MouseEnter:Connect(function()
					nd.Hover = true
					paint(false)
				end)
				btn.MouseLeave:Connect(function()
					nd.Hover = false
					paint(false)
				end)
				btn.MouseButton1Click:Connect(function()
					pick(name, true)
				end)
				nodes[name] = nd
			end
			if not indexOf(selected) then
				selected = list[1]
			end
			paint(true)
		end

		function api:SetRarities(l, c)
			list = table.clone(l or {})
			colors = c or colors
			build()
		end

		function api:Set(v)
			if type(v) == "table" then
				v = v[1]
			end
			pick(v, true)
		end

		function api:Get()
			return { selected }
		end

		function api:GetName()
			return selected
		end

		function api:Destroy()
			card:Destroy()
		end

		list = table.clone(opts.Rarities or opts.Options or {})
		colors = opts.Colors or {}
		selected = type(opts.Default) == "table" and opts.Default[1] or opts.Default or opts.CurrentOption
		if type(selected) == "table" then
			selected = selected[1]
		end
		build()
		return api
	end
end
