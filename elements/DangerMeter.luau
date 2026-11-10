return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	local STATES = {
		Safe = { K.Green, "shield-check", 0.15 },
		Hunting = { K.Amber, "eye", 0.6 },
		Run = { K.Red, "triangle-alert", 1 },
		Idle = { nil, "moon", 0 },
	}

	return function(tab, opts)
		opts = opts or {}
		local segs = opts.Segments or 14
		local card = K.card(tab, 104, { Name = "DangerMeter" })

		local badge = new("Frame", {
			Position = UDim2.fromOffset(14, 14),
			Size = UDim2.fromOffset(44, 44),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local ring = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(44, 44),
			BackgroundColor3 = T.Muted,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = badge,
		})
		K.corner(ring, UDim.new(1, 0))
		local disc = new("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = T.Muted,
			BackgroundTransparency = 0.86,
			BorderSizePixel = 0,
			Parent = badge,
		})
		K.corner(disc, UDim.new(1, 0))
		local discStroke = K.stroke(disc, T.Muted, 0.6)
		local icon = K.icon(disc, "moon", 20, T.Muted, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})

		local word = K.text({
			Position = UDim2.fromOffset(70, 14),
			Size = UDim2.new(1, -200, 0, 26),
			Text = "Idle",
			TextSize = 22,
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = card,
		})
		local detail = K.text({
			Position = UDim2.fromOffset(70, 40),
			Size = UDim2.new(1, -200, 0, 18),
			Text = opts.EmptyText or "Not in a run",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			Parent = card,
		})

		local dist = K.text({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 14),
			Size = UDim2.fromOffset(120, 26),
			Text = "",
			TextSize = 20,
			FontFace = F.Bold,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})
		local distSub = K.text({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 40),
			Size = UDim2.fromOffset(120, 18),
			Text = "",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})

		local bar = new("Frame", {
			Position = UDim2.new(0, 14, 1, -28),
			Size = UDim2.new(1, -28, 0, 10),
			BackgroundTransparency = 1,
			Parent = card,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = bar,
		})
		local cells = {}
		for i = 1, segs do
			local c = new("Frame", {
				Size = UDim2.new(1 / segs, -4 * (segs - 1) / segs, 1, 0),
				BackgroundColor3 = T.Surface3,
				BorderSizePixel = 0,
				LayoutOrder = i,
				Parent = bar,
			})
			K.corner(c, 3)
			cells[i] = c
		end

		local function segColor(i)
			local t = (i - 1) / math.max(segs - 1, 1)
			if t < 0.5 then
				return K.Green:Lerp(K.Amber, t * 2)
			end
			return K.Amber:Lerp(K.Red, (t - 0.5) * 2)
		end

		local api = { Frame = card }
		local cur, level, token = nil, 0, 0

		local function startPulse(col, speed)
			token += 1
			local my = token
			task.spawn(function()
				while card.Parent and token == my do
					ring.Size = UDim2.fromOffset(44, 44)
					ring.BackgroundColor3 = col
					ring.BackgroundTransparency = 0.55
					tween(
						ring,
						{ Size = UDim2.fromOffset(72, 72), BackgroundTransparency = 1 },
						speed,
						Enum.EasingStyle.Sine
					)
					task.wait(speed + 0.1)
				end
			end)
		end

		local litNow
		function api:SetLevel(v)
			level = math.clamp(tonumber(v) or 0, 0, 1)
			local lit = math.floor(level * segs + 0.5)
			if lit == litNow then
				return
			end
			litNow = lit
			for i, c in cells do
				local on = i <= lit
				tween(c, { BackgroundColor3 = on and segColor(i) or T.Surface3 }, 0.25)
			end
		end

		function api:Set(d)
			d = d or {}
			local st = STATES[d.State] and d.State or "Idle"
			local spec = STATES[st]
			local col = spec[1] or T.Muted
			if st ~= cur then
				cur = st
				word.Text = d.Label or st
				K.setIcon(icon, spec[2])
				tween(word, { TextColor3 = col }, 0.2)
				tween(icon, { ImageColor3 = col }, 0.2)
				tween(disc, { BackgroundColor3 = col }, 0.2)
				tween(discStroke, { Color = col }, 0.2)
				if st == "Hunting" then
					startPulse(col, 1.2)
				elseif st == "Run" then
					startPulse(col, 0.55)
				else
					token += 1
					ring.BackgroundTransparency = 1
				end
			end
			if d.Label then
				word.Text = d.Label
			end
			detail.Text = d.Text or (st == "Idle" and (opts.EmptyText or "Not in a run") or "")
			if tonumber(d.Distance) then
				dist.Text = K.fmt(d.Distance) .. " studs"
				dist.TextColor3 = col
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
			token += 1
			card:Destroy()
		end

		api:Set({ State = opts.State or "Idle" })
		return api
	end
end
