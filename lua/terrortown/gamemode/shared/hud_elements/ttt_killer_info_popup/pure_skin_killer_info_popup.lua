local base = "pure_skin_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 400, h = 213},
		minsize = {w = 350, h = 213}
	}

	HUDELEMENT.icon_headshot = Material("vgui/ttt/huds/icon_headshot")

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		local hud = huds.GetStored("pure_skin")
		if hud then
			hud:ForceElement(self.id)
		end

		-- set as fallback default, other skins have to be set to true!
		self.disabledUnlessForced = false
	end

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:PerformLayout()
		self.basecolor = self:GetHUDBasecolor()

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = math.Round(ScrW() - (110 * self.scale + self.size.w)), y = math.Round(ScrH() * 0.5 - self.size.h * 0.5)}

		return const_defaults
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end

	function HUDELEMENT:ShouldDraw()
		return KILLER_INFO.data.render or HUDEditor.IsEditing
	end
	-- parameter overwrites end

	local icon_armor = Material("vgui/ttt/hud_armor.vmt")
	local icon_armor_rei = Material("vgui/ttt/hud_armor_reinforced.vmt")

	function HUDELEMENT:Draw()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h

		self:DrawHelper(x, y, w, h)

		-- draw border and shadow
		self:DrawLines(x, y, w, h, self.basecolor.a)
	end

	-- added to a helper function to use return instead of nested ifs
	function HUDELEMENT:DrawHelper(x, y, w, h)
		-- params
		local edge_padding = 39
		local box_size = 78
		local inner_padding = 14

		-- draw bg
		self:DrawBg(x, y, w, h, self.basecolor)

		local ix = x + edge_padding + box_size + inner_padding
		local iy = y + inner_padding - 4

		local ywkb = string.upper(LANG.GetTranslation("ttt_rs_you_were_killed"))
		draw.AdvancedText(ywkb, "PureSkinBar", ix, iy, util.GetDefaultColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true, self.scale)

		surface.SetDrawColor(0, 0, 0, 90)
		surface.DrawRect(x, y + edge_padding, w, box_size)

		surface.SetDrawColor(KILLER_INFO.data.killer_role_color)
		surface.DrawRect(x + edge_padding, y, box_size, 32)

		surface.SetDrawColor(KILLER_INFO.data.killer_role_color)
		surface.DrawRect(x + edge_padding, y + edge_padding, box_size, box_size)
		self:DrawLines(x + edge_padding, y + edge_padding, box_size, box_size, self.basecolor.a)

		draw.FilteredTexture(x + 46, y + 46, 64, 64, KILLER_INFO.data.killer_icon)
		self:DrawLines(x + 47, y + 47, 64, 64, self.basecolor.a)

		surface.SetDrawColor(KILLER_INFO.data.killer_role_color)
		surface.DrawRect(x + edge_padding, y + 124, box_size, h - 124)

		-- killer name
		local nx = x + edge_padding + box_size + inner_padding
		local ny = y + edge_padding + inner_padding - 4

		local killer_name = string.upper(KILLER_INFO.data.killer_name)
		draw.AdvancedText(killer_name, "PureSkinBar", nx, ny, util.GetDefaultColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true, self.scale)

		-- killer hp
		local bh = 26 --  bar height
		local bx = nx
		local by = y + edge_padding + box_size - bh - inner_padding
		local bw = w - (bx - x) - inner_padding -- bar width
		self:DrawBar(bx, by, bw, bh, Color(234, 41, 41), KILLER_INFO.data.killer_health / KILLER_INFO.data.killer_max_health, self.scale, string.upper(LANG.GetTranslation("hud_health")) .. ": " .. KILLER_INFO.data.killer_health)

		-- draw armor information
		if not GetGlobalBool("ttt_armor_classic", false) and KILLER_INFO.data.killer_armor > 0 then
			local icon_mat = LocalPlayer():ArmorIsReinforced() and icon_armor_rei or icon_armor

			local a_size = bh - math.Round(11 * self.scale)
			local a_pad = math.Round(5 * self.scale)

			local a_pos_y = by + a_pad
			local a_pos_x = nx + bw - math.Round(65 * self.scale)

			local at_pos_y = by + 1
			local at_pos_x = a_pos_x + a_size + a_pad

			draw.FilteredShadowedTexture(a_pos_x, a_pos_y, a_size, a_size, icon_mat, 255, COLOR_WHITE, self.scale)

			draw.AdvancedText(KILLER_INFO.data.killer_armor, "PureSkinBar", at_pos_x, at_pos_y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT, true, self.scale)
		end

		-- killer role
		if KILLER_INFO.data.mode ~= "killer_world" then
			draw.FilteredTexture(x + edge_padding + 0.5 * (box_size - 40) , y + edge_padding + box_size + inner_padding, 40, 40, KILLER_INFO.data.killer_role_icon)
		end

		if KILLER_INFO.data.mode == "killer_self_no_weapon" or KILLER_INFO.data.mode == "killer_no_weapon" or KILLER_INFO.data.mode == "killer_world" then
			local wx = x + edge_padding + box_size + inner_padding
			local wy = y + edge_padding + box_size + inner_padding

			draw.FilteredTexture(wx, wy, 32, 32, KILLER_INFO.data.damage_type_icon)
			self:DrawLines(wx, wy, 32, 32, self.basecolor.a * 0.75)

			local damage_type_name = string.upper(KILLER_INFO.data.damage_type_name)
			draw.AdvancedText(damage_type_name, "PureSkinBar", wx + 42, wy + 5, util.GetDefaultColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true, self.scale)
			return
		end

		-- killer weapon info
		local wx = x + edge_padding + box_size + inner_padding
		local wy = y + edge_padding + box_size + inner_padding

		-- killer weapon icon
		draw.FilteredTexture(wx, wy, 32, 32, KILLER_INFO.data.killer_weapon_icon)
		self:DrawLines(wx, wy, 32, 32, self.basecolor.a * 0.75)

		-- killer weapon name
		local weapon_name = string.upper(KILLER_INFO.data.killer_weapon_name)
		local weapon_name_width = surface.GetTextSize(weapon_name) * self.scale
		draw.AdvancedText(weapon_name, "PureSkinBar", wx + 42, wy + 5, util.GetDefaultColor(self.basecolor), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, true, self.scale)

		-- killer weapon headshot
		if KILLER_INFO.data.killer_weapon_head then
			draw.FilteredTexture(wx + 42 + weapon_name_width + 8, wy + 3, 24, 24, self.icon_headshot, 180, {r = 240, g = 80, b = 45})
		end

		-- killer ammo
		local ah = 26 -- bar height
		local ax = wx
		local ay = y + h - inner_padding - ah
		local aw = w - (wx - x) - inner_padding  -- bar width

		if KILLER_INFO.data.killer_weapon_clip >= 0 then
			local text = string.format("%i + %02i", KILLER_INFO.data.killer_weapon_clip, KILLER_INFO.data.killer_weapon_ammo)
			self:DrawBar(ax, ay, aw, ah, Color(238, 151, 0), KILLER_INFO.data.killer_weapon_clip / KILLER_INFO.data.killer_weapon_clip_max, self.scale, text)
		end
	end
end
