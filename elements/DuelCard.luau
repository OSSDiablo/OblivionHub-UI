return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween
	local Players = game:GetService("Players")

	return function(tab, opts)
		opts = opts or {}
		local me = Players.LocalPlayer
		local card = K.card(tab, 168, { Name = "DuelCard" })
		local _, title, right = K.head(card, "swords", opts.Title or "Duel", 10)
		title.FontFace = F.Bold
		local pill = K.pill(right, "Lobby", T.Muted)

		local arena = new("Frame", {
			Position = UDim2.fromOffset(12, 42),
			Size = UDim2.new(1, -24, 0, 66),
			BackgroundTransparency = 1,
			Parent = card,
		})

		local meAv = K.avatar(arena, 48, { Position = UDim2.new(0, 4, 0.5, -24) })
		local meStroke = K.stroke(meAv, T.Accent, 0.3, 2)
		K.setAvatar(meAv, me)
		K.text({
			Position = UDim2.fromOffset(62, 14),
			Size = UDim2.new(0.5, -88, 0, 18),
			Text = me.DisplayName,
			FontFace = F.Bold,
			Parent = arena,
		})
		local meSub = K.text({
			Position = UDim2.fromOffset(62, 32),
			Size = UDim2.new(0.5, -88, 0, 16),
			Text = "You",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			Parent = arena,
		})

		local vs = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(38, 38),
			BackgroundColor3 = T.Surface3,
			BorderSizePixel = 0,
			Parent = arena,
		})
		K.corner(vs, UDim.new(1, 0))
		local vsStroke = K.stroke(vs)
		local vsText = K.text({
			Size = UDim2.fromScale(1, 1),
			Text = "VS",
			TextSize = 13,
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = vs,
		})

		local foes = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -4, 0.5, 0),
			Size = UDim2.fromOffset(120, 48),
			BackgroundTransparency = 1,
			Parent = arena,
		})
		local slots = {}
		for i = 1, 3 do
			local a = K.avatar(foes, 44, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -(i - 1) * 28, 0.5, 0),
				ZIndex = 4 - i,
				Visible = false,
			})
			K.stroke(a, K.Red, 0.35, 2)
			slots[i] = a
		end
		local ph = K.avatar(foes, 44, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
		})
		K.icon(ph, "user-round", 18, T.Muted, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})
		K.stroke(ph, T.Stroke, 0, 1.5)
		local foeName = K.text({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -56, 0, 14),
			Size = UDim2.new(0.5, -86, 0, 18),
			Text = "No opponent",
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = arena,
		})
		local foeSub = K.text({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -56, 0, 32),
			Size = UDim2.new(0.5, -86, 0, 16),
			Text = "Waiting for a match",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = arena,
		})

		local strip = new("Frame", {
			Position = UDim2.new(0, 12, 1, -50),
			Size = UDim2.new(1, -24, 0, 38),
			BackgroundColor3 = T.Surface3,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Parent = card,
		})
		K.corner(strip, 9)
		K.stroke(strip)
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = strip,
		})
		local stats = opts.Stats or { "Matches", "Kills", "Deaths" }
		local statLabels = {}
		for i, name in stats do
			local cell = new("Frame", {
				Size = UDim2.fromScale(1 / #stats, 1),
				BackgroundTransparency = 1,
				LayoutOrder = i,
				Parent = strip,
			})
			if i > 1 then
				new("Frame", {
					Position = UDim2.new(0, 0, 0.5, -9),
					Size = UDim2.fromOffset(1, 18),
					BackgroundColor3 = T.Stroke,
					BorderSizePixel = 0,
					Parent = cell,
				})
			end
			local v = K.text({
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(0.5, -3, 0.5, 0),
				Size = UDim2.new(0.5, -6, 1, 0),
				Text = "0",
				TextSize = 16,
				FontFace = F.Bold,
				TextXAlignment = Enum.TextXAlignment.Right,
				Parent = cell,
			})
			K.text({
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.5, 3, 0.5, 1),
				Size = UDim2.new(0.5, -6, 1, 0),
				Text = name,
				TextSize = 12,
				FontFace = F.Regular,
				TextColor3 = T.Muted,
				Parent = cell,
			})
			statLabels[name] = v
		end

		local api = { Frame = card }
		local last = ""
		local cur

		function api:SetEnemies(list)
			list = list or {}
			local key = {}
			for _, p in list do
				key[#key + 1] = p.UserId
			end
			local k = table.concat(key, ",")
			if k == last then
				return
			end
			last = k
			for i, a in slots do
				local p = list[i]
				a.Visible = p ~= nil
				if p then
					K.setAvatar(a, p)
				end
			end
			ph.Visible = #list == 0
			local fw = 44 + math.max(math.min(#list, 3) - 1, 0) * 28
			foes.Size = UDim2.fromOffset(fw, 48)
			foeName.Position = UDim2.new(1, -(fw + 12), 0, 14)
			foeName.Size = UDim2.new(0.5, -(fw + 42), 0, 18)
			foeSub.Position = UDim2.new(1, -(fw + 12), 0, 32)
			foeSub.Size = UDim2.new(0.5, -(fw + 42), 0, 16)
			if #list == 0 then
				foeName.Text = "No opponent"
				foeName.TextColor3 = T.Muted
			else
				foeName.Text = list[1].DisplayName .. (#list > 1 and ("  +" .. (#list - 1)) or "")
				foeName.TextColor3 = T.Text
			end
		end

		function api:SetState(s, sub)
			if s ~= cur then
				cur = s
				if s == "Duel" or s == "In duel" then
					pill:Set("In duel", T.Accent)
					tween(vsStroke, { Color = T.Accent }, 0.2)
					tween(vsText, { TextColor3 = T.Accent }, 0.2)
				elseif s == "Dead" then
					pill:Set("Dead", K.Red)
					tween(vsStroke, { Color = T.Stroke }, 0.2)
					tween(vsText, { TextColor3 = T.Muted }, 0.2)
				else
					pill:Set(s or "Lobby", T.Muted)
					tween(vsStroke, { Color = T.Stroke }, 0.2)
					tween(vsText, { TextColor3 = T.Muted }, 0.2)
				end
				tween(meStroke, { Transparency = s == "Dead" and 0.85 or 0.3 }, 0.2)
				meAv.ImageTransparency = s == "Dead" and 0.5 or 0
			end
			if sub then
				foeSub.Text = sub
			end
		end

		function api:SetStat(name, v)
			local l = statLabels[name]
			if l and l.Text ~= tostring(v) then
				l.Text = tostring(v)
				l.TextColor3 = T.Accent
				tween(l, { TextColor3 = T.Text }, 0.8)
			end
		end

		function api:Set(d)
			d = d or {}
			if d.Enemies then
				api:SetEnemies(d.Enemies)
			end
			api:SetState(d.State or cur or "Lobby", d.Text)
			if d.You then
				meSub.Text = d.You
			end
			for k, v in d.Stats or {} do
				api:SetStat(k, v)
			end
		end

		function api:Destroy()
			card:Destroy()
		end

		api:SetState("Lobby")
		return api
	end
end
