return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween
	local Players = game:GetService("Players")

	return function(tab, opts)
		opts = opts or {}
		local me = Players.LocalPlayer
		local card = K.card(tab, 122, { Name = "Spectator" })
		local conns = {}

		local function arrow(icon, x)
			local b = new("TextButton", {
				AnchorPoint = Vector2.new(x, 0),
				Position = UDim2.new(x, x == 0 and 12 or -12, 0, 14),
				Size = UDim2.fromOffset(40, 52),
				BackgroundColor3 = T.Surface3,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				Parent = card,
			})
			K.corner(b, 9)
			local s = K.stroke(b)
			local ic = K.icon(b, icon, 18, T.Text, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
			})
			K.hover(b, s, { Color = T.StrokeHover }, { Color = T.Stroke })
			return b, ic
		end
		local prev = arrow("chevron-left", 0)
		local nextB = arrow("chevron-right", 1)

		local mid = new("Frame", {
			Position = UDim2.fromOffset(60, 14),
			Size = UDim2.new(1, -120, 0, 52),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local av = K.avatar(mid, 44, { Position = UDim2.new(0, 6, 0.5, -22) })
		local ph = K.icon(av, "user-round", 18, T.Muted, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})
		local avStroke = K.stroke(av, T.Stroke, 0, 1.5)
		local live = new("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(0, 50, 1, -2),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = K.Red,
			BorderSizePixel = 0,
			Visible = false,
			Parent = mid,
		})
		K.corner(live, UDim.new(1, 0))
		K.stroke(live, T.Surface2, 0, 2)
		local name = K.text({
			Position = UDim2.fromOffset(62, 7),
			Size = UDim2.new(1, -140, 0, 20),
			Text = "No players",
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = mid,
		})
		local user = K.text({
			Position = UDim2.fromOffset(62, 27),
			Size = UDim2.new(1, -140, 0, 16),
			Text = "Nobody else is in this server",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			Parent = mid,
		})
		local idx = K.text({
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(70, 20),
			Text = "",
			TextSize = 12,
			FontFace = F.Medium,
			TextColor3 = T.Muted,
			TextXAlignment = Enum.TextXAlignment.Right,
			Parent = mid,
		})

		local words = new("Frame", {
			Position = UDim2.new(0, 12, 1, -42),
			Size = UDim2.new(1, -24, 0, 30),
			BackgroundTransparency = 1,
			Parent = card,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = words,
		})

		local api = { Frame = card }
		local list, i, cur = {}, 0, nil
		local watching = false
		local specWord

		local function refreshWords()
			if specWord then
				specWord.Text = watching and (opts.StopText or "Stop") or (opts.SpectateText or "Spectate")
				tween(specWord, {
					BackgroundColor3 = watching and K.Red or T.Surface3,
					BackgroundTransparency = watching and 0.82 or 0,
				}, 0.15)
			end
			live.Visible = watching and cur ~= nil
			tween(avStroke, { Color = watching and K.Red or (cur and T.Accent or T.Stroke) }, 0.2)
		end

		local function show()
			if cur then
				ph.Visible = false
				K.setAvatar(av, cur)
				name.Text = cur.DisplayName
				name.TextColor3 = T.Text
				user.Text = "@" .. cur.Name
				idx.Text = i .. " of " .. #list
			else
				ph.Visible = true
				av.Image = ""
				name.Text = "No players"
				name.TextColor3 = T.Muted
				user.Text = "Nobody else is in this server"
				idx.Text = ""
			end
			refreshWords()
		end

		local function choose(p, fire)
			if p == cur then
				return
			end
			cur = p
			show()
			if fire and type(opts.Callback) == "function" then
				task.spawn(opts.Callback, cur)
			end
		end

		local function rebuild()
			list = {}
			for _, p in Players:GetPlayers() do
				if p ~= me then
					table.insert(list, p)
				end
			end
			table.sort(list, function(a, b)
				return a.DisplayName:lower() < b.DisplayName:lower()
			end)
			i = 0
			for n, p in list do
				if p == cur then
					i = n
				end
			end
			if i == 0 then
				i = #list > 0 and 1 or 0
				choose(list[i], true)
			else
				show()
			end
		end

		local function step(d)
			if #list == 0 then
				return
			end
			i = (i - 1 + d) % #list + 1
			choose(list[i], true)
		end

		prev.MouseButton1Click:Connect(function()
			step(-1)
		end)
		nextB.MouseButton1Click:Connect(function()
			step(1)
		end)

		if opts.Spectate then
			specWord = K.word(words, opts.SpectateText or "Spectate", function()
				if not cur and not watching then
					return
				end
				watching = not watching
				refreshWords()
				task.spawn(opts.Spectate, watching, cur)
			end, { LayoutOrder = 0 })
		end
		for n, a in opts.Actions or {} do
			K.word(words, a.Name, function()
				if cur and type(a.Callback) == "function" then
					a.Callback(cur)
				end
			end, { LayoutOrder = n })
		end

		table.insert(conns, Players.PlayerAdded:Connect(rebuild))
		table.insert(
			conns,
			Players.PlayerRemoving:Connect(function(p)
				if p == cur then
					cur = nil
				end
				task.defer(rebuild)
			end)
		)
		card.Destroying:Connect(function()
			for _, c in conns do
				c:Disconnect()
			end
		end)

		function api:Get()
			return cur
		end

		function api:Set(p)
			if typeof(p) == "Instance" and p:IsA("Player") then
				for n, q in list do
					if q == p then
						i = n
					end
				end
				choose(p, true)
			end
		end

		function api:Next()
			step(1)
		end

		function api:Prev()
			step(-1)
		end

		function api:SetSpectating(on)
			watching = on == true
			refreshWords()
		end

		function api:IsSpectating()
			return watching
		end

		function api:Refresh()
			rebuild()
		end

		function api:Destroy()
			card:Destroy()
		end

		rebuild()
		return api
	end
end
