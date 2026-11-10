return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local range = opts.Range or 290
		local span = opts.Span or range * 1.25
		local goalW = opts.GoalWidth or 24
		local boxD, boxW = opts.BoxDepth or 40, opts.BoxWidth or 90

		local card = K.card(tab, 158, { Name = "GoalMap" })

		local map = new("Frame", {
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.new(1, -196, 1, -24),
			BackgroundColor3 = T.Background,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Parent = card,
		})
		K.corner(map, 8)
		K.stroke(map)
		for i = 0, 7 do
			new("Frame", {
				Position = UDim2.fromScale(i / 8, 0),
				Size = UDim2.fromScale(1 / 16, 1),
				BackgroundColor3 = Color3.new(1, 1, 1),
				BackgroundTransparency = 0.975,
				BorderSizePixel = 0,
				Parent = map,
			})
		end

		local zone = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = K.Red,
			BackgroundTransparency = 0.92,
			BorderSizePixel = 0,
			Parent = map,
		})
		K.corner(zone, UDim.new(1, 0))
		local zoneStroke = K.stroke(zone, K.Red, 0.35)

		local box = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Parent = map,
		})
		K.stroke(box, Color3.new(1, 1, 1), 0.85)

		local goal = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = T.Text,
			BorderSizePixel = 0,
			Parent = map,
		})
		K.corner(goal, 2)
		local corner = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(8, 8),
			BackgroundColor3 = K.Green,
			BorderSizePixel = 0,
			Parent = map,
		})
		K.corner(corner, UDim.new(1, 0))

		local ball = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Visible = false,
			Parent = map,
		})
		K.corner(ball, UDim.new(1, 0))

		local ring = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = T.Accent,
			BackgroundTransparency = 0.6,
			BorderSizePixel = 0,
			Visible = false,
			Parent = map,
		})
		K.corner(ring, UDim.new(1, 0))
		local dot = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(10, 10),
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			Visible = false,
			Parent = map,
		})
		K.corner(dot, UDim.new(1, 0))
		K.stroke(dot, Color3.new(1, 1, 1), 0.2, 1.5)

		local side = new("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 14),
			Size = UDim2.new(0, 158, 1, -28),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local pill = K.pill(side, "Waiting", T.Muted)
		local big = K.text({
			Position = UDim2.fromOffset(0, 34),
			Size = UDim2.new(1, 0, 0, 30),
			Text = "No match",
			TextSize = 24,
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = side,
		})
		local sub = K.text({
			Position = UDim2.fromOffset(0, 64),
			Size = UDim2.new(1, 0, 0, 18),
			Text = "Join a match to see the map",
			TextSize = 12,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			Parent = side,
		})
		local cornerRow = new("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Parent = side,
		})
		local cdot = new("Frame", {
			Position = UDim2.new(0, 0, 0.5, -4),
			Size = UDim2.fromOffset(8, 8),
			BackgroundColor3 = K.Green,
			BorderSizePixel = 0,
			Parent = cornerRow,
		})
		K.corner(cdot, UDim.new(1, 0))
		local ctext = K.text({
			Position = UDim2.fromOffset(16, 0),
			Size = UDim2.new(1, -16, 1, 0),
			Text = "Open corner",
			TextSize = 12,
			FontFace = F.Medium,
			TextColor3 = T.Muted,
			Parent = cornerRow,
		})

		local state = { Live = false, Gap = nil, Side = 1 }
		local inRange = nil

		local function layout()
			local w, h = map.AbsoluteSize.X, map.AbsoluteSize.Y
			if w < 2 then
				return
			end
			local ppx = w / span
			local cy = h / 2
			local r = range * ppx * 2
			zone.Size = UDim2.fromOffset(r, r)
			zone.Position = UDim2.fromOffset(w, cy)
			box.Size = UDim2.fromOffset(boxD * ppx, boxW * ppx)
			box.Position = UDim2.fromOffset(w, cy)
			local gh = math.max(goalW * ppx, 10)
			goal.Size = UDim2.fromOffset(3, gh)
			goal.Position = UDim2.fromOffset(w, cy)
			corner.Position = UDim2.fromOffset(w - 6, cy + state.Side * (gh / 2 - 3))
			local function place(o, v)
				if typeof(v) ~= "Vector2" then
					o.Visible = false
					return
				end
				o.Visible = true
				local x = math.clamp(w - v.X * ppx, 4, w - 4)
				local y = math.clamp(cy + v.Y * ppx, 4, h - 4)
				o.Position = UDim2.fromOffset(x, y)
			end
			place(dot, state.Player)
			place(ring, state.Player)
			place(ball, state.Ball)
		end
		map:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)

		local pulsing = false
		local function pulse()
			if pulsing then
				return
			end
			pulsing = true
			task.spawn(function()
				while card.Parent and ring.Visible do
					ring.Size = UDim2.fromOffset(10, 10)
					ring.BackgroundTransparency = 0.5
					tween(
						ring,
						{ Size = UDim2.fromOffset(26, 26), BackgroundTransparency = 1 },
						1.1,
						Enum.EasingStyle.Sine
					)
					task.wait(1.2)
				end
				pulsing = false
			end)
		end

		local api = { Frame = card }

		function api:Set(d)
			d = d or {}
			state.Live = d.Live == true
			state.Gap = d.Gap
			state.Side = (d.Side == -1) and -1 or 1
			state.Player = d.Player
			state.Ball = d.Ball
			layout()
			if state.Player then
				pulse()
			end

			local ok = state.Live and state.Gap ~= nil and state.Gap <= 0
			if ok ~= inRange then
				inRange = ok
				local c = ok and K.Green or K.Red
				tween(zone, { BackgroundColor3 = c, BackgroundTransparency = ok and 0.86 or 0.92 }, 0.3)
				tween(zoneStroke, { Color = c }, 0.3)
			end

			if not state.Live then
				pill:Set("Waiting", T.Muted)
				big.Text = "No match"
				big.TextColor3 = T.Muted
				sub.Text = d.Text or "Waiting for kickoff"
			elseif ok then
				pill:Set(d.HasBall and "Shoot" or "Get ball", K.Green)
				big.Text = "In range"
				big.TextColor3 = K.Green
				sub.Text = d.Text or (d.HasBall and "Ready to score" or "Grab the ball")
			else
				pill:Set("Live", T.Accent)
				big.Text = state.Gap and (K.fmt(math.ceil(state.Gap)) .. " studs") or "Locating"
				big.TextColor3 = T.Text
				sub.Text = d.Text or "to go before you can shoot"
			end
			ctext.TextColor3 = state.Live and T.Text or T.Muted
			cdot.BackgroundTransparency = state.Live and 0 or 0.6
			corner.Visible = state.Live
		end

		function api:Destroy()
			card:Destroy()
		end

		task.defer(layout)
		api:Set({})
		return api
	end
end
