return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween
	local Players = game:GetService("Players")

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local actions = opts.Actions or {}
		local card = K.card(tab, #actions > 0 and (112 + K.BtnH + P) or 114, { Name = "TowerMeter" })

		local _, _, right = K.head(card, "castle", opts.Label or "Climb")
		local pct = K.text({
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "0%",
			FontFace = F.Bold,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTruncate = Enum.TextTruncate.None,
			Parent = right,
		})

		local rail = new("Frame", {
			Position = UDim2.fromOffset(P, 48),
			Size = UDim2.new(1, -P * 2, 0, 22),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local segs = new("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Parent = rail,
		})
		local plain = K.bar(rail, 4, T.Accent, { Position = UDim2.fromOffset(0, 9) })
		local face = K.avatar(rail, 22, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0, 11, 0.5, 0),
		})
		K.setAvatar(face, Players.LocalPlayer)

		local secText = K.text({
			Position = UDim2.fromOffset(P, 82),
			Size = UDim2.new(0.5, -P, 0, 18),
			Text = opts.EmptyText or "No tower loaded",
			TextColor3 = T.Muted,
			Parent = card,
		})
		local subText = K.muted({
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -P, 0, 82),
			Size = UDim2.new(0.5, -P, 0, 18),
			Text = "",
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = card,
		})

		if #actions > 0 then
			local words = new("Frame", {
				Position = UDim2.fromOffset(P, 112),
				Size = UDim2.new(1, -P * 2, 0, K.BtnH),
				BackgroundTransparency = 1,
				Parent = card,
			})
			K.list(words, Enum.FillDirection.Horizontal, 8)
			for i, a in actions do
				K.word(words, a.Name, a.Callback, { LayoutOrder = i })
			end
		end

		local api = { Frame = card }
		local blocks = {}
		local count = 0
		local painted = false

		local function paint(section)
			if section == painted then
				return
			end
			painted = section
			for i, b in blocks do
				local done = section and i < section
				local here = section and i == section
				tween(b, {
					BackgroundColor3 = (done or here) and T.Accent or T.Surface3,
					BackgroundTransparency = done and 0.55 or 0,
				}, 0.25)
			end
		end

		function api:SetSections(list)
			for _, b in blocks do
				b:Destroy()
			end
			blocks = {}
			count = #(list or {})
			local g = 4
			for i = 1, count do
				local b = new("Frame", {
					Position = UDim2.new((i - 1) / count, (i - 1) * g / count, 0, 8),
					Size = UDim2.new(1 / count, -g * (count - 1) / count, 0, 6),
					BackgroundColor3 = T.Surface3,
					BorderSizePixel = 0,
					Parent = segs,
				})
				K.corner(b, UDim.new(1, 0))
				blocks[i] = b
			end
			plain.Track.Visible = count == 0
			painted = false
			if count == 0 then
				secText.Text = opts.EmptyText or "No tower loaded"
				secText.TextColor3 = T.Muted
			end
		end

		function api:SetProgress(f, section, text)
			f = math.clamp(tonumber(f) or 0, 0, 1)
			pct.Text = math.floor(f * 100 + 0.5) .. "%"
			pct.TextColor3 = f >= 0.999 and K.Green or T.Text
			tween(face, { Position = UDim2.new(f, 11 - 22 * f, 0.5, 0) }, 0.35)
			plain:Set(f)
			section = tonumber(section)
			if not section and count > 0 then
				section = math.clamp(math.floor(f * count) + 1, 1, count)
			end
			paint(section)
			if count > 0 then
				secText.Text = "Section " .. section .. " of " .. count
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
