return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	local STATES = {
		Safe = { K.Green, "shield-check", 0.15, nil },
		Hunting = { K.Amber, "eye", 0.6, 1.2 },
		Run = { K.Red, "triangle-alert", 1, 0.6 },
		Idle = { nil, "moon", 0, nil },
	}

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local segs = opts.Segments or 14
		local card = K.card(tab, 80, { Name = "DangerMeter" })

		local tile = K.inset(card, {
			Position = UDim2.fromOffset(P, P),
			Size = UDim2.fromOffset(36, 36),
		})
		local icon = K.icon(tile, "moon", 18, T.Muted, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})

		local row = new("Frame", {
			Position = UDim2.fromOffset(60, P),
			Size = UDim2.new(1, -60 - 150, 0, 20),
			BackgroundTransparency = 1,
			Parent = card,
		})
		K.list(row, Enum.FillDirection.Horizontal, 8, { VerticalAlignment = Enum.VerticalAlignment.Center })
		local word = K.text({
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "Idle",
			TextTruncate = Enum.TextTruncate.None,
			LayoutOrder = 1,
			Parent = row,
		})
		local pip = K.status(row, "", T.Muted, { LayoutOrder = 2 })
		pip.Label.Visible = false

		local detail = K.muted({
			Position = UDim2.fromOffset(60, 34),
			Size = UDim2.new(1, -60 - 150, 0, 16),
			Text = opts.EmptyText or "Not in a run",
			Parent = card,
		})

		local dist = K.text({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -P, 0, P),
			Size = UDim2.fromOffset(130, 20),
			Text = "",
			FontFace = F.Bold,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})
		local distSub = K.muted({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -P, 0, 34),
			Size = UDim2.fromOffset(130, 16),
			Text = "",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})

		local _, cells = K.segments(card, segs, 3, 4, {
			Position = UDim2.fromOffset(P, 62),
			Size = UDim2.new(1, -P * 2, 0, 4),
		})

		local api = { Frame = card }
		local cur, level, col = nil, 0, T.Muted
		local paintedKey

		function api:SetLevel(v)
			level = math.clamp(tonumber(v) or 0, 0, 1)
			local lit = math.floor(level * segs + 0.5)
			local key = lit .. ":" .. tostring(cur)
			if key == paintedKey then
				return
			end
			paintedKey = key
			for i, c in cells do
				tween(c, { BackgroundColor3 = i <= lit and col or T.Surface3 }, 0.25)
			end
		end

		function api:Set(d)
			d = d or {}
			local st = STATES[d.State] and d.State or "Idle"
			local spec = STATES[st]
			if st ~= cur then
				cur = st
				col = spec[1] or T.Muted
				word.Text = d.Label or st
				word.TextColor3 = st == "Idle" and T.Muted or T.Text
				K.setIcon(icon, spec[2])
				tween(icon, { ImageColor3 = col }, 0.2)
				pip:Set(nil, col)
				pip:Pulse(false)
				if spec[4] then
					pip:Pulse(true, spec[4])
				end
			end
			if d.Label then
				word.Text = d.Label
			end
			detail.Text = d.Text or (st == "Idle" and (opts.EmptyText or "Not in a run") or "")
			if tonumber(d.Distance) then
				dist.Text = K.fmt(d.Distance) .. " studs"
				distSub.Text = d.DistanceText or "nearest creature"
			else
				dist.Text = ""
				distSub.Text = ""
			end
			api:SetLevel(d.Level ~= nil and d.Level or spec[3])
		end

		function api:Get()
			return cur, level
		end

		function api:Destroy()
			card:Destroy()
		end

		api:Set({ State = opts.State or "Idle" })
		return api
	end
end
