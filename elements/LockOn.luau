return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local card = K.card(tab, 80, { Name = "LockOn" })

		local reticle = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(40, 40),
			Size = UDim2.fromOffset(52, 52),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local av = K.avatar(card, 40, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(40, 40),
		})
		local ph = K.icon(av, "crosshair", 16, T.Muted, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})

		local brackets = {}
		for _, c in { { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 } } do
			for _, s in { { 8, 2 }, { 2, 8 } } do
				local b = new("Frame", {
					AnchorPoint = Vector2.new(c[1], c[2]),
					Position = UDim2.fromScale(c[1], c[2]),
					Size = UDim2.fromOffset(s[1], s[2]),
					BackgroundColor3 = T.Muted,
					BorderSizePixel = 0,
					Parent = reticle,
				})
				table.insert(brackets, b)
			end
		end

		local name = K.text({
			Position = UDim2.fromOffset(78, 15),
			Size = UDim2.new(1, -78 - P - 110, 0, 18),
			Text = opts.EmptyText or "No target in FOV",
			TextColor3 = T.Muted,
			Parent = card,
		})
		local sub = K.muted({
			Position = UDim2.fromOffset(78, 33),
			Size = UDim2.new(1, -78 - P, 0, 16),
			Text = opts.EmptyDesc or "Aim near someone to lock on",
			Parent = card,
		})
		local hp = K.bar(card, 4, K.Green, {
			Position = UDim2.fromOffset(78, 58),
			Size = UDim2.new(1, -128, 0, 4),
		})
		local hpText = K.muted({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -P, 0, 52),
			Size = UDim2.fromOffset(32, 16),
			Text = "",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})

		local status = K.status(card, "Off", T.Muted, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -P, 0, P),
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
			status:Set(label or s or "Off", col, s == "Searching")
			if s == state then
				return
			end
			state = s
			for _, b in brackets do
				tween(b, { BackgroundColor3 = s == "Locked" and T.Accent or T.Muted }, 0.2)
			end
			if s == "Locked" then
				reticle.Size = UDim2.fromOffset(64, 64)
				tween(reticle, { Size = UDim2.fromOffset(52, 52) }, 0.35, Enum.EasingStyle.Back)
			else
				tween(reticle, { Size = UDim2.fromOffset(52, 52) }, 0.25)
			end
		end

		local lastSub
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
				else
					ph.Visible = true
					av.Image = ""
					name.Text = opts.EmptyText or "No target in FOV"
					name.TextColor3 = T.Muted
				end
			end
			local s
			if plr then
				s = "@" .. plr.Name
				if tonumber(d.Distance) then
					s ..= ", " .. K.fmt(d.Distance) .. " studs"
				end
			else
				s = opts.EmptyDesc or "Aim near someone to lock on"
			end
			if s ~= lastSub then
				lastSub = s
				sub.Text = s
			end
			if plr and tonumber(d.Health) then
				local mx = tonumber(d.MaxHealth) or 100
				local f = mx > 0 and math.clamp(d.Health / mx, 0, 1) or 0
				hp:Set(f, hpColor(f))
				hpText.Text = tostring(math.floor(d.Health + 0.5))
			else
				hp:Set(0)
				hpText.Text = ""
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
