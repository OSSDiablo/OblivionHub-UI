return function(Lib)
	local TweenService = game:GetService("TweenService")
	local Players = game:GetService("Players")
	local T = Lib.Theme
	local F = Lib.Fonts

	local K = { T = T, F = F, Touch = Lib.Touch == true }

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
			TweenInfo.new(d or 0.22, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			p
		)
		tw:Play()
		return tw
	end

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

	function K.pad(o, l, r, t, b)
		return new("UIPadding", {
			PaddingLeft = UDim.new(0, l or 0),
			PaddingRight = UDim.new(0, r or l or 0),
			PaddingTop = UDim.new(0, t or l or 0),
			PaddingBottom = UDim.new(0, b or t or l or 0),
			Parent = o,
		})
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
		for k, v in props or {} do
			o[k] = v
		end
		return o
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
		local h = K.Touch and 30 or 26
		local b = new("TextButton", {
			Size = UDim2.fromOffset(0, h),
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
		K.corner(b, 7)
		K.pad(b, 12, 12, 0, 0)
		local s = K.stroke(b)
		b.MouseEnter:Connect(function()
			if b.Active then
				K.tween(s, { Color = T.StrokeHover }, 0.15)
			end
		end)
		b.MouseLeave:Connect(function()
			K.tween(s, { Color = T.Stroke }, 0.15)
		end)
		b.MouseButton1Click:Connect(function()
			if not b.Active then
				return
			end
			K.tween(b, { BackgroundColor3 = T.Stroke }, 0.06)
			task.delay(0.08, function()
				K.tween(b, { BackgroundColor3 = T.Surface3 }, 0.2)
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

	function K.enable(btn, on)
		btn.Active = on
		btn.AutoButtonColor = false
		K.tween(btn, { TextColor3 = on and T.Text or T.Muted, BackgroundTransparency = on and 0 or 0.5 }, 0.15)
	end

	function K.pill(parent, label, col, props)
		local p = new("Frame", {
			Size = UDim2.fromOffset(0, 22),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = col or T.Accent,
			BackgroundTransparency = 0.86,
			BorderSizePixel = 0,
			Parent = parent,
		})
		K.corner(p, UDim.new(1, 0))
		K.pad(p, 9, 9, 0, 0)
		local s = K.stroke(p, col or T.Accent, 0.6)
		local t = K.text({
			Size = UDim2.fromScale(0, 1),
			AutomaticSize = Enum.AutomaticSize.X,
			Text = label,
			TextSize = 12,
			FontFace = F.Bold,
			TextColor3 = col or T.Accent,
			TextTruncate = Enum.TextTruncate.None,
			Parent = p,
		})
		for k, v in props or {} do
			p[k] = v
		end
		local api = { Frame = p, Label = t }
		function api.Set(_, txt, c)
			if txt then
				t.Text = txt
			end
			if c then
				K.tween(p, { BackgroundColor3 = c }, 0.2)
				K.tween(s, { Color = c }, 0.2)
				K.tween(t, { TextColor3 = c }, 0.2)
			end
		end
		return api
	end

	function K.bar(parent, h, col, props)
		local track = new("Frame", {
			Size = UDim2.new(1, 0, 0, h or 6),
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
			K.tween(fill, { Size = UDim2.fromScale(v, 1) }, 0.35)
			if c then
				K.tween(fill, { BackgroundColor3 = c }, 0.25)
			end
		end
		return api
	end

	function K.head(card, icon, title, y)
		local row = new("Frame", {
			Name = "Head",
			Position = UDim2.fromOffset(14, y or 10),
			Size = UDim2.new(1, -28, 0, 24),
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
			Size = UDim2.new(1, -x - 150, 1, 0),
			Text = title or "",
			Parent = row,
		})
		local right = new("Frame", {
			Name = "Right",
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.new(0, 150, 1, 0),
			BackgroundTransparency = 1,
			Parent = row,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = right,
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
			K.tween(target, on, 0.15)
		end)
		btn.MouseLeave:Connect(function()
			K.tween(target, off, 0.15)
		end)
	end

	K.Red = Color3.fromRGB(235, 72, 80)
	K.Amber = Color3.fromRGB(242, 178, 64)
	K.Green = Color3.fromRGB(86, 214, 128)
	K.Blue = Color3.fromRGB(82, 156, 255)

	return K
end
