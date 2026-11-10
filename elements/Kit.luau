return function(Lib)
	local TweenService = game:GetService("TweenService")
	local Players = game:GetService("Players")
	local T = Lib.Theme
	local F = Lib.Fonts

	local K = { T = T, F = F, Touch = Lib.Touch == true }
	K.Pad = 14
	K.BtnH = K.Touch and 32 or 28

	function K.new(class, props)
		local o = Instance.new(class)
		for k, v in props do
			if k ~= "Parent" then
				o[k] = v
			end
		end
		o.Parent = props.Parent
		return o
	end
	local new = K.new

	function K.tween(o, p, d, style)
		local tw = TweenService:Create(
			o,
			TweenInfo.new(d or 0.2, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			p
		)
		tw:Play()
		return tw
	end
	local tween = K.tween

	function K.corner(o, r)
		return new("UICorner", {
			CornerRadius = typeof(r) == "UDim" and r or UDim.new(0, r or 10),
			Parent = o,
		})
	end

	function K.stroke(o, col, tr, th)
		local s = new("UIStroke", {
			Color = col or T.Stroke,
			Transparency = tr or 0,
			Thickness = th or 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = o,
		})
		pcall(function()
			s.BorderStrokePosition = Enum.BorderStrokePosition.Inner
		end)
		return s
	end

	function K.text(props)
		props.BackgroundTransparency = 1
		props.FontFace = props.FontFace or F.Medium
		props.TextColor3 = props.TextColor3 or T.Text
		props.TextSize = props.TextSize or 14
		props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
		props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
		props.TextTruncate = props.TextTruncate or Enum.TextTruncate.AtEnd
		return new("TextLabel", props)
	end

	function K.muted(props)
		props.TextSize = props.TextSize or 13
		props.FontFace = props.FontFace or F.Regular
		props.TextColor3 = props.TextColor3 or T.Muted
		return K.text(props)
	end

	function K.pad(o, l, r, t, b)
		return new("UIPadding", {
			PaddingLeft = UDim.new(0, l or 0),
			PaddingRight = UDim.new(0, r or l or 0),
			PaddingTop = UDim.new(0, t or l or 0),
			PaddingBottom = UDim.new(0, b or t or l or 0),
			Parent = o,
		})
	end

	function K.list(parent, dir, gap, props)
		local l = new("UIListLayout", {
			FillDirection = dir or Enum.FillDirection.Vertical,
			Padding = UDim.new(0, gap or 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = parent,
		})
		for k, v in props or {} do
			l[k] = v
		end
		return l
	end

	function K.shade(lo)
		local k = {}
		for i = 0, 8 do
			local t = i / 8
			local v = 1 - (1 - lo / 255) * (t * t * (3 - 2 * t))
			k[#k + 1] = ColorSequenceKeypoint.new(t, Color3.new(v, v, v))
		end
		return ColorSequence.new(k)
	end

	function K.card(tab, h, opts)
		opts = opts or {}
		local f = new("Frame", {
			Name = opts.Name or "Card",
			Size = UDim2.new(1, 0, 0, h or 0),
			AutomaticSize = h and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
			BackgroundColor3 = T.Surface2,
			BorderSizePixel = 0,
			ClipsDescendants = opts.Clip == true,
			LayoutOrder = tab:_nextOrder(),
			Parent = tab.List,
		})
		f:SetAttribute("NoDrag", true)
		K.corner(f, 10)
		new("UIGradient", { Rotation = 90, Color = K.shade(175), Parent = f })
		return f, K.stroke(f)
	end

	function K.inset(parent, props)
		local f = new("Frame", {
			BackgroundColor3 = T.Background,
			BorderSizePixel = 0,
			Parent = parent,
		})
		K.corner(f, 8)
		local s = K.stroke(f)
		for k, v in props or {} do
			f[k] = v
		end
		return f, s
	end

	function K.divider(parent, props)
		local f = new("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = T.Stroke,
			BorderSizePixel = 0,
			Parent = parent,
		})
		for k, v in props or {} do
			f[k] = v
		end
		return f
	end

	function K.mix(a, b, t)
		return a:Lerp(b, t)
	end

	function K.fmt(n)
		n = tonumber(n) or 0
		local s = tostring(math.floor(math.abs(n)))
		s = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
		return (n < 0 and "-" or "") .. s
	end

	function K.short(n)
		n = tonumber(n) or 0
		local a = math.abs(n)
		if a >= 1e9 then
			return (string.format("%.1fB", n / 1e9):gsub("%.0B", "B"))
		elseif a >= 1e6 then
			return (string.format("%.1fM", n / 1e6):gsub("%.0M", "M"))
		elseif a >= 1e4 then
			return (string.format("%.1fK", n / 1e3):gsub("%.0K", "K"))
		end
		return K.fmt(n)
	end

	function K.clock(s)
		s = math.max(0, math.floor(tonumber(s) or 0))
		local h = s // 3600
		local m = (s % 3600) // 60
		if h > 0 then
			return string.format("%d:%02d:%02d", h, m, s % 60)
		end
		return string.format("%d:%02d", m, s % 60)
	end

	local function lucide()
		if Lib._lucide == nil then
			local ok, lib = pcall(function()
				return loadstring(
					game:HttpGet(
						"https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"
					)
				)()
			end)
			Lib._lucide = ok and lib or false
		end
		return Lib._lucide
	end

	function K.setIcon(o, name)
		local icons = lucide()
		local c = icons and (icons.Icons and icons.Icons[name] or icons[name])
		if type(c) == "string" then
			o.Image = c
			o.ImageRectOffset = Vector2.zero
			o.ImageRectSize = Vector2.zero
		elseif type(c) == "table" then
			local img = c.Image
			if type(img) == "number" then
				img = "rbxassetid://" .. img
			end
			o.Image = (icons.Spritesheets and icons.Spritesheets[tostring(img)]) or img
			if c.ImageRectPosition then
				o.ImageRectOffset = c.ImageRectPosition
				o.ImageRectSize = c.ImageRectSize
			end
		end
	end

	function K.icon(parent, name, size, col, props)
		local o = new("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(size, size),
			ImageColor3 = col or T.Muted,
			Parent = parent,
		})
		if name then
			K.setIcon(o, name)
		end
		for k, v in props or {} do
			o[k] = v
		end
		return o
	end

	local thumbs = {}
	function K.avatar(parent, size, props)
		local o = new("ImageLabel", {
			BackgroundColor3 = T.Surface3,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(size, size),
			Image = "",
			Parent = parent,
		})
		K.corner(o, UDim.new(1, 0))
		local s = K.stroke(o)
		for k, v in props or {} do
			o[k] = v
		end
		return o, s
	end

	function K.setAvatar(o, plr)
		local id = typeof(plr) == "Instance" and plr.UserId or tonumber(plr)
		if not id or id <= 0 then
			o.Image = ""
			return
		end
		if thumbs[id] then
			o.Image = thumbs[id]
			return
		end
		o:SetAttribute("Want", id)
		task.spawn(function()
			local ok, url = pcall(function()
				return Players:GetUserThumbnailAsync(id, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
			end)
			if ok and url then
				thumbs[id] = url
				if o:GetAttribute("Want") == id then
					o.Image = url
				end
			end
		end)
	end

	function K.word(parent, label, cb, props)
		local b = new("TextButton", {
			Size = UDim2.fromOffset(0, K.BtnH),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = T.Surface3,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = label,
			TextColor3 = T.Text,
			TextSize = 13,
			FontFace = F.Medium,
			Parent = parent,
		})
		K.corner(b, 8)
		K.pad(b, 12, 12, 0, 0)
		local s = K.stroke(b)
		local function rest()
			return b:GetAttribute("On") and T.Accent or T.Stroke
		end
		b.MouseEnter:Connect(function()
			if b.Active and not b:GetAttribute("On") then
				tween(s, { Color = T.StrokeHover }, 0.12)
			end
		end)
		b.MouseLeave:Connect(function()
			tween(s, { Color = rest() }, 0.12)
		end)
		b.MouseButton1Click:Connect(function()
			if not b.Active then
				return
			end
			tween(b, { BackgroundColor3 = T.Stroke }, 0.06)
			task.delay(0.08, function()
				tween(b, { BackgroundColor3 = T.Surface3 }, 0.2)
			end)
			if cb then
				task.spawn(cb)
			end
		end)
		for k, v in props or {} do
			b[k] = v
		end
		return b, s
	end

	function K.setOn(btn, on)
		btn:SetAttribute("On", on == true)
		local s = btn:FindFirstChildOfClass("UIStroke")
		if s then
			tween(s, { Color = on and T.Accent or T.Stroke }, 0.15)
		end
		tween(btn, { TextColor3 = on and T.Accent or T.Text }, 0.15)
	end

	function K.enable(btn, on)
		btn.Active = on
		btn.AutoButtonColor = false
		tween(btn, { TextColor3 = on and T.Text or T.Muted, BackgroundTransparency = on and 0 or 0.5 }, 0.15)
		local s = btn:FindFirstChildOfClass("UIStroke")
		if s then
			tween(s, { Transparency = on and 0 or 0.5 }, 0.15)
		end
	end

	function K.status(parent, label, col, props)
		local f = new("Frame", {
			Size = UDim2.fromOffset(0, 20),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			Parent = parent,
		})
		K.list(f, Enum.FillDirection.Horizontal, 7, { VerticalAlignment = Enum.VerticalAlignment.Center })
		local box = new("Frame", {
			Size = UDim2.fromOffset(6, 6),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
			Parent = f,
		})
		local ring = new("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = col or T.Muted,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = box,
		})
		K.corner(ring, UDim.new(1, 0))
		local dot = new("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = col or T.Muted,
			BorderSizePixel = 0,
			Parent = box,
		})
		K.corner(dot, UDim.new(1, 0))
		local t = K.text({
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = label or "",
			TextSize = 13,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			TextTruncate = Enum.TextTruncate.None,
			LayoutOrder = 2,
			Parent = f,
		})
		for k, v in props or {} do
			f[k] = v
		end
		local api = { Frame = f, Label = t, Dot = dot }
		local token, pulsing, color = 0, false, nil
		function api.Pulse(_, on, speed)
			on = on == true
			if on == pulsing then
				return
			end
			pulsing = on
			token += 1
			local my = token
			if not on then
				ring.BackgroundTransparency = 1
				return
			end
			speed = speed or 1
			task.spawn(function()
				while f.Parent and token == my do
					ring.Size = UDim2.fromOffset(6, 6)
					ring.BackgroundColor3 = dot.BackgroundColor3
					ring.BackgroundTransparency = 0.45
					tween(
						ring,
						{ Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1 },
						speed,
						Enum.EasingStyle.Quad
					)
					task.wait(speed + 0.15)
				end
			end)
		end
		function api.Set(_, txt, c, pulse)
			if txt and t.Text ~= txt then
				t.Text = txt
			end
			if c and c ~= color then
				color = c
				tween(dot, { BackgroundColor3 = c }, 0.2)
				tween(t, { TextColor3 = c == T.Muted and T.Muted or T.Text }, 0.2)
			end
			if pulse ~= nil then
				api:Pulse(pulse)
			end
		end
		api:Set(nil, col or T.Muted)
		return api
	end
	K.pill = K.status

	function K.bar(parent, h, col, props)
		local track = new("Frame", {
			Size = UDim2.new(1, 0, 0, h or 4),
			BackgroundColor3 = T.Surface3,
			BorderSizePixel = 0,
			Parent = parent,
		})
		K.corner(track, UDim.new(1, 0))
		local fill = new("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = col or T.Accent,
			BorderSizePixel = 0,
			Parent = track,
		})
		K.corner(fill, UDim.new(1, 0))
		for k, v in props or {} do
			track[k] = v
		end
		local api = { Track = track, Fill = fill, Value = 0 }
		function api.Set(_, v, c)
			v = math.clamp(tonumber(v) or 0, 0, 1)
			api.Value = v
			tween(fill, { Size = UDim2.fromScale(v, 1) }, 0.35)
			fill.Visible = v > 0
			if c then
				tween(fill, { BackgroundColor3 = c }, 0.25)
			end
		end
		return api
	end

	function K.segments(parent, n, gap, h, props)
		local f = new("Frame", {
			Size = UDim2.new(1, 0, 0, h or 4),
			BackgroundTransparency = 1,
			Parent = parent,
		})
		for k, v in props or {} do
			f[k] = v
		end
		local cells = {}
		gap = gap or 3
		for i = 1, n do
			local c = new("Frame", {
				Position = UDim2.new((i - 1) / n, (i - 1) * gap / n, 0, 0),
				Size = UDim2.new(1 / n, -gap * (n - 1) / n, 1, 0),
				BackgroundColor3 = T.Surface3,
				BorderSizePixel = 0,
				Parent = f,
			})
			K.corner(c, UDim.new(1, 0))
			cells[i] = c
		end
		return f, cells
	end

	function K.head(card, icon, title, y)
		local row = new("Frame", {
			Name = "Head",
			Position = UDim2.fromOffset(K.Pad, y or K.Pad),
			Size = UDim2.new(1, -K.Pad * 2, 0, 20),
			BackgroundTransparency = 1,
			Parent = card,
		})
		local x = 0
		if icon then
			K.icon(row, icon, 16, T.Muted, { Position = UDim2.new(0, 0, 0.5, -8) })
			x = 24
		end
		local t = K.text({
			Name = "Title",
			Position = UDim2.fromOffset(x, 0),
			Size = UDim2.new(1, -x - 180, 1, 0),
			Text = title or "",
			Parent = row,
		})
		local right = new("Frame", {
			Name = "Right",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, 180, 1, 0),
			BackgroundTransparency = 1,
			Parent = row,
		})
		K.list(right, Enum.FillDirection.Horizontal, 8, {
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		})
		return row, t, right
	end

	function K.flag(tab, opts, api, kind)
		api._type = kind
		local win = tab.Window
		if opts.Flag then
			Lib.Flags[opts.Flag] = api
			if win and win.Flags then
				win.Flags[opts.Flag] = api
			end
		end
		return function()
			if opts.Flag and win and win._autoSave then
				pcall(win._autoSave, win)
			end
		end
	end

	function K.hover(btn, target, on, off)
		btn.MouseEnter:Connect(function()
			tween(target, on, 0.12)
		end)
		btn.MouseLeave:Connect(function()
			tween(target, off, 0.12)
		end)
	end

	K.Red = T.Error or Color3.fromRGB(255, 107, 107)
	K.Amber = T.Warning or Color3.fromRGB(244, 184, 96)
	K.Green = T.Success or Color3.fromRGB(95, 211, 141)
	K.Blue = Color3.fromRGB(96, 165, 250)

	return K
end
