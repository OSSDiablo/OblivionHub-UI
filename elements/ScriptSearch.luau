return function(Lib)
	local TweenService = game:GetService("TweenService")
	local T = Lib.Theme
	local F = Lib.Fonts
	local touch = Lib.Touch

	local function new(class, props)
		local o = Instance.new(class)
		for k, v in props do
			if k ~= "Parent" then
				o[k] = v
			end
		end
		o.Parent = props.Parent
		return o
	end
	local function corner(o, r)
		return new("UICorner", { CornerRadius = UDim.new(0, r), Parent = o })
	end
	local function stroke(o, col)
		local s = new("UIStroke", {
			Color = col or T.Stroke,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = o,
		})
		pcall(function()
			s.BorderStrokePosition = Enum.BorderStrokePosition.Inner
		end)
		return s
	end
	local function pad(o, l, r, t, b)
		return new("UIPadding", {
			PaddingLeft = UDim.new(0, l),
			PaddingRight = UDim.new(0, r or l),
			PaddingTop = UDim.new(0, t or l),
			PaddingBottom = UDim.new(0, b or t or l),
			Parent = o,
		})
	end
	local function shade(o)
		local k = {}
		for i = 0, 8 do
			local t = i / 8
			local v = 1 - (1 - 175 / 255) * (t * t * (3 - 2 * t))
			k[#k + 1] = ColorSequenceKeypoint.new(t, Color3.new(v, v, v))
		end
		new("UIGradient", { Rotation = 90, Color = ColorSequence.new(k), Parent = o })
	end
	local function text(props)
		props.BackgroundTransparency = 1
		props.FontFace = props.FontFace or F.Regular
		props.TextColor3 = props.TextColor3 or T.Text
		props.TextSize = props.TextSize or 14
		props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
		props.TextTruncate = props.TextTruncate or Enum.TextTruncate.AtEnd
		return new("TextLabel", props)
	end
	local function tween(o, p, d)
		TweenService:Create(o, TweenInfo.new(d or 0.15, Enum.EasingStyle.Quad), p):Play()
	end
	local function hover(btn, base, over)
		btn.MouseEnter:Connect(function()
			tween(btn, { BackgroundColor3 = over })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, { BackgroundColor3 = base })
		end)
	end

	local icons
	local function icon(name)
		if icons == nil then
			local ok, lib = pcall(function()
				return loadstring(
					game:HttpGet(
						"https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"
					)
				)()
			end)
			icons = ok and lib or false
		end
		local c = icons and (icons.Icons and icons.Icons[name] or icons[name])
		if type(c) == "string" then
			return c
		end
		if type(c) ~= "table" then
			return nil
		end
		local img = c.Image
		if type(img) == "number" then
			img = "rbxassetid://" .. img
		end
		return (icons.Spritesheets and icons.Spritesheets[tostring(img)]) or img, c.ImageRectPosition, c.ImageRectSize
	end
	local function iconLabel(parent, name, size, col, props)
		local img, off, sz = icon(name)
		local o = new("ImageLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(size, size),
			Image = img or "",
			ImageColor3 = col or T.Muted,
			Parent = parent,
		})
		if off then
			o.ImageRectOffset = off
			o.ImageRectSize = sz
		end
		for k, v in props or {} do
			o[k] = v
		end
		return o
	end

	local universes = {}
	local function universe(placeId)
		local key = tostring(placeId)
		if universes[key] == nil then
			universes[key] = "pending"
			local ok, d = pcall(function()
				return game:GetService("HttpService")
					:JSONDecode(game:HttpGet("https://apis.roblox.com/universes/v1/places/" .. key .. "/universe"))
			end)
			universes[key] = ok and type(d) == "table" and d.universeId or false
		end
		while universes[key] == "pending" do
			task.wait()
		end
		return universes[key] or nil
	end

	local thumbs = {}
	local canFile = type(writefile) == "function" and type(isfile) == "function" and type(getcustomasset) == "function"
	local function thumbFor(uid)
		local key = tostring(uid)
		local fallback = "rbxthumb://type=GameIcon&id=" .. key .. "&w=150&h=150"
		if not canFile then
			return fallback
		end
		if thumbs[key] == nil then
			thumbs[key] = "pending"
			local ok, asset = pcall(function()
				local path = "oblivion_thumbs/" .. key .. ".png"
				if not isfile(path) then
					local d = game:GetService("HttpService"):JSONDecode(
						game:HttpGet(
							"https://thumbnails.roblox.com/v1/games/icons?universeIds="
								.. key
								.. "&size=150x150&format=Png&isCircular=false"
						)
					)
					local url = d.data and d.data[1] and d.data[1].imageUrl
					if type(url) ~= "string" or url == "" then
						error("no icon")
					end
					local bytes = game:HttpGet(url)
					if #bytes < 64 then
						error("bad icon")
					end
					if type(makefolder) == "function" and not (isfolder and isfolder("oblivion_thumbs")) then
						makefolder("oblivion_thumbs")
					end
					writefile(path, bytes)
				end
				return getcustomasset(path)
			end)
			thumbs[key] = ok and asset or fallback
		end
		while thumbs[key] == "pending" do
			task.wait()
		end
		return thumbs[key]
	end

	local function short(n)
		n = tonumber(n) or 0
		if n >= 1e6 then
			return ("%.1fM"):format(n / 1e6):gsub("%.0M", "M")
		elseif n >= 1e3 then
			return ("%.1fK"):format(n / 1e3):gsub("%.0K", "K")
		end
		return tostring(math.floor(n))
	end

	return function(tab, opts)
		opts = opts or {}
		local state = {
			q = "",
			source = opts.Source or "All",
			sort = opts.Sort or "Recent",
			here = opts.Mode == "game",
			keyless = false,
			verified = false,
		}
		local order = function()
			return tab:_nextOrder()
		end

		local root = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = order(),
			Parent = tab.List,
		})
		root:SetAttribute("NoDrag", true)
		new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = root })

		local box, go
		if opts.Mode ~= "game" then
			local barH = touch and 44 or 40
			local bar = new("Frame", {
				Size = UDim2.new(1, 0, 0, barH),
				BackgroundColor3 = T.Surface2,
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Parent = root,
			})
			corner(bar, 10)
			shade(bar)
			local barStroke = stroke(bar)
			iconLabel(bar, "search", 16, T.Muted, {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 12, 0.5, 0),
			})
			box = new("TextBox", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(36, 0),
				Size = UDim2.new(1, -36 - 76, 1, 0),
				ClearTextOnFocus = false,
				PlaceholderText = opts.Placeholder or "Game or script name",
				PlaceholderColor3 = T.Muted,
				Text = "",
				TextColor3 = T.Text,
				TextSize = 14,
				FontFace = F.Regular,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = bar,
			})
			go = new("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -6, 0.5, 0),
				Size = UDim2.new(0, 64, 1, -12),
				BackgroundColor3 = T.Accent,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "Search",
				TextColor3 = T.Background,
				TextSize = 13,
				FontFace = F.Bold,
				Parent = bar,
			})
			corner(go, 7)
			box.Focused:Connect(function()
				tween(barStroke, { Color = T.Accent })
			end)
			box.FocusLost:Connect(function()
				tween(barStroke, { Color = T.Stroke })
			end)
		end

		local function chipRow(lo)
			local row = new("ScrollingFrame", {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 0,
				ScrollingDirection = Enum.ScrollingDirection.X,
				AutomaticCanvasSize = Enum.AutomaticSize.X,
				CanvasSize = UDim2.new(),
				LayoutOrder = lo,
				Parent = root,
			})
			new("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Parent = row,
			})
			return row
		end
		local function chip(parent, label, lo)
			local b = new("TextButton", {
				Size = UDim2.fromOffset(0, 26),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = T.Surface2,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = label,
				TextColor3 = T.Muted,
				TextSize = 13,
				FontFace = F.Medium,
				LayoutOrder = lo,
				Parent = parent,
			})
			corner(b, 13)
			pad(b, 11, 11, 0, 0)
			local s = stroke(b)
			local api = { on = false }
			function api.set(on)
				api.on = on
				tween(
					b,
					{ BackgroundColor3 = on and T.Accent or T.Surface2, TextColor3 = on and T.Background or T.Muted }
				)
				tween(s, { Transparency = on and 1 or 0 })
			end
			api.button = b
			return api
		end

		local search
		local function group(row, key, list, lo0)
			local chips = {}
			for i, name in list do
				local c = chip(row, name, (lo0 or 0) + i)
				chips[name] = c
				c.set(state[key] == name)
				c.button.MouseButton1Click:Connect(function()
					if state[key] == name then
						return
					end
					state[key] = name
					for n, other in chips do
						other.set(n == name)
					end
					search(1)
				end)
			end
		end
		local function flag(row, key, label, lo)
			local c = chip(row, label, lo)
			c.button.MouseButton1Click:Connect(function()
				state[key] = not state[key]
				c.set(state[key])
				search(1)
			end)
		end
		local r1 = chipRow(2)
		group(r1, "source", { "All", "ScriptBlox", "rscripts" })
		local sep = new("Frame", {
			Size = UDim2.fromOffset(1, 16),
			BackgroundColor3 = T.Stroke,
			BorderSizePixel = 0,
			LayoutOrder = 10,
			Parent = r1,
		})
		sep.Name = "Sep"
		group(r1, "sort", { "Recent", "Popular", "Top rated" }, 10)
		local r2 = chipRow(3)
		flag(r2, "keyless", "Keyless", 2)
		flag(r2, "verified", "Verified", 3)

		local status = text({
			Size = UDim2.new(1, 0, 0, 16),
			Text = "",
			TextSize = 12,
			TextColor3 = T.Muted,
			LayoutOrder = 4,
			Parent = root,
		})
		pad(status, 2, 2, 0, 0)

		local list = new("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 5,
			Parent = root,
		})
		new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

		local function empty(title, body)
			local f = new("Frame", {
				Size = UDim2.new(1, 0, 0, 92),
				BackgroundColor3 = T.Surface,
				BorderSizePixel = 0,
				LayoutOrder = 0,
				Parent = list,
			})
			corner(f, 10)
			stroke(f)
			iconLabel(f, "file-code", 22, T.Muted, {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 16),
			})
			text({
				Size = UDim2.new(1, -24, 0, 18),
				Position = UDim2.fromOffset(12, 44),
				Text = title,
				FontFace = F.Medium,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = f,
			})
			text({
				Size = UDim2.new(1, -24, 0, 16),
				Position = UDim2.fromOffset(12, 64),
				Text = body,
				TextSize = 12,
				TextColor3 = T.Muted,
				TextXAlignment = Enum.TextXAlignment.Center,
				Parent = f,
			})
			return f
		end

		local function pill(parent, label, strong, lo)
			local p = new("TextLabel", {
				Size = UDim2.fromOffset(0, 18),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = strong and T.AccentDark or T.Surface3,
				BorderSizePixel = 0,
				Text = label,
				TextColor3 = strong and T.Accent or T.Muted,
				TextSize = 11,
				FontFace = F.Medium,
				LayoutOrder = lo,
				Parent = parent,
			})
			corner(p, 5)
			pad(p, 6, 6, 0, 0)
			return p
		end

		local function actionButton(parent, label, primary, xOff)
			local base = primary and T.Accent or T.Surface3
			local b = new("TextButton", {
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, xOff, 1, -10),
				Size = UDim2.fromOffset(primary and 62 or 56, 26),
				BackgroundColor3 = base,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = label,
				TextColor3 = primary and T.Background or T.Text,
				TextSize = 12,
				FontFace = F.Bold,
				Parent = parent,
			})
			corner(b, 7)
			if not primary then
				hover(b, base, T.Stroke)
			end
			return b
		end

		local cards, moreBtn, emptyF = {}, nil, nil
		local function card(item, lo)
			local h = 84
			local f = new("Frame", {
				Size = UDim2.new(1, 0, 0, h),
				BackgroundColor3 = T.Surface2,
				BorderSizePixel = 0,
				LayoutOrder = lo,
				Parent = list,
			})
			corner(f, 10)
			shade(f)
			local s = stroke(f)
			local thumb = new("Frame", {
				Position = UDim2.fromOffset(10, 10),
				Size = UDim2.fromOffset(64, 64),
				BackgroundColor3 = T.Surface3,
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Parent = f,
			})
			corner(thumb, 8)
			if item.placeId and tonumber(item.placeId) and tonumber(item.placeId) > 0 then
				local img = new("ImageLabel", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					ImageTransparency = 1,
					ScaleType = Enum.ScaleType.Crop,
					Parent = thumb,
				})
				img:SetAttribute("OblivionNoTheme", true)
				corner(img, 8)
				task.spawn(function()
					local uid = universe(item.placeId)
					if uid and img.Parent then
						img.Image = thumbFor(uid)
						if img.Parent then
							tween(img, { ImageTransparency = 0 })
						end
					end
				end)
			else
				iconLabel(thumb, "globe", 24, T.Muted, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
				})
			end
			local x = 84
			text({
				Position = UDim2.fromOffset(x, 10),
				Size = UDim2.new(1, -x - 10, 0, 18),
				Text = item.title,
				FontFace = F.Bold,
				Parent = f,
			})
			local meta = { item.game ~= "" and item.game or "Universal", short(item.views) .. " views" }
			text({
				Position = UDim2.fromOffset(x, 29),
				Size = UDim2.new(1, -x - 10, 0, 15),
				Text = table.concat(meta, "  ·  "),
				TextSize = 12,
				TextColor3 = T.Muted,
				Parent = f,
			})
			local tags = new("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				Position = UDim2.new(0, x, 1, -14),
				Size = UDim2.new(1, -x - 140, 0, 18),
				BackgroundTransparency = 1,
				ClipsDescendants = true,
				Parent = f,
			})
			new("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = tags,
			})
			pill(tags, item.keyless and "Keyless" or "Key", item.keyless, 1)
			if item.verified then
				pill(tags, "Verified", true, 2)
			end
			pill(tags, item.source, false, 3)

			local run = actionButton(f, "Run", true, -10)
			local copy = actionButton(f, "Copy", false, -78)
			local busy = false
			run.MouseButton1Click:Connect(function()
				if busy or not opts.Run then
					return
				end
				busy = true
				run.Text = "..."
				task.spawn(function()
					local ok, res = pcall(opts.Run, item)
					local good = ok and res ~= false
					run.Text = good and "Ran" or "Failed"
					tween(s, { Color = good and T.Accent or T.StrokeHover })
					task.wait(1.6)
					run.Text = "Run"
					tween(s, { Color = T.Stroke })
					busy = false
				end)
			end)
			copy.MouseButton1Click:Connect(function()
				local line = item.url and ('loadstring(game:HttpGet("' .. item.url .. '"))()') or item.code or ""
				local clip = setclipboard or toclipboard
				if clip then
					pcall(clip, line)
					copy.Text = "Copied"
					task.delay(1.4, function()
						copy.Text = "Copy"
					end)
				end
			end)
			f.MouseEnter:Connect(function()
				tween(s, { Color = T.StrokeHover })
			end)
			f.MouseLeave:Connect(function()
				if not busy then
					tween(s, { Color = T.Stroke })
				end
			end)
			return f
		end

		local page, busy, gen = 1, false, 0
		local function clearAll()
			for _, c in cards do
				c:Destroy()
			end
			cards = {}
			if moreBtn then
				moreBtn:Destroy()
				moreBtn = nil
			end
			if emptyF then
				emptyF:Destroy()
				emptyF = nil
			end
		end
		local function more()
			local b = new("TextButton", {
				Size = UDim2.new(1, 0, 0, 34),
				BackgroundColor3 = T.Surface2,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "Load more",
				TextColor3 = T.Text,
				TextSize = 13,
				FontFace = F.Medium,
				LayoutOrder = 100000,
				Parent = list,
			})
			corner(b, 10)
			stroke(b)
			hover(b, T.Surface2, T.Surface3)
			b.MouseButton1Click:Connect(function()
				search(page + 1)
			end)
			return b
		end

		search = function(p)
			if not opts.Fetch then
				return
			end
			p = p or 1
			if busy and p ~= 1 then
				return
			end
			gen += 1
			local my = gen
			busy = true
			page = p
			if p == 1 then
				clearAll()
			elseif moreBtn then
				moreBtn.Text = "Loading"
			end
			status.Text = "Searching"
			task.spawn(function()
				local ok, items, hasMore = pcall(opts.Fetch, table.clone(state), p)
				if my ~= gen then
					return
				end
				busy = false
				if moreBtn then
					moreBtn:Destroy()
					moreBtn = nil
				end
				if not ok then
					status.Text = "Search failed"
					if p == 1 then
						emptyF = empty("Could not reach the sites", "Try again in a moment")
					end
					return
				end
				local shown = 0
				for _, item in items or {} do
					if (not state.keyless or item.keyless) and (not state.verified or item.verified) then
						cards[#cards + 1] = card(item, #cards + 1)
						shown += 1
					end
				end
				if #cards == 0 then
					status.Text = ""
					emptyF = empty("Nothing found", "Try another name or turn off a filter")
				else
					status.Text = #cards .. " scripts"
				end
				if hasMore then
					moreBtn = more()
				end
			end)
		end

		if box then
			go.MouseButton1Click:Connect(function()
				state.q = box.Text
				search(1)
			end)
			box.FocusLost:Connect(function(enter)
				if enter then
					state.q = box.Text
					search(1)
				end
			end)
		end

		emptyF = opts.Mode == "game" and empty("Scripts for this game", "Loading the list")
			or empty("Find a script", "Type a name, or press Search for the newest")

		task.defer(function()
			local scroller = root:FindFirstAncestorWhichIsA("ScrollingFrame")
			if not scroller then
				return
			end
			scroller:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				if not moreBtn or busy or not root.Parent then
					return
				end
				local p = root
				while p and p ~= scroller do
					if p:IsA("GuiObject") and not p.Visible then
						return
					end
					p = p.Parent
				end
				local bottom = scroller.CanvasPosition.Y + scroller.AbsoluteWindowSize.Y
				if bottom >= scroller.AbsoluteCanvasSize.Y - 120 then
					search(page + 1)
				end
			end)
		end)

		local api = { _frame = root }
		function api:Search(q)
			if q ~= nil then
				state.q = tostring(q)
				if box then
					box.Text = state.q
				end
			end
			search(1)
		end
		function api:Destroy()
			gen += 1
			root:Destroy()
		end
		return api
	end
end
