return function(Lib)
	local K = Lib.Element("Kit")
	local T, F, new, tween = K.T, K.F, K.new, K.tween

	return function(tab, opts)
		opts = opts or {}
		local P = K.Pad
		local colors = opts.Colors or {}
		local cMurd = colors.Murderer or K.Red
		local cSher = colors.Sheriff or K.Blue
		local cInno = colors.Innocent or K.Green
		local card = K.card(tab, 110 + K.BtnH + P, { Name = "RoleBoard" })

		local _, _, right = K.head(card, "users", opts.Title or "Round")
		local you = K.status(right, "Lobby", T.Muted)

		local function panel(x, role, col)
			local f = K.inset(card, {
				Position = x,
				Size = UDim2.new(0.5, -P - 5, 0, 52),
			})
			local av = K.avatar(f, 32, { Position = UDim2.fromOffset(10, 10) })
			local dot = new("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromOffset(50, 16),
				Size = UDim2.fromOffset(6, 6),
				BackgroundColor3 = col,
				BorderSizePixel = 0,
				Parent = f,
			})
			K.corner(dot, UDim.new(1, 0))
			local line = K.muted({
				Position = UDim2.fromOffset(62, 9),
				Size = UDim2.new(1, -72, 0, 14),
				Text = role,
				TextSize = 12,
				Parent = f,
			})
			local name = K.text({
				Position = UDim2.fromOffset(50, 24),
				Size = UDim2.new(1, -60, 0, 18),
				Text = "Unknown",
				TextColor3 = T.Muted,
				Parent = f,
			})
			return { Av = av, Dot = dot, Line = line, Name = name, Role = role, Who = false }
		end
		local murd = panel(UDim2.fromOffset(P, 46), "Murderer", cMurd)
		local sher = panel(UDim2.new(0.5, 5, 0, 46), "Sheriff", cSher)

		local gunIcon = K.icon(card, "crosshair", 16, T.Muted, { Position = UDim2.fromOffset(P, 110 + K.BtnH / 2 - 8) })
		local gunText = K.text({
			Position = UDim2.fromOffset(P + 24, 110),
			Size = UDim2.new(1, -P * 2 - 24 - 190, 0, K.BtnH),
			Text = "No gun on the map",
			TextSize = 13,
			FontFace = F.Regular,
			TextColor3 = T.Muted,
			Parent = card,
		})
		local words = new("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -P, 0, 110),
			Size = UDim2.fromOffset(190, K.BtnH),
			BackgroundTransparency = 1,
			Parent = card,
		})
		K.list(words, Enum.FillDirection.Horizontal, 8, { HorizontalAlignment = Enum.HorizontalAlignment.Right })
		local shoot = opts.Shoot and K.word(words, opts.ShootText or "Shoot", opts.Shoot, { LayoutOrder = 1 })
		local grab = opts.Grab and K.word(words, opts.GrabText or "Grab gun", opts.Grab, { LayoutOrder = 2 })

		local function fill(p, plr, dist, extra)
			if plr ~= p.Who then
				p.Who = plr
				if plr then
					K.setAvatar(p.Av, plr)
					p.Name.Text = plr.DisplayName
					p.Name.TextColor3 = T.Text
				else
					p.Av.Image = ""
					p.Name.Text = "Unknown"
					p.Name.TextColor3 = T.Muted
				end
				p.Dot.BackgroundTransparency = plr and 0 or 0.6
			end
			local s = p.Role
			if plr and tonumber(dist) then
				s ..= ", " .. K.fmt(dist) .. " studs"
			end
			if extra then
				s ..= extra
			end
			p.Line.Text = s
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
			if shoot then
				K.enable(shoot, d.CanShoot == true and d.Murderer ~= nil)
			end
			local g = d.Gun
			if g == "Dropped" then
				gunText.Text = "Gun dropped"
					.. (tonumber(d.GunDist) and (", " .. K.fmt(d.GunDist) .. " studs away") or "")
				gunText.TextColor3 = T.Text
				tween(gunIcon, { ImageColor3 = K.Amber }, 0.2)
			elseif g == "Held" then
				gunText.Text = d.GunText or "Gun is held"
				gunText.TextColor3 = T.Text
				tween(gunIcon, { ImageColor3 = T.Text }, 0.2)
			else
				gunText.Text = d.GunText or "No gun on the map"
				gunText.TextColor3 = T.Muted
				tween(gunIcon, { ImageColor3 = T.Muted }, 0.2)
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
