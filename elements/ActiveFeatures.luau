return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local card = K.card(tab, nil, { Name = "ActiveFeatures" })
		K.pad(card, P, P, P, P)
		K.list(card, nil, 12)

		local head, _, right = K.head(card, "activity", opts.Label or "Session")
		head.Size = UDim2.new(1, 0, 0, 20)
		head.LayoutOrder = 1
		local clock = K.text({
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "0:00",
			FontFace = F.Bold,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.None,
			Parent = right,
		})

		local statRow = new("Frame", {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = card,
		})
		K.list(statRow, Enum.FillDirection.Horizontal, 16, { VerticalAlignment = Enum.VerticalAlignment.Center })
		local statLabels = {}
		for i, s in opts.Stats or { { Name = "Active" } } do
			local nm = type(s) == "table" and s.Name or tostring(s)
			local f = new("Frame", {
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				LayoutOrder = i,
				Parent = statRow,
			})
			K.list(f, Enum.FillDirection.Horizontal, 5, { VerticalAlignment = Enum.VerticalAlignment.Center })
			local v = type(s) == "table" and s.Value
			statLabels[nm] = K.text({
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = v ~= nil and (type(v) == "number" and K.short(v) or tostring(v)) or "0",
				TextTruncate = Enum.TextTruncate.None,
				LayoutOrder = 1,
				Parent = f,
			})
			K.muted({
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = string.lower(nm),
				TextTruncate = Enum.TextTruncate.None,
				LayoutOrder = 2,
				Parent = f,
			})
		end

		K.divider(card, { LayoutOrder = 3 })

		local chips = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 4,
			Parent = card,
		})
		K.list(chips, Enum.FillDirection.Horizontal, 6, { Wraps = true })
		local empty = K.muted({
			Size = UDim2.new(1, 0, 0, 18),
			Text = opts.EmptyText or "Nothing running. Turn a feature on and it shows up here.",
			LayoutOrder = 5,
			Parent = card,
		})

		local api = { Frame = card }
		local items = {}
		local order = 0

		local function chip(name)
			order += 1
			local b = new("TextButton", {
				Size = UDim2.fromOffset(0, K.Touch and 32 or 28),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = T.Background,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				LayoutOrder = order,
				Parent = chips,
			})
			K.corner(b, 8)
			K.pad(b, 10, 8, 0, 0)
			local s = K.stroke(b)
			K.list(b, Enum.FillDirection.Horizontal, 6, { VerticalAlignment = Enum.VerticalAlignment.Center })
			K.text({
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = name,
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.None,
				LayoutOrder = 1,
				Parent = b,
			})
			local x = K.icon(b, "x", 12, T.Muted, { LayoutOrder = 2 })
			b.MouseEnter:Connect(function()
				tween(s, { Color = T.StrokeHover }, 0.12)
				tween(x, { ImageColor3 = T.Text }, 0.12)
			end)
			b.MouseLeave:Connect(function()
				tween(s, { Color = T.Stroke }, 0.12)
				tween(x, { ImageColor3 = T.Muted }, 0.12)
			end)
			b.MouseButton1Click:Connect(function()
				local it = items[name]
				if it and type(it.Off) == "function" then
					task.spawn(it.Off)
				end
			end)
			return b
		end

		function api:SetItems(list)
			local seen = {}
			for _, it in list or {} do
				local nm = type(it) == "table" and it.Name or tostring(it)
				seen[nm] = true
				local cur = items[nm]
				if cur then
					cur.Off = type(it) == "table" and it.Off or nil
				else
					items[nm] = { Off = type(it) == "table" and it.Off or nil, Btn = chip(nm) }
				end
			end
			for nm, it in items do
				if not seen[nm] then
					it.Btn:Destroy()
					items[nm] = nil
				end
			end
			local c = 0
			for _ in items do
				c += 1
			end
			empty.Visible = c == 0
			chips.Visible = c > 0
			if statLabels.Active then
				statLabels.Active.Text = tostring(c)
			end
		end

		function api:SetTime(v)
			clock.Text = type(v) == "number" and K.clock(v) or tostring(v)
		end

		function api:SetStat(name, v)
			local l = statLabels[name]
			if l then
				l.Text = type(v) == "number" and K.short(v) or tostring(v)
			end
		end

		function api:Set(d)
			d = d or {}
			if d.Time ~= nil then
				api:SetTime(d.Time)
			end
			for k, v in d.Stats or {} do
				api:SetStat(k, v)
			end
			if d.Items then
				api:SetItems(d.Items)
			end
		end

		function api:Destroy()
			card:Destroy()
		end

		chips.Visible = false
		return api
	end
end
