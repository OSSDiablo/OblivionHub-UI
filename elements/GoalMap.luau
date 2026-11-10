return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local range = opts.Range or 290
		local span = opts.Span or range * 1.25
		local goalW = opts.GoalWidth or 24
		local boxD = opts.BoxDepth or 40
		local boxW = opts.BoxWidth or 90
		local card = K.card(tab, 160, { Name = "GoalMap" })

		local _, _, right = K.head(card, "goal", opts.Title or "Shot range")
		local status = K.status(right, "Waiting", T.Muted)

		local map = K.inset(card, {
			Position = UDim2.fromOffset(P, 46),
			Size = UDim2.new(1, -206, 0, 100),
			ClipsDescendants = true,
		})
		local zone = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = T.Accent,
			BackgroundTransparency = 0.92,
			BorderSizePixel = 0,
			Parent = map,
		})
		K.corner(zone, UDim.new(1, 0))
		local zoneStroke = K.stroke(zone, T.Accent, 0.6)
		local function outline(parent)
			local f = new("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundTransparency = 1,
				Parent = parent,
			})
			K.stroke(f)
			return f
		end
		local box = outline(map)
		local area = outline(map)
		local goal = new("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = T.Text,
			BorderSizePixel = 0,
			Parent = map,
		})
		local corner = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = K.Green,
			BorderSizePixel = 0,
			Visible = false,
			Parent = map,
		})
		K.corner(corner, UDim.new(1, 0))
		local ball = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = T.Text,
			BorderSizePixel = 0,
			Visible = false,
			Parent = map,
		})
		K.corner(ball, UDim.new(1, 0))
		local ring = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(8, 8),
			BackgroundColor3 = T.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Visible = false,
			Parent = map,
		})
		K.corner(ring, UDim.new(1, 0))
		local dot = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(8, 8),
			BackgroundColor3 = T.Accent,
			BorderSizePixel = 0,
			Visible = false,
			Parent = map,
		})
		K.corner(dot, UDim.new(1, 0))

		local side = new("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -P, 0, 46),
			Size = UDim2.fromOffset(166, 100),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local big = K.text({
			Size = UDim2.new(1, 0, 0, 24),
			Text = "No match",
			TextSize = 20,
			FontFace = F.Bold,
			TextColor3 = T.Muted,
			Parent = side,
		})
		local sub = K.muted({
			Position = UDim2.fromOffset(0, 26),
			Size = UDim2.new(1, 0, 0, 34),
			Text = "Waiting for kickoff",
			TextWrapped = true,
			TextTruncate = Enum.TextTruncate.None,
			TextYAlignment = Enum.TextYAlignment.Top,
			Parent = side,
		})
		local mark = K.status(side, "Open corner", T.Muted, {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
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
			box.Position = UDim2.fromOffset(w + 1, cy)
			area.Size = UDim2.fromOffset(boxD * 0.4 * ppx, boxW * 0.45 * ppx)
			area.Position = UDim2.fromOffset(w + 1, cy)
			local gh = math.max(goalW * ppx, 10)
			goal.Size = UDim2.fromOffset(3, gh)
			goal.Position = UDim2.fromOffset(w, cy)
			corner.Position = UDim2.fromOffset(w - 7, cy + state.Side * (gh / 2 - 3))
			local function place(o, v)
				if typeof(v) ~= "Vector2" then
					o.Visible = false
					return
				end
				o.Visible = true
				local x = math.clamp(w - v.X * ppx, 5, w - 5)
				local y = math.clamp(cy + v.Y * ppx, 5, h - 5)
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
					ring.Size = UDim2.fromOffset(8, 8)
					ring.BackgroundTransparency = 0.5
					tween(
						ring,
						{ Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1 },
						1.1,
						Enum.EasingStyle.Quad
					)
					task.wait(1.25)
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
				local c = ok and K.Green or T.Accent
				tween(zone, { BackgroundColor3 = c, BackgroundTransparency = ok and 0.88 or 0.92 }, 0.3)
				tween(zoneStroke, { Color = c, Transparency = ok and 0.4 or 0.6 }, 0.3)
			end
			if not state.Live then
				status:Set("Waiting", T.Muted, false)
				big.Text = "No match"
				big.TextColor3 = T.Muted
				sub.Text = d.Text or "Waiting for kickoff"
			elseif ok then
				status:Set(d.HasBall and "Shoot" or "Get ball", K.Green, true)
				big.Text = "In range"
				big.TextColor3 = T.Text
				sub.Text = d.Text or (d.HasBall and "Ready to score" or "Grab the ball")
			else
				status:Set("Live", T.Accent, true)
				big.Text = state.Gap and (K.fmt(math.ceil(state.Gap)) .. " studs") or "Locating"
				big.TextColor3 = T.Text
				sub.Text = d.Text or "to go before you can shoot"
			end
			mark:Set(nil, state.Live and K.Green or T.Muted)
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
