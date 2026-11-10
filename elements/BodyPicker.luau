return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	local SHAPES = {
		Head = { { 21, 0, 22, 22, true } },
		Torso = { { 18, 26, 28, 38 } },
		Arms = { { 5, 27, 10, 36, true }, { 49, 27, 10, 36, true } },
		Legs = { { 19, 67, 12, 41, true }, { 33, 67, 12, 41, true } },
	}
	local DESC = {
		Head = "Best damage, smallest target",
		Torso = "Big and steady, easy hits",
		Arms = "Wide reach on the sides",
		Legs = "Low hits, hard to dodge",
	}

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local parts = opts.Parts or opts.Options or { "Head", "Torso", "Arms", "Legs" }
		local card = K.card(tab, 136, { Name = "BodyPicker" })

		local fig = new("Frame", {
			Position = UDim2.fromOffset(22, P),
			Size = UDim2.fromOffset(64, 108),
			BackgroundTransparency = 1,
			Parent = card,
		})

		local side = new("Frame", {
			Position = UDim2.fromOffset(110, 0),
			Size = UDim2.new(1, -110 - P, 1, 0),
			BackgroundTransparency = 1,
			Parent = card,
		})
		K.list(side, nil, 4, { VerticalAlignment = Enum.VerticalAlignment.Center })
		K.text({
			Size = UDim2.new(1, 0, 0, 18),
			Text = opts.Name or opts.Title or "Hitbox part",
			LayoutOrder = 1,
			Parent = side,
		})
		local desc = K.muted({
			Size = UDim2.new(1, 0, 0, 16),
			Text = "",
			LayoutOrder = 2,
			Parent = side,
		})
		new("Frame", { Size = UDim2.fromOffset(1, 6), BackgroundTransparency = 1, LayoutOrder = 3, Parent = side })
		local seg = K.inset(side, {
			Size = UDim2.new(1, 0, 0, K.Touch and 36 or 32),
			LayoutOrder = 4,
		})
		local inner = new("Frame", {
			Position = UDim2.fromOffset(3, 3),
			Size = UDim2.new(1, -6, 1, -6),
			BackgroundTransparency = 1,
			Parent = seg,
		})
		local n = #parts
		local thumb = new("Frame", {
			Size = UDim2.fromScale(1 / math.max(n, 1), 1),
			BackgroundColor3 = T.Surface3,
			BorderSizePixel = 0,
			Parent = inner,
		})
		K.corner(thumb, 6)
		K.stroke(thumb)

		local api = { Frame = card }
		local save = K.flag(tab, opts, api, "Dropdown")
		local nodes = {}
		local selected

		local function paint(d)
			for name, nd in nodes do
				local on = name == selected
				for _, p in nd.Pieces do
					tween(p.F, { BackgroundColor3 = on and T.Accent or T.Surface3 }, d)
					tween(p.S, { Color = on and T.Accent or (nd.Hover and T.StrokeHover or T.Stroke) }, d)
				end
				if nd.Seg then
					tween(nd.Seg, { TextColor3 = (on or nd.Hover) and T.Text or T.Muted }, d)
				end
			end
			local i = selected and table.find(parts, selected)
			if i then
				tween(thumb, { Position = UDim2.fromScale((i - 1) / n, 0) }, d == 0 and 0 or 0.25)
			end
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

		local function hover(nd, on)
			nd.Hover = on
			paint(0.12)
		end

		for i, name in parts do
			local nd = { Pieces = {}, Hover = false }
			nodes[name] = nd
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
				K.corner(b, r[5] and UDim.new(1, 0) or UDim.new(0, 8))
				local s = K.stroke(b)
				b.MouseEnter:Connect(function()
					hover(nd, true)
				end)
				b.MouseLeave:Connect(function()
					hover(nd, false)
				end)
				b.MouseButton1Click:Connect(function()
					pick(name, true)
				end)
				table.insert(nd.Pieces, { F = b, S = s })
			end
			local sb = new("TextButton", {
				Position = UDim2.fromScale((i - 1) / n, 0),
				Size = UDim2.fromScale(1 / n, 1),
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = name,
				TextColor3 = T.Muted,
				TextSize = 13,
				FontFace = F.Medium,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = inner,
			})
			sb.MouseEnter:Connect(function()
				hover(nd, true)
			end)
			sb.MouseLeave:Connect(function()
				hover(nd, false)
			end)
			sb.MouseButton1Click:Connect(function()
				pick(name, true)
			end)
			nd.Seg = sb
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
