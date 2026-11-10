return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local actions = opts.Actions or {}
		local cols = opts.Columns or (K.Touch and 3 or 4)
		local tileH = K.Touch and 70 or 64

		local card = K.card(tab, nil, { Name = "ActionGrid" })
		K.pad(card, 12, 12, 12, 12)
		new("UIListLayout", {
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = card,
		})

		local head = new("Frame", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = card,
		})
		local av = K.avatar(head, 36)
		local avIcon = K.icon(av, "user-round", 18, T.Muted, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
		})
		local avStroke = K.stroke(av, T.Stroke, 0, 1.5)
		local name = K.text({
			Position = UDim2.fromOffset(46, 0),
			Size = UDim2.new(1, -140, 0, 20),
			Text = opts.EmptyText or "No target",
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = head,
		})
		local user = K.text({
			Position = UDim2.fromOffset(46, 19),
			Size = UDim2.new(1, -140, 0, 16),
			Text = opts.EmptyDesc or "Pick a player to unlock the actions",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			Parent = head,
		})
		local count = K.pill(head, "0 on", T.Muted, {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.fromScale(1, 0.5),
			Visible = false,
		})

		local grid = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
			Parent = card,
		})
		local gap = 8
		new("UIGridLayout", {
			CellSize = UDim2.new(1 / cols, -gap * (cols - 1) / cols, 0, tileH),
			CellPadding = UDim2.fromOffset(gap, gap),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = grid,
		})

		local api = { Frame = card }
		local target = nil
		local tiles = {}

		local function onCount()
			local n = 0
			for _, t in tiles do
				if t.Toggle and t.On then
					n += 1
				end
			end
			count.Frame.Visible = n > 0
			count:Set(n .. " on", T.Accent)
		end

		local function paint(t, d)
			local live = target ~= nil or t.Free
			local on = t.Toggle and t.On
			tween(t.Btn, {
				BackgroundColor3 = on and T.Accent or T.Surface3,
				BackgroundTransparency = on and 0.85 or (live and 0 or 0.45),
			}, d)
			tween(t.Stroke, { Color = on and T.Accent or T.Stroke, Transparency = on and 0.3 or 0 }, d)
			tween(
				t.Icon,
				{ ImageColor3 = on and T.Accent or (live and T.Text or T.Muted), ImageTransparency = live and 0 or 0.5 },
				d
			)
			tween(
				t.Label,
				{ TextColor3 = live and (on and T.Text or T.Muted) or T.Muted, TextTransparency = live and 0 or 0.4 },
				d
			)
			t.Dot.Visible = on
		end

		for i, a in actions do
			local btn = new("TextButton", {
				BackgroundColor3 = T.Surface3,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				LayoutOrder = i,
				Parent = grid,
			})
			K.corner(btn, 10)
			local s = K.stroke(btn)
			local ic = K.icon(btn, a.Icon or "zap", 20, T.Text, {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 13),
			})
			local lb = K.text({
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.new(0.5, 0, 1, -9),
				Size = UDim2.new(1, -10, 0, 16),
				Text = a.Name,
				TextSize = 12,
				TextColor3 = T.Muted,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = btn,
			})
			local dot = new("Frame", {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -8, 0, 8),
				Size = UDim2.fromOffset(6, 6),
				BackgroundColor3 = T.Accent,
				BorderSizePixel = 0,
				Visible = false,
				Parent = btn,
			})
			K.corner(dot, UDim.new(1, 0))
			local t = {
				Btn = btn,
				Stroke = s,
				Icon = ic,
				Label = lb,
				Dot = dot,
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
					tween(btn, { BackgroundColor3 = T.Accent, BackgroundTransparency = 0.7 }, 0.06)
					task.delay(0.1, function()
						paint(t, 0.3)
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
				tween(avStroke, { Color = T.Accent, Transparency = 0.4 }, 0.2)
			else
				name.Text = opts.EmptyText or "No target"
				name.TextColor3 = T.Muted
				user.Text = opts.EmptyDesc or "Pick a player to unlock the actions"
				av.Image = ""
				avIcon.Visible = true
				tween(avStroke, { Color = T.Stroke, Transparency = 0 }, 0.2)
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
