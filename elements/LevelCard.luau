return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local card = K.card(tab, 112, { Name = "LevelCard" })

		local top = new("Frame", {
			Position = UDim2.fromOffset(P, P),
			Size = UDim2.new(1, -P * 2 - 120, 0, 24),
			BackgroundTransparency = 1,
			Parent = card,
		})
		K.list(top, Enum.FillDirection.Horizontal, 8, { VerticalAlignment = Enum.VerticalAlignment.Bottom })
		K.text({
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = opts.Label or "Level",
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			TextTruncate = Enum.TextTruncate.None,
			LayoutOrder = 1,
			Parent = top,
		})
		local level = K.text({
			Size = UDim2.new(0, 0, 1, 2),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "0",
			TextSize = 20,
			FontFace = F.Bold,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			TextTruncate = Enum.TextTruncate.None,
			LayoutOrder = 2,
			Parent = top,
		})
		local bumpBox = new("Frame", {
			Size = UDim2.new(0, 48, 1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = 3,
			Parent = top,
		})
		local bump = K.text({
			Size = UDim2.fromScale(1, 1),
			Text = "",
			TextSize = 13,
			FontFace = F.Bold,
			TextColor3 = T.Accent,
			TextTransparency = 1,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			Parent = bumpBox,
		})

		local status = K.status(card, "Idle", T.Muted, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -P, 0, 26),
		})

		local title = K.text({
			Position = UDim2.fromOffset(P, 50),
			Size = UDim2.new(1, -P * 2 - 96, 0, 18),
			Text = opts.EmptyText or "No quest",
			TextColor3 = T.Muted,
			Parent = card,
		})
		local ptext = K.muted({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -P, 0, 50),
			Size = UDim2.fromOffset(90, 18),
			Text = "",
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})
		local sub = K.muted({
			Position = UDim2.fromOffset(P, 68),
			Size = UDim2.new(1, -P * 2, 0, 16),
			Text = opts.EmptyDesc or "Start the farm to pick a quest",
			Parent = card,
		})
		local bar = K.bar(card, 4, T.Accent, {
			Position = UDim2.fromOffset(P, 94),
			Size = UDim2.new(1, -P * 2, 0, 4),
		})

		local api = { Frame = card }
		local cur = nil

		function api:SetLevel(n)
			n = tonumber(n)
			if not n then
				return
			end
			level.Text = K.fmt(n)
			if cur and n > cur then
				bump.Text = "+" .. K.fmt(n - cur)
				bump.Position = UDim2.fromOffset(0, 4)
				bump.TextTransparency = 0
				level.TextColor3 = T.Accent
				tween(level, { TextColor3 = T.Text }, 1.2)
				tween(bump, { Position = UDim2.fromOffset(0, -6), TextTransparency = 1 }, 1.4)
			end
			cur = n
		end

		function api:SetState(txt, col)
			local c = col or T.Muted
			status:Set(txt or "Idle", c, c ~= T.Muted)
		end

		function api:Set(d)
			d = d or {}
			if d.Level ~= nil then
				api:SetLevel(d.Level)
			end
			if d.Title ~= nil or d.Sub ~= nil then
				local has = d.Title and d.Title ~= ""
				title.Text = has and d.Title or (opts.EmptyText or "No quest")
				title.TextColor3 = has and T.Text or T.Muted
				sub.Text = d.Sub or (has and "" or (opts.EmptyDesc or "Start the farm to pick a quest"))
			end
			if d.Progress ~= nil then
				bar:Set(d.Progress)
			end
			if d.ProgressText ~= nil then
				ptext.Text = d.ProgressText
			end
			if d.State ~= nil then
				api:SetState(d.State, d.StateColor)
			end
		end

		function api:Destroy()
			card:Destroy()
		end

		api:Set({
			Level = opts.Level,
			Title = opts.Title,
			Sub = opts.Sub,
			Progress = opts.Progress or 0,
			ProgressText = opts.ProgressText or "",
		})
		return api
	end
end
