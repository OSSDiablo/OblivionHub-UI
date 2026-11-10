return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local card = K.card(tab, 92, { Name = "LockOn" })

		local reticle = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 46, 0.5, 0),
			Size = UDim2.fromOffset(64, 64),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local av = K.avatar(card, 48, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 46, 0.5, 0),
		})
		local ph = K.icon(av, "crosshair", 20, T.Muted, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})
		local avStroke = K.stroke(av, T.Stroke, 0, 1.5)

		local brackets = {}
		for _, c in { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } } do
			local h = new("Frame", {
				AnchorPoint = Vector2.new(c[1], c[2]),
				Position = UDim2.fromScale(c[1], c[2]),
				Size = UDim2.fromOffset(12, 2),
				BackgroundColor3 = T.Muted,
				BorderSizePixel = 0,
				Parent = reticle,
			})
			local v = new("Frame", {
				AnchorPoint = Vector2.new(c[1], c[2]),
				Position = UDim2.fromScale(c[1], c[2]),
				Size = UDim2.fromOffset(2, 12),
				BackgroundColor3 = T.Muted,
				BorderSizePixel = 0,
				Parent = reticle,
			})
			table.insert(brackets, h)
			table.insert(brackets, v)
		end

		local name = K.text({
			Position = UDim2.fromOffset(90, 16),
			Size = UDim2.new(1, -206, 0, 20),
			Text = opts.EmptyText or "No target in FOV",
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = card,
		})
		local sub = K.text({
			Position = UDim2.fromOffset(90, 36),
			Size = UDim2.new(1, -206, 0, 16),
			Text = opts.EmptyDesc or "Aim near someone to lock on",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			Parent = card,
		})
		local hp = K.bar(card, 6, K.Green, {
			Position = UDim2.new(0, 90, 0, 62),
			Size = UDim2.new(1, -206, 0, 6),
		})
		local hpText = K.text({
			Position = UDim2.new(1, -110, 0, 54),
			Size = UDim2.fromOffset(40, 20),
			Text = "",
			TextSize = 12,
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = card,
		})

		local pill = K.pill(card, "Off", T.Muted, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 14),
		})
		local dist = K.text({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 44),
			Size = UDim2.fromOffset(100, 22),
			Text = "",
			TextSize = 18,
			FontFace = F.Bold,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})
		local distSub = K.text({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 64),
			Size = UDim2.fromOffset(100, 14),
			Text = "",
			TextSize = 11,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})

		local api = { Frame = card }
		local target, state, lastLabel = false, nil, nil

		local function hpColor(f)
			if f > 0.5 then
				return K.Amber:Lerp(K.Green, (f - 0.5) * 2)
			end
			return K.Red:Lerp(K.Amber, f * 2)
		end

		function api:SetState(s, label)
			if s == state and label == lastLabel then
				return
			end
			lastLabel = label
			local col = s == "Locked" and T.Accent or (s == "Searching" and K.Amber or T.Muted)
			pill:Set(label or s or "Off", col)
			if s == state then
				return
			end
			state = s
			for _, b in brackets do
				tween(b, { BackgroundColor3 = col }, 0.2)
			end
			tween(avStroke, { Color = s == "Locked" and T.Accent or T.Stroke }, 0.2)
			if s == "Locked" then
				reticle.Size = UDim2.fromOffset(84, 84)
				tween(reticle, { Size = UDim2.fromOffset(64, 64), Rotation = 0 }, 0.35, Enum.EasingStyle.Back)
			else
				tween(reticle, { Size = UDim2.fromOffset(64, 64), Rotation = s == "Searching" and 45 or 0 }, 0.3)
			end
		end

		function api:Set(d)
			d = d or {}
			local plr = d.Target
			if plr ~= target then
				target = plr
				if plr then
					ph.Visible = false
					K.setAvatar(av, plr)
					name.Text = plr.DisplayName
					name.TextColor3 = T.Text
					sub.Text = "@" .. plr.Name
				else
					ph.Visible = true
					av.Image = ""
					name.Text = opts.EmptyText or "No target in FOV"
					name.TextColor3 = T.Muted
					sub.Text = opts.EmptyDesc or "Aim near someone to lock on"
				end
			end
			if plr and tonumber(d.Health) then
				local mx = tonumber(d.MaxHealth) or 100
				local f = mx > 0 and math.clamp(d.Health / mx, 0, 1) or 0
				hp:Set(f, hpColor(f))
				hpText.Text = tostring(math.floor(d.Health + 0.5))
				hpText.TextColor3 = hpColor(f)
			else
				hp:Set(0)
				hpText.Text = ""
			end
			if plr and tonumber(d.Distance) then
				dist.Text = K.fmt(d.Distance)
				distSub.Text = "studs away"
			else
				dist.Text = ""
				distSub.Text = ""
			end
			api:SetState(d.State or (plr and "Locked" or "Searching"), d.Label)
		end

		function api:Get()
			return target or nil
		end

		function api:Destroy()
			card:Destroy()
		end

		api:Set({ State = opts.State or "Off" })
		return api
	end
end
