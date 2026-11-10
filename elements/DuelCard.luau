return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween
	local Players = game:GetService("Players")

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local me = Players.LocalPlayer
		local card = K.card(tab, 160, { Name = "DuelCard" })

		local _, _, right = K.head(card, "swords", opts.Title or "Duel")
		local status = K.status(right, "Lobby", T.Muted)

		local meAv = K.avatar(card, 40, { Position = UDim2.fromOffset(P, 46) })
		K.setAvatar(meAv, me)
		K.text({
			Position = UDim2.fromOffset(64, 48),
			Size = UDim2.new(0.5, -96, 0, 18),
			Text = me and me.DisplayName or "You",
			Parent = card,
		})
		local meSub = K.muted({
			Position = UDim2.fromOffset(64, 66),
			Size = UDim2.new(0.5, -96, 0, 16),
			Text = "You",
			Parent = card,
		})

		K.muted({
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 66),
			Size = UDim2.fromOffset(24, 16),
			Text = "vs",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = card,
		})

		local foes = new("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -P, 0, 46),
			Size = UDim2.fromOffset(40, 40),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local slots = {}
		for i = 3, 1, -1 do
			local a, s = K.avatar(foes, 40, {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -(i - 1) * 26, 0, 0),
				Visible = false,
			})
			s.Color = T.Surface2
			s.Thickness = 2
			slots[i] = a
		end
		local ph = K.avatar(foes, 40, { AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0) })
		K.icon(ph, "user-round", 16, T.Muted, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})
		local foeName = K.text({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -(P + 50), 0, 48),
			Size = UDim2.new(0.5, -96, 0, 18),
			Text = "No opponent",
			TextColor3 = T.Muted,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})
		local foeSub = K.muted({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -(P + 50), 0, 66),
			Size = UDim2.new(0.5, -96, 0, 16),
			Text = "",
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})

		local stats = K.inset(card, {
			Position = UDim2.fromOffset(P, 98),
			Size = UDim2.new(1, -P * 2, 0, 48),
		})
		local names = opts.Stats or { "Matches", "Kills", "Deaths" }
		local statLabels = {}
		local n = #names
		for i, nm in names do
			local cell = new("Frame", {
				Position = UDim2.fromScale((i - 1) / n, 0),
				Size = UDim2.fromScale(1 / n, 1),
				BackgroundTransparency = 1,
				Parent = stats,
			})
			statLabels[nm] = K.text({
				Position = UDim2.fromOffset(0, 7),
				Size = UDim2.new(1, 0, 0, 18),
				Text = "0",
				TextSize = 16,
				FontFace = F.Bold,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = cell,
			})
			K.muted({
				Position = UDim2.fromOffset(0, 27),
				Size = UDim2.new(1, 0, 0, 14),
				Text = nm,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = cell,
			})
			if i > 1 then
				K.divider(cell, {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromOffset(1, 24),
				})
			end
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
			local fw = 40 + math.max(math.min(#list, 3) - 1, 0) * 26
			foes.Size = UDim2.fromOffset(fw, 40)
			foeName.Position = UDim2.new(1, -(P + fw + 10), 0, 48)
			foeSub.Position = UDim2.new(1, -(P + fw + 10), 0, 66)
			if #list == 0 then
				foeName.Text = "No opponent"
				foeName.TextColor3 = T.Muted
			else
				foeName.Text = list[1].DisplayName .. (#list > 1 and (" +" .. (#list - 1)) or "")
				foeName.TextColor3 = T.Text
			end
		end

		function api:SetState(s, sub)
			if s ~= cur then
				cur = s
				if s == "Duel" or s == "In duel" then
					status:Set("In duel", T.Accent, true)
				elseif s == "Dead" then
					status:Set("Dead", K.Red, false)
				else
					status:Set(s or "Lobby", T.Muted, false)
				end
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
