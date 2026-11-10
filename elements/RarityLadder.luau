return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local card = K.card(tab, nil, { Name = "RarityLadder" })
		K.pad(card, 14, 14, 12, 14)
		new("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = card,
		})

		local head = new("Frame", {
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = card,
		})
		local hx = 0
		if opts.Icon then
			K.icon(head, opts.Icon, 16, T.Muted, { Position = UDim2.new(0, 0, 0.5, -8) })
			hx = 24
		end
		K.text({
			Position = UDim2.fromOffset(hx, 0),
			Size = UDim2.new(1, -hx - 140, 1, 0),
			Text = opts.Name or opts.Title or "Minimum rarity",
			Parent = head,
		})
		local value = K.text({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, 140, 1, 0),
			Text = "",
			FontFace = F.Bold,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = head,
		})

		local spectrum = new("Frame", {
			Size = UDim2.new(1, 0, 0, 4),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = card,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = spectrum,
		})

		local chips = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Parent = card,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Wraps = true,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = chips,
		})
		new("UIPadding", { PaddingBottom = UDim.new(0, 0), Parent = chips })

		local hint = K.text({
			Size = UDim2.new(1, 0, 0, 14),
			Text = opts.Hint or "Tap a rarity, everything at or above it counts",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			LayoutOrder = 4,
			Parent = card,
		})
		if opts.Hint == false then
			hint.Visible = false
		end

		local list, colors, nodes = {}, {}, {}
		local selected = nil
		local api = { Frame = card }
		local save = K.flag(tab, opts, api, "Dropdown")

		local function colorOf(name)
			local c = colors[name]
			if typeof(c) == "Color3" then
				return c
			end
			return T.Accent
		end

		local function indexOf(name)
			for i, n in list do
				if n == name then
					return i
				end
			end
			return nil
		end

		local function paint(instant)
			local si = indexOf(selected) or 1
			local d = instant and 0 or 0.2
			for i, n in list do
				local node = nodes[n]
				if node then
					local c = colorOf(n)
					local lit = i >= si
					local sel = i == si
					tween(node.Btn, {
						BackgroundColor3 = lit and c or T.Surface3,
						BackgroundTransparency = lit and 0.84 or 0,
					}, d)
					tween(node.Stroke, {
						Color = lit and c or T.Stroke,
						Transparency = sel and 0 or (lit and 0.55 or 0),
						Thickness = sel and 1.5 or 1,
					}, d)
					tween(node.Dot, { BackgroundTransparency = lit and 0 or 0.65 }, d)
					tween(node.Label, { TextColor3 = lit and T.Text or T.Muted }, d)
					node.Label.FontFace = sel and F.Bold or F.Medium
					if node.Seg then
						tween(node.Seg, { BackgroundTransparency = lit and 0 or 0.8 }, d)
					end
				end
			end
			value.Text = selected or ""
			value.TextColor3 = selected and colorOf(selected) or T.Muted
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
			for _, node in nodes do
				node.Btn:Destroy()
				if node.Seg then
					node.Seg:Destroy()
				end
			end
			nodes = {}
			local n = #list
			for i, name in list do
				local c = colorOf(name)
				local btn = new("TextButton", {
					Size = UDim2.fromOffset(0, K.Touch and 32 or 28),
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundColor3 = T.Surface3,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Text = "",
					LayoutOrder = i,
					Parent = chips,
				})
				K.corner(btn, UDim.new(1, 0))
				K.pad(btn, 10, 12, 0, 0)
				local s = K.stroke(btn)
				new("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 7),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = btn,
				})
				local dot = new("Frame", {
					Size = UDim2.fromOffset(8, 8),
					BackgroundColor3 = c,
					BorderSizePixel = 0,
					LayoutOrder = 1,
					Parent = btn,
				})
				K.corner(dot, UDim.new(1, 0))
				local label = K.text({
					Size = UDim2.fromScale(0, 1),
					AutomaticSize = Enum.AutomaticSize.X,
					Text = name,
					TextSize = 13,
					TextColor3 = T.Muted,
					TextTruncate = Enum.TextTruncate.None,
					LayoutOrder = 2,
					Parent = btn,
				})
				local seg = new("Frame", {
					Size = UDim2.new(1 / n, -3 * (n - 1) / n, 1, 0),
					BackgroundColor3 = c,
					BackgroundTransparency = 0.8,
					BorderSizePixel = 0,
					LayoutOrder = i,
					Parent = spectrum,
				})
				K.corner(seg, UDim.new(1, 0))
				btn.MouseEnter:Connect(function()
					if name ~= selected then
						tween(s, { Color = c, Transparency = 0.3 }, 0.12)
					end
				end)
				btn.MouseLeave:Connect(function()
					paint(false)
				end)
				btn.MouseButton1Click:Connect(function()
					pick(name, true)
				end)
				nodes[name] = { Btn = btn, Stroke = s, Dot = dot, Label = label, Seg = seg }
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
