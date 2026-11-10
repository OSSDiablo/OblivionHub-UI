return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local actions = opts.Actions or {}
		local card = K.card(tab, nil, { Name = "ActionGrid" })
		K.pad(card, P, P, P, P)
		K.list(card, nil, 12)

		local head = new("Frame", {
			Size = UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = card,
		})
		local av, avStroke = K.avatar(head, 32)
		local avIcon = K.icon(av, "user-round", 16, T.Muted, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})
		local name = K.text({
			Position = UDim2.fromOffset(42, -1),
			Size = UDim2.new(1, -42 - 90, 0, 18),
			Text = opts.EmptyText or "No target",
			TextColor3 = T.Muted,
			Parent = head,
		})
		local user = K.muted({
			Position = UDim2.fromOffset(42, 17),
			Size = UDim2.new(1, -42 - 90, 0, 15),
			Text = opts.EmptyDesc or "Pick a player to unlock the actions",
			Parent = head,
		})
		local count = K.status(head, "", T.Accent, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Visible = false,
		})

		local rowsF = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = card,
		})
		K.list(rowsF, nil, 8)

		local n = #actions
		local maxCols = opts.Columns or (K.Touch and 3 or 4)
		local rows = math.max(math.ceil(n / maxCols), 1)
		local perRow = math.ceil(n / rows)
		local tileH = K.Touch and 64 or 56
		local g = 8

		local api = { Frame = card }
		local target = nil
		local tiles = {}

		local function onCount()
			local c = 0
			for _, t in tiles do
				if t.Toggle and t.On then
					c += 1
				end
			end
			count.Frame.Visible = c > 0
			count:Set(c .. " active", T.Accent)
		end

		local function paint(t, d)
			local live = target ~= nil or t.Free
			local on = t.Toggle and t.On
			tween(t.Btn, { BackgroundTransparency = live and 0 or 0.5 }, d)
			tween(t.Stroke, { Color = on and T.Accent or T.Stroke, Transparency = live and 0 or 0.5 }, d)
			tween(t.Icon, {
				ImageColor3 = on and T.Accent or (live and T.Text or T.Muted),
				ImageTransparency = live and 0 or 0.5,
			}, d)
			tween(t.Label, {
				TextColor3 = on and T.Text or T.Muted,
				TextTransparency = live and 0 or 0.5,
			}, d)
		end

		local row
		for i, a in actions do
			local col = (i - 1) % perRow
			if col == 0 then
				row = new("Frame", {
					Size = UDim2.new(1, 0, 0, tileH),
					BackgroundTransparency = 1,
					LayoutOrder = i,
					Parent = rowsF,
				})
			end
			local k = math.min(perRow, n - (i - 1 - col))
			local btn = new("TextButton", {
				Position = UDim2.new(col / k, col * g / k, 0, 0),
				Size = UDim2.new(1 / k, -g * (k - 1) / k, 1, 0),
				BackgroundColor3 = T.Background,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				Parent = row,
			})
			K.corner(btn, 8)
			local s = K.stroke(btn)
			local ic = K.icon(btn, a.Icon or "zap", 18, T.Text, {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, K.Touch and 13 or 10),
			})
			local lb = K.text({
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -8),
				Size = UDim2.new(1, -12, 0, 16),
				Text = a.Name,
				TextSize = 12,
				TextColor3 = T.Muted,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = btn,
			})
			local t = {
				Btn = btn,
				Stroke = s,
				Icon = ic,
				Label = lb,
				Toggle = a.Toggle == true,
				Free = a.NeedsTarget == false,
				On = false,
				Callback = a.Callback,
			}
			tiles[a.Name] = t
			btn.MouseEnter:Connect(function()
				if (target or t.Free) and not t.On then
					tween(s, { Color = T.StrokeHover }, 0.12)
				end
			end)
			btn.MouseLeave:Connect(function()
				paint(t, 0.12)
			end)
			btn.MouseButton1Click:Connect(function()
				if not (target or t.Free) then
					tween(avStroke, { Color = T.Accent }, 0.08)
					task.delay(0.25, function()
						tween(avStroke, { Color = T.Stroke }, 0.3)
					end)
					return
				end
				if t.Toggle then
					t.On = not t.On
					paint(t, 0.18)
					onCount()
					if type(t.Callback) == "function" then
						task.spawn(t.Callback, t.On, target)
					end
				else
					tween(btn, { BackgroundColor3 = T.Surface3 }, 0.06)
					task.delay(0.1, function()
						tween(btn, { BackgroundColor3 = T.Background }, 0.3)
					end)
					if type(t.Callback) == "function" then
						task.spawn(t.Callback, target)
					end
				end
			end)
			paint(t, 0)
		end

		function api:SetTarget(plr)
			if plr == target then
				return
			end
			target = plr
			if plr then
				name.Text = plr.DisplayName
				name.TextColor3 = T.Text
				user.Text = "@" .. plr.Name
				avIcon.Visible = false
				K.setAvatar(av, plr)
			else
				name.Text = opts.EmptyText or "No target"
				name.TextColor3 = T.Muted
				user.Text = opts.EmptyDesc or "Pick a player to unlock the actions"
				av.Image = ""
				avIcon.Visible = true
			end
			for _, t in tiles do
				paint(t, 0.2)
			end
		end

		function api:Set(nm, on)
			local t = tiles[nm]
			if not t or not t.Toggle or t.On == (on == true) then
				return
			end
			t.On = on == true
			paint(t, 0.18)
			onCount()
		end

		function api:Get(nm)
			local t = tiles[nm]
			return t and t.On or false
		end

		function api:GetTarget()
			return target
		end

		function api:Destroy()
			card:Destroy()
		end

		return api
	end
end
