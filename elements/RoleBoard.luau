return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local colors = opts.Colors or {}
		local cMurd = colors.Murderer or K.Red
		local cSher = colors.Sheriff or K.Blue
		local cInno = colors.Innocent or K.Green

		local card = K.card(tab, 176, { Name = "RoleBoard" })
		local _, title, right = K.head(card, "swords", opts.Title or "Round", 10)
		title.FontFace = F.Bold
		local you = K.pill(right, "Lobby", T.Muted)

		local function slot(x, role, col, word, cb)
			local f = new("Frame", {
				Position = UDim2.new(x, x == 0 and 12 or 4, 0, 42),
				Size = UDim2.new(0.5, -16, 0, 72),
				BackgroundColor3 = T.Surface3,
				BackgroundTransparency = 0.4,
				BorderSizePixel = 0,
				Parent = card,
			})
			K.corner(f, 9)
			local st = K.stroke(f, T.Stroke)
			local bar = new("Frame", {
				Position = UDim2.fromOffset(0, 14),
				Size = UDim2.new(0, 3, 1, -28),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				Parent = f,
			})
			K.corner(bar, UDim.new(1, 0))
			local av = K.avatar(f, 40, { Position = UDim2.new(0, 14, 0.5, -20) })
			local ph = K.icon(av, "user-round", 18, T.Muted, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
			})
			local avs = K.stroke(av, col, 0.4, 1.5)
			local rl = K.text({
				Position = UDim2.fromOffset(64, 12),
				Size = UDim2.new(1, -76, 0, 14),
				Text = string.upper(role),
				TextSize = 11,
				FontFace = F.Bold,
				TextColor3 = col,
				Parent = f,
			})
			local nm = K.text({
				Position = UDim2.fromOffset(64, 26),
				Size = UDim2.new(1, -76, 0, 18),
				Text = "Unknown",
				FontFace = F.Bold,
				TextColor3 = T.Muted,
				Parent = f,
			})
			local ds = K.text({
				Position = UDim2.fromOffset(64, 44),
				Size = UDim2.new(1, -76, 0, 16),
				Text = "",
				TextSize = 12,
				FontFace = F.Regular,
				TextColor3 = T.Muted,
				Parent = f,
			})
			local w
			if word then
				w = K.word(f, word, cb, {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
				})
				nm.Size = UDim2.new(1, -150, 0, 18)
				ds.Size = UDim2.new(1, -150, 0, 16)
			end
			return {
				Frame = f,
				Stroke = st,
				Avatar = av,
				Ph = ph,
				AvStroke = avs,
				Role = rl,
				Name = nm,
				Dist = ds,
				Word = w,
				Col = col,
				Plr = nil,
			}
		end

		local murd = slot(0, "Murderer", cMurd, opts.Shoot and (opts.ShootText or "Shoot"), opts.Shoot)
		local sher = slot(0.5, "Sheriff", cSher)

		local gun = new("Frame", {
			Position = UDim2.new(0, 12, 0, 124),
			Size = UDim2.new(1, -24, 0, 40),
			BackgroundColor3 = T.Surface3,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Parent = card,
		})
		K.corner(gun, 9)
		local gunStroke = K.stroke(gun)
		local gunIcon = K.icon(gun, "crosshair", 16, T.Muted, { Position = UDim2.new(0, 12, 0.5, -8) })
		local gunText = K.text({
			Position = UDim2.fromOffset(36, 0),
			Size = UDim2.new(1, -150, 1, 0),
			Text = "No gun on the map",
			TextSize = 13,
			TextColor3 = T.Muted,
			Parent = gun,
		})
		local grab
		if opts.Grab then
			grab = K.word(gun, opts.GrabText or "Grab gun", opts.Grab, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -7, 0.5, 0),
			})
			K.enable(grab, false)
		end

		local function fill(s, plr, dist, extra)
			if plr ~= s.Plr then
				s.Plr = plr
				if plr then
					s.Ph.Visible = false
					K.setAvatar(s.Avatar, plr)
					s.Name.Text = plr.DisplayName
					s.Name.TextColor3 = T.Text
				else
					s.Ph.Visible = true
					s.Avatar.Image = ""
					s.Name.Text = "Unknown"
					s.Name.TextColor3 = T.Muted
				end
				tween(s.Stroke, { Color = plr and s.Col or T.Stroke, Transparency = plr and 0.6 or 0 }, 0.2)
			end
			if plr and tonumber(dist) then
				s.Dist.Text = K.fmt(dist) .. " studs" .. (extra or "")
			else
				s.Dist.Text = plr and (extra and extra:gsub("^%s*,%s*", "") or "") or "Not found yet"
			end
		end

		local api = { Frame = card }

		function api:Set(d)
			d = d or {}
			fill(murd, d.Murderer, d.MurdererDist)
			fill(sher, d.Sheriff, d.SheriffDist, d.SheriffDead and ", dead" or nil)

			local role = d.Role
			if role == "Murderer" then
				you:Set("You are Murderer", cMurd)
			elseif role == "Sheriff" or role == "Hero" then
				you:Set("You are " .. role, cSher)
			elseif role == "Innocent" then
				you:Set("You are Innocent", cInno)
			else
				you:Set(role or "Lobby", T.Muted)
			end

			if murd.Word then
				K.enable(murd.Word, d.CanShoot == true and d.Murderer ~= nil)
			end

			local g = d.Gun
			if g == "Dropped" then
				gunText.Text = "Gun dropped"
					.. (tonumber(d.GunDist) and (", " .. K.fmt(d.GunDist) .. " studs away") or "")
				gunText.TextColor3 = T.Text
				tween(gunIcon, { ImageColor3 = K.Amber }, 0.2)
				tween(gunStroke, { Color = K.Amber, Transparency = 0.5 }, 0.2)
			elseif g == "Held" then
				gunText.Text = d.GunText or "Gun is held"
				gunText.TextColor3 = T.Text
				tween(gunIcon, { ImageColor3 = cSher }, 0.2)
				tween(gunStroke, { Color = T.Stroke, Transparency = 0 }, 0.2)
			else
				gunText.Text = d.GunText or "No gun on the map"
				gunText.TextColor3 = T.Muted
				tween(gunIcon, { ImageColor3 = T.Muted }, 0.2)
				tween(gunStroke, { Color = T.Stroke, Transparency = 0 }, 0.2)
			end
			if grab then
				K.enable(grab, g == "Dropped")
			end
		end

		function api:Destroy()
			card:Destroy()
		end

		api:Set({})
		return api
	end
end
