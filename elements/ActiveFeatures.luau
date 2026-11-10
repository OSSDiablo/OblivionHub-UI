return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local card = K.card(tab, nil, { Name = "ActiveFeatures" })
		K.pad(card, 14, 14, 12, 14)
		new("UIListLayout", {
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = card,
		})

		local top = new("Frame", {
			Size = UDim2.new(1, 0, 0, 44),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = card,
		})
		K.text({
			Size = UDim2.new(0.5, 0, 0, 14),
			Text = string.upper(opts.Label or "Session"),
			TextSize = 11,
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = top,
		})
		local clock = K.text({
			Position = UDim2.fromOffset(0, 14),
			Size = UDim2.new(0.5, 0, 0, 30),
			Text = "0:00",
			TextSize = 26,
			FontFace = F.Bold,
			Parent = top,
		})

		local stats = new("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0.5, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent = top,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 18),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = stats,
		})
		local statLabels = {}
		for i, s in opts.Stats or { { Name = "Active" } } do
			local col = new("Frame", {
				Size = UDim2.fromOffset(0, 44),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				LayoutOrder = i,
				Parent = stats,
			})
			K.text({
				Size = UDim2.new(0, 0, 0, 14),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = string.upper(s.Name),
				TextSize = 11,
				FontFace = F.Bold,
				TextColor3 = T.Muted,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextTruncate = Enum.TextTruncate.None,
				Parent = col,
			})
			local v = K.text({
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, 0, 0, 14),
				Size = UDim2.new(0, 0, 0, 30),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = tostring(s.Value or 0),
				TextSize = 22,
				FontFace = F.Bold,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextTruncate = Enum.TextTruncate.None,
				Parent = col,
			})
			statLabels[s.Name] = v
		end

		new("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = T.Stroke,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			Parent = card,
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
		local empty = K.text({
			Size = UDim2.new(1, 0, 0, 28),
			Text = opts.EmptyText or "Nothing running. Turn a feature on and it shows up here.",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			LayoutOrder = 0,
			Parent = chips,
		})

		local api = { Frame = card }
		local items = {}
		local order = 0

		local function chip(name, off)
			order += 1
			local b = new("TextButton", {
				Size = UDim2.fromOffset(0, K.Touch and 32 or 28),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = T.Accent,
				BackgroundTransparency = 0.88,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				LayoutOrder = order,
				Parent = chips,
			})
			K.corner(b, UDim.new(1, 0))
			K.pad(b, 10, 8, 0, 0)
			local s = K.stroke(b, T.Accent, 0.55)
			new("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = b,
			})
			local d = new("Frame", {
				Size = UDim2.fromOffset(6, 6),
				BackgroundColor3 = T.Accent,
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Parent = b,
			})
			K.corner(d, UDim.new(1, 0))
			local l = K.text({
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = name,
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.None,
				LayoutOrder = 2,
				Parent = b,
			})
			local x = K.icon(b, "x", 14, T.Muted, { LayoutOrder = 3 })
			b.MouseEnter:Connect(function()
				tween(s, { Color = K.Red, Transparency = 0.2 }, 0.12)
				tween(x, { ImageColor3 = K.Red }, 0.12)
				tween(l, { TextColor3 = K.Red }, 0.12)
			end)
			b.MouseLeave:Connect(function()
				tween(s, { Color = T.Accent, Transparency = 0.55 }, 0.12)
				tween(x, { ImageColor3 = T.Muted }, 0.12)
				tween(l, { TextColor3 = T.Text }, 0.12)
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
			local n = 0
			for _ in items do
				n += 1
			end
			empty.Visible = n == 0
			if statLabels.Active then
				statLabels.Active.Text = tostring(n)
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

		return api
	end
end
