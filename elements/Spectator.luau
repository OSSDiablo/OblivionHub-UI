return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween
	local Players = game:GetService("Players")

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local me = Players.LocalPlayer
		local card = K.card(tab, 78 + K.BtnH + P, { Name = "Spectator" })

		local av = K.avatar(card, 40, { Position = UDim2.fromOffset(P, P) })
		local ph = K.icon(av, "user-round", 16, T.Muted, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})
		local name = K.text({
			Position = UDim2.fromOffset(64, 17),
			Size = UDim2.new(1, -64 - P - 110, 0, 18),
			Text = "No players",
			TextColor3 = T.Muted,
			Parent = card,
		})
		local user = K.muted({
			Position = UDim2.fromOffset(64, 35),
			Size = UDim2.new(1, -64 - P - 110, 0, 16),
			Text = "",
			Parent = card,
		})

		local stepper = K.inset(card, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -P, 0, 18),
			Size = UDim2.fromOffset(100, 32),
		})
		local function chevron(icon, x, anchor)
			local b = new("TextButton", {
				AnchorPoint = Vector2.new(anchor, 0),
				Position = UDim2.fromScale(x, 0),
				Size = UDim2.new(0, 28, 1, 0),
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = "",
				Parent = stepper,
			})
			local ic = K.icon(b, icon, 16, T.Muted, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
			})
			K.hover(b, ic, { ImageColor3 = T.Text }, { ImageColor3 = T.Muted })
			return b
		end
		local prev = chevron("chevron-left", 0, 0)
		local nextB = chevron("chevron-right", 1, 1)
		local idx = K.muted({
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.new(0, 44, 1, 0),
			Text = "",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			Parent = stepper,
		})

		K.divider(card, { Position = UDim2.fromOffset(P, 66), Size = UDim2.new(1, -P * 2, 0, 1) })

		local words = new("Frame", {
			Position = UDim2.fromOffset(P, 78),
			Size = UDim2.new(1, -P * 2 - 100, 0, K.BtnH),
			BackgroundTransparency = 1,
			Parent = card,
		})
		K.list(words, Enum.FillDirection.Horizontal, 8)
		local live = K.status(card, "Watching", T.Accent, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -P, 0, 78 + K.BtnH / 2),
			Visible = false,
		})

		local api = { Frame = card }
		local conns = {}
		local list, i, cur = {}, 0, nil
		local watching = false
		local specWord

		local function refreshWords()
			if specWord then
				specWord.Text = watching and (opts.StopText or "Stop") or (opts.SpectateText or "Spectate")
				K.setOn(specWord, watching)
			end
			local on = watching and cur ~= nil
			live.Frame.Visible = on
			live:Pulse(on)
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
				idx.Text = "0 of 0"
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
