return function(Lib)
	return function(Window)
		local ICON_SEARCH = "rbxassetid://121018724060431"
		local ICON_X = "rbxassetid://110786993356448"
		local KINDS = {
			"Toggle",
			"Button",
			"Slider",
			"Dropdown",
			"Input",
			"FeatureTile",
			"Keybind",
			"ColorPicker",
			"Stepper",
			"Menu",
		}

		do
			local TS = game:GetService("TweenService")
			local T = Lib.Theme
			local F = Lib.Fonts
			local first = Window.Tabs and Window.Tabs[1]
			local mt = first and getmetatable(first)
			local proto = mt and type(mt.__index) == "table" and mt.__index
			local list = Window.TabList
			if not proto or not list then
				return
			end

			local entries, menus = {}, {}

			local function tw(o, p, t)
				TS:Create(o, TweenInfo.new(t or 0.2, Enum.EasingStyle.Quint), p):Play()
			end

			local function new(class, props)
				local o = Instance.new(class)
				for k, v in props do
					o[k] = v
				end
				return o
			end

			local function nameOf(opts)
				if type(opts) == "string" then
					return opts
				end
				return type(opts) == "table" and (opts.Name or opts.Title) or nil
			end

			for _, kind in KINDS do
				local base = proto[kind]
				if type(base) == "function" then
					local function wrapped(self, opts, ...)
						local el = base(self, opts, ...)
						pcall(function()
							local owner = self._tab or self
							local name = nameOf(opts)
							if kind == "Menu" then
								menus[el] = { owner = owner, name = name }
							end
							if type(name) == "string" and name ~= "" then
								table.insert(
									entries,
									{ name = name, low = name:lower(), kind = kind, owner = owner, el = el }
								)
							end
						end)
						return el
					end
					proto[kind] = wrapped
					if proto["Create" .. kind] == base then
						proto["Create" .. kind] = wrapped
					end
				end
			end

			local function pathOf(owner)
				if owner.Menu then
					local m = menus[owner.Menu]
					if m then
						return pathOf(m.owner) .. " / " .. tostring(m.name)
					end
				end
				return tostring(owner.Name or "")
			end

			local function open(owner)
				if owner.Menu then
					local m = menus[owner.Menu]
					if m then
						open(m.owner)
					end
					pcall(function()
						owner.Menu:Open()
					end)
					pcall(function()
						owner:Select()
					end)
				else
					pcall(Window.SelectTab, Window, owner)
				end
			end

			local function scrollTo(f)
				local sc = f:FindFirstAncestorWhichIsA("ScrollingFrame")
				if not sc then
					return
				end
				local s = (Window.Scale and Window.Scale.Scale) or 1
				local y = f.AbsolutePosition.Y - sc.AbsolutePosition.Y + sc.CanvasPosition.Y * s
				y = y - (sc.AbsoluteSize.Y - f.AbsoluteSize.Y) / 2
				local max = math.max(0, sc.AbsoluteCanvasSize.Y - sc.AbsoluteWindowSize.Y)
				y = math.clamp(y, 0, max) / s
				tw(sc, { CanvasPosition = Vector2.new(sc.CanvasPosition.X, y) }, 0.35)
			end

			local flashing = {}
			local function flash(f)
				if flashing[f] then
					return
				end
				flashing[f] = true
				local st = f:FindFirstChildWhichIsA("UIStroke")
				local own = st == nil
				if own then
					st = new("UIStroke", {
						Color = T.Accent,
						Thickness = 1.5,
						Transparency = 1,
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Parent = f,
					})
				end
				local was = { Color = st.Color, Transparency = st.Transparency, Thickness = st.Thickness }
				task.spawn(function()
					for _ = 1, 2 do
						tw(st, { Color = T.Accent, Transparency = 0, Thickness = 1.5 }, 0.25)
						task.wait(0.45)
						tw(st, { Transparency = 0.65 }, 0.3)
						task.wait(0.35)
					end
					tw(st, { Transparency = 0 }, 0.25)
					task.wait(1.2)
					if own then
						tw(st, { Transparency = 1 }, 0.5)
						task.wait(0.55)
						st:Destroy()
					else
						tw(st, was, 0.5)
						task.wait(0.55)
					end
					flashing[f] = nil
				end)
			end

			local function go(e)
				open(e.owner)
				if e.kind == "Tab" then
					return
				end
				local f = e.el and e.el._frame
				if typeof(f) ~= "Instance" then
					return
				end
				task.delay(0.4, function()
					scrollTo(f)
					task.delay(0.3, function()
						flash(f)
					end)
				end)
			end

			local sidebar = list.Parent
			local top = list.Position.Y.Offset
			list.Position = UDim2.new(list.Position.X.Scale, list.Position.X.Offset, 0, top + 40)
			list.Size = UDim2.new(list.Size.X.Scale, list.Size.X.Offset, list.Size.Y.Scale, list.Size.Y.Offset - 40)

			local bar = new("Frame", {
				Name = "Search",
				Position = UDim2.fromOffset(16, top),
				Size = UDim2.new(1, -32, 0, 32),
				BackgroundColor3 = T.Surface2,
				BorderSizePixel = 0,
				ZIndex = 2,
				Parent = sidebar,
			})
			bar:SetAttribute("NoDrag", true)
			new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = bar })
			local stroke = new("UIStroke", { Color = T.Stroke, Transparency = 0, Parent = bar })
			new("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 10, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),
				BackgroundTransparency = 1,
				Image = ICON_SEARCH,
				ImageColor3 = T.Muted,
				ZIndex = 3,
				Parent = bar,
			})
			local box = new("TextBox", {
				Position = UDim2.fromOffset(32, 0),
				Size = UDim2.new(1, -58, 1, 0),
				BackgroundTransparency = 1,
				Text = "",
				PlaceholderText = "Search",
				PlaceholderColor3 = T.Muted,
				TextColor3 = T.Text,
				TextSize = 13,
				FontFace = F.Regular,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ClearTextOnFocus = false,
				ZIndex = 3,
				Parent = bar,
			})
			local clear = new("ImageButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -8, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),
				BackgroundTransparency = 1,
				Image = ICON_X,
				ImageColor3 = T.Muted,
				Visible = false,
				ZIndex = 3,
				Parent = bar,
			})

			local results = new("ScrollingFrame", {
				Name = "SearchResults",
				Position = list.Position,
				Size = list.Size,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 0,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(),
				Visible = false,
				ZIndex = 2,
				Parent = sidebar,
			})
			results:SetAttribute("NoDrag", true)
			new("UIPadding", {
				PaddingLeft = UDim.new(0, 16),
				PaddingRight = UDim.new(0, 16),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
				Parent = results,
			})
			new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2), Parent = results })
			local empty = new("TextLabel", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Text = "Nothing found",
				TextColor3 = T.Muted,
				TextSize = 13,
				FontFace = F.Regular,
				TextXAlignment = Enum.TextXAlignment.Left,
				Visible = false,
				ZIndex = 3,
				Parent = results,
			})
			new("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = empty })

			local rows, best = {}, nil

			local function row(e, i)
				local b = new("TextButton", {
					Size = UDim2.new(1, 0, 0, 40),
					BackgroundColor3 = T.Surface3,
					BackgroundTransparency = 1,
					AutoButtonColor = false,
					Text = "",
					LayoutOrder = i,
					ZIndex = 3,
					Parent = results,
				})
				new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = b })
				new("TextLabel", {
					Position = UDim2.fromOffset(10, 5),
					Size = UDim2.new(1, -20, 0, 16),
					BackgroundTransparency = 1,
					Text = e.name,
					TextColor3 = T.Text,
					TextSize = 13,
					FontFace = F.Medium,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 4,
					Parent = b,
				})
				new("TextLabel", {
					Position = UDim2.fromOffset(10, 21),
					Size = UDim2.new(1, -20, 0, 14),
					BackgroundTransparency = 1,
					Text = e.path,
					TextColor3 = T.Muted,
					TextSize = 11,
					FontFace = F.Regular,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
					ZIndex = 4,
					Parent = b,
				})
				b.MouseEnter:Connect(function()
					tw(b, { BackgroundTransparency = 0.5 }, 0.12)
				end)
				b.MouseLeave:Connect(function()
					tw(b, { BackgroundTransparency = 1 }, 0.2)
				end)
				b.MouseButton1Click:Connect(function()
					box.Text = ""
					box:ReleaseFocus()
					go(e)
				end)
				table.insert(rows, b)
			end

			local function score(low, q)
				local i = low:find(q, 1, true)
				if not i then
					return nil
				end
				if i == 1 then
					return 0
				end
				if low:sub(i - 1, i - 1) == " " then
					return 1
				end
				return 2
			end

			local function render(q)
				for _, b in rows do
					b:Destroy()
				end
				table.clear(rows)
				best = nil
				local hits = {}
				for _, t in Window.Tabs do
					local s = type(t.Name) == "string" and score(t.Name:lower(), q)
					if s then
						table.insert(hits, { name = t.Name, kind = "Tab", owner = t, s = s, path = "Tab" })
					end
				end
				for _, e in entries do
					local s = score(e.low, q)
					if s and not (e.el and e.el._destroyed) then
						local ok, p = pcall(pathOf, e.owner)
						table.insert(
							hits,
							{ name = e.name, kind = e.kind, owner = e.owner, el = e.el, s = s, path = ok and p or "" }
						)
					end
				end
				table.sort(hits, function(a, b)
					if a.s ~= b.s then
						return a.s < b.s
					end
					if #a.name ~= #b.name then
						return #a.name < #b.name
					end
					return a.path < b.path
				end)
				for i = 1, math.min(#hits, 40) do
					row(hits[i], i)
				end
				best = hits[1]
				empty.Visible = best == nil
				results.CanvasPosition = Vector2.zero
			end

			local function searching(on)
				results.Visible = on
				list.Visible = not on
				if Window.Indicator then
					if on then
						Window.Indicator.Visible = false
					elseif Window.CurrentTab then
						Window.Indicator.Visible = true
						pcall(Window._placeIndicator, Window, Window.CurrentTab)
					end
				end
			end

			box:GetPropertyChangedSignal("Text"):Connect(function()
				local q = box.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
				clear.Visible = box.Text ~= ""
				if q == "" then
					searching(false)
					return
				end
				searching(true)
				render(q)
			end)
			box.Focused:Connect(function()
				tw(stroke, { Color = T.Accent, Transparency = 0.3 }, 0.15)
			end)
			box.FocusLost:Connect(function(enter)
				tw(stroke, { Color = T.Stroke, Transparency = 0 }, 0.2)
				if enter and best then
					local e = best
					box.Text = ""
					go(e)
				end
			end)
			clear.MouseButton1Click:Connect(function()
				box.Text = ""
			end)
		end
	end
end
