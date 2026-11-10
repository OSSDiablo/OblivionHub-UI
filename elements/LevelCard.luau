return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local card = K.card(tab, 100, { Name = "LevelCard" })

		local left = new("Frame", {
			Position = UDim2.fromOffset(14, 12),
			Size = UDim2.fromOffset(118, 58),
			BackgroundTransparency = 1,
			Parent = card,
		})
		K.text({
			Size = UDim2.new(1, 0, 0, 16),
			Text = string.upper(opts.Label or "Level"),
			TextSize = 11,
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = left,
		})
		local level = K.text({
			Position = UDim2.fromOffset(0, 16),
			Size = UDim2.new(1, 0, 0, 38),
			Text = "0",
			TextSize = 32,
			FontFace = F.Bold,
			Parent = left,
		})
		local bump = K.text({
			Position = UDim2.fromOffset(0, 16),
			Size = UDim2.new(1, 0, 0, 38),
			Text = "",
			TextSize = 14,
			FontFace = F.Bold,
			TextColor3 = T.Accent,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTransparency = 1,
			Parent = left,
		})

		new("Frame", {
			Position = UDim2.fromOffset(140, 16),
			Size = UDim2.fromOffset(1, 48),
			BackgroundColor3 = T.Stroke,
			BorderSizePixel = 0,
			Parent = card,
		})

		local info = new("Frame", {
			Position = UDim2.fromOffset(156, 14),
			Size = UDim2.new(1, -170, 0, 52),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local pill = K.pill(info, "Idle", T.Muted, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
		})
		local title = K.text({
			Size = UDim2.new(1, -96, 0, 22),
			Text = opts.EmptyText or "No quest",
			TextColor3 = T.Muted,
			Parent = info,
		})
		local sub = K.text({
			Position = UDim2.fromOffset(0, 24),
			Size = UDim2.new(1, 0, 0, 18),
			Text = opts.EmptyDesc or "Start the farm to pick a quest",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			Parent = info,
		})

		local bar = K.bar(card, 6, T.Accent, {
			Position = UDim2.new(0, 14, 1, -22),
			Size = UDim2.new(1, -86, 0, 6),
		})
		local ptext = K.text({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 1, -31),
			Size = UDim2.fromOffset(64, 24),
			Text = "",
			TextSize = 12,
			FontFace = F.Medium,
			TextColor3 = T.Muted,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
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
				bump.Text = "+" .. (n - cur)
				bump.Position = UDim2.fromOffset(0, 16)
				bump.TextTransparency = 0
				level.TextColor3 = T.Accent
				tween(level, { TextColor3 = T.Text }, 1.2)
				tween(bump, { Position = UDim2.fromOffset(0, -2), TextTransparency = 1 }, 1.4)
			end
			cur = n
		end

		function api:SetState(txt, col)
			pill:Set(txt or "Idle", col or T.Muted)
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
				sub.Text = d.Sub or ""
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
