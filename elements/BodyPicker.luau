return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	local SHAPES = {
		Head = { { 34, 0, 26, 26, true } },
		Torso = { { 28, 30, 38, 46 } },
		Arms = { { 12, 30, 13, 44 }, { 69, 30, 13, 44 } },
		Legs = { { 28, 80, 17, 50 }, { 49, 80, 17, 50 } },
	}
	local DESC = {
		Head = "Best damage, smallest target",
		Torso = "Big and steady, easy hits",
		Arms = "Wide reach on the sides",
		Legs = "Low hits, hard to dodge",
	}

	return function(tab, opts)
		opts = opts or {}
		local parts = opts.Parts or opts.Options or { "Head", "Torso", "Arms", "Legs" }
		local card = K.card(tab, 158, { Name = "BodyPicker" })

		local fig = new("Frame", {
			Position = UDim2.new(0, 22, 0.5, -65),
			Size = UDim2.fromOffset(94, 130),
			BackgroundTransparency = 1,
			Parent = card,
		})

		local info = new("Frame", {
			Position = UDim2.fromOffset(140, 18),
			Size = UDim2.new(1, -154, 1, -36),
			BackgroundTransparency = 1,
			Parent = card,
		})
		K.text({
			Size = UDim2.new(1, 0, 0, 14),
			Text = string.upper(opts.Name or opts.Title or "Hitbox part"),
			TextSize = 11,
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = info,
		})
		local big = K.text({
			Position = UDim2.fromOffset(0, 16),
			Size = UDim2.new(1, 0, 0, 32),
			Text = "",
			TextSize = 28,
			FontFace = F.Bold,
			TextColor3 = T.Accent,
			Parent = info,
		})
		local desc = K.text({
			Position = UDim2.fromOffset(0, 50),
			Size = UDim2.new(1, 0, 0, 16),
			Text = "",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			Parent = info,
		})
		local words = new("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Parent = info,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = words,
		})

		local api = { Frame = card }
		local save = K.flag(tab, opts, api, "Dropdown")
		local nodes = {}
		local selected

		local function paint(d)
			for name, n in nodes do
				local on = name == selected
				for _, p in n.Pieces do
					tween(p.F, {
						BackgroundColor3 = on and T.Accent or T.Surface3,
						BackgroundTransparency = on and 0.15 or (n.Hover and 0 or 0.1),
					}, d)
					tween(p.S, {
						Color = on and T.Glow or (n.Hover and T.StrokeHover or T.Stroke),
						Transparency = on and 0.4 or 0,
					}, d)
				end
				if n.Word then
					tween(n.Word, {
						BackgroundColor3 = on and T.Accent or T.Surface3,
						BackgroundTransparency = on and 0.85 or 0,
						TextColor3 = on and T.Text or T.Muted,
					}, d)
					tween(n.WordStroke, { Color = on and T.Accent or T.Stroke, Transparency = on and 0.4 or 0 }, d)
				end
			end
			big.Text = selected or ""
			desc.Text = (opts.Descriptions and opts.Descriptions[selected]) or DESC[selected] or ""
		end

		local function pick(name, fire)
			if not nodes[name] then
				return
			end
			local changed = name ~= selected
			selected = name
			paint(0.2)
			if fire and changed then
				if type(opts.Callback) == "function" then
					task.spawn(opts.Callback, name)
				end
				save()
			end
		end

		for i, name in parts do
			local n = { Pieces = {}, Hover = false }
			nodes[name] = n
			for _, r in SHAPES[name] or {} do
				local b = new("TextButton", {
					Position = UDim2.fromOffset(r[1], r[2]),
					Size = UDim2.fromOffset(r[3], r[4]),
					BackgroundColor3 = T.Surface3,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Text = "",
					Parent = fig,
				})
				K.corner(b, r[5] and UDim.new(1, 0) or UDim.new(0, 6))
				local s = K.stroke(b)
				b.MouseEnter:Connect(function()
					n.Hover = true
					paint(0.12)
				end)
				b.MouseLeave:Connect(function()
					n.Hover = false
					paint(0.12)
				end)
				b.MouseButton1Click:Connect(function()
					pick(name, true)
				end)
				table.insert(n.Pieces, { F = b, S = s })
			end
			local w, ws = K.word(words, name, function()
				pick(name, true)
			end, { LayoutOrder = i, TextColor3 = T.Muted })
			n.Word, n.WordStroke = w, ws
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

		local def = opts.Default or opts.CurrentOption or parts[1]
		if type(def) == "table" then
			def = def[1]
		end
		selected = nodes[def] and def or parts[1]
		paint(0)
		return api
	end
end
