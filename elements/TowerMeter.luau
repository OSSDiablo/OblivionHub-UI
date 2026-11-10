return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween
	local Players = game:GetService("Players")

	return function(tab, opts)
		opts = opts or {}
		local card = K.card(tab, 176, { Name = "TowerMeter" })

		local col = new("Frame", {
			Position = UDim2.fromOffset(16, 14),
			Size = UDim2.new(0, 40, 1, -28),
			BackgroundColor3 = T.Background,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = card,
		})
		K.corner(col, 8)
		K.stroke(col)
		local stack = new("Frame", {
			Position = UDim2.fromOffset(4, 4),
			Size = UDim2.new(1, -8, 1, -8),
			BackgroundTransparency = 1,
			Parent = col,
		})
		new("UIListLayout", {
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = stack,
		})

		local marker = new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 60, 1, -14),
			Size = UDim2.fromOffset(32, 24),
			BackgroundTransparency = 1,
			Parent = card,
		})
		new("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(8, 2),
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			Parent = marker,
		})
		local face = K.avatar(marker, 22, {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
		})
		K.stroke(face, T.Accent, 0, 1.5)
		K.setAvatar(face, Players.LocalPlayer)

		local info = new("Frame", {
			Position = UDim2.fromOffset(104, 14),
			Size = UDim2.new(1, -118, 1, -28),
			BackgroundTransparency = 1,
			Parent = card,
		})
		K.text({
			Size = UDim2.new(1, 0, 0, 14),
			Text = string.upper(opts.Label or "Climb"),
			TextSize = 11,
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = info,
		})
		local pct = K.text({
			Position = UDim2.fromOffset(0, 14),
			Size = UDim2.new(1, 0, 0, 40),
			Text = "0%",
			TextSize = 34,
			FontFace = F.Bold,
			Parent = info,
		})
		local secText = K.text({
			Position = UDim2.fromOffset(0, 56),
			Size = UDim2.new(1, 0, 0, 18),
			Text = opts.EmptyText or "No tower loaded",
			TextSize = 13,
			TextColor3 = T.Muted,
			Parent = info,
		})
		local subText = K.text({
			Position = UDim2.fromOffset(0, 74),
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
			Size = UDim2.new(1, 0, 0, K.Touch and 30 or 26),
			BackgroundTransparency = 1,
			Parent = info,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = words,
		})
		for i, a in opts.Actions or {} do
			K.word(words, a.Name, a.Callback, { LayoutOrder = i })
		end

		local api = { Frame = card }
		local blocks = {}
		local count = 0
		local painted = false

		function api:SetSections(list)
			for _, b in blocks do
				b:Destroy()
			end
			blocks = {}
			count = #(list or {})
			for i, s in list or {} do
				local c = typeof(s) == "Color3" and s or (type(s) == "table" and s.Color) or T.Surface3
				local b = new("Frame", {
					Size = UDim2.new(1, 0, 1 / math.max(count, 1), -2),
					BackgroundColor3 = c,
					BackgroundTransparency = 0.55,
					BorderSizePixel = 0,
					LayoutOrder = count - i + 1,
					Parent = stack,
				})
				K.corner(b, 3)
				blocks[i] = b
			end
			painted = false
			if count == 0 then
				secText.Text = opts.EmptyText or "No tower loaded"
			end
		end

		function api:SetProgress(f, section, text)
			f = math.clamp(tonumber(f) or 0, 0, 1)
			pct.Text = math.floor(f * 100 + 0.5) .. "%"
			pct.TextColor3 = f >= 0.999 and K.Green or T.Text
			local h = col.AbsoluteSize.Y
			if h < 2 then
				h = 148
			end
			local y = 14 + 4 + (h - 8) * (1 - f)
			tween(marker, { Position = UDim2.fromOffset(60, math.clamp(y, 18, 14 + h - 4)) }, 0.35)
			section = tonumber(section)
			if section ~= painted then
				painted = section
				for i, b in blocks do
					local done = section and i < section
					local here = section and i == section
					tween(b, { BackgroundTransparency = here and 0 or (done and 0.35 or 0.75) }, 0.25)
				end
			end
			if count > 0 then
				secText.Text = section and ("Section " .. section .. " of " .. count) or (count .. " sections")
				secText.TextColor3 = T.Text
			end
			if text then
				subText.Text = text
			end
		end

		function api:Set(d)
			d = d or {}
			if d.Sections then
				api:SetSections(d.Sections)
			end
			api:SetProgress(d.Progress, d.Section, d.Text)
		end

		function api:Destroy()
			card:Destroy()
		end

		api:SetProgress(0)
		return api
	end
end
