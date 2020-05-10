# -*- coding: utf-8 -*-
from odoo import api, models, _
from odoo.exceptions import UserError


class ResUsers(models.Model):
	_inherit = 'res.users'

	@api.model
	def create(self, vals):
		users = len(self.env['res.users'].search([]))
		if self.env.user.company_id.max_limit <= users:
			raise UserError(_("Maximum number of users reached. Please contact the vendor for details!"))
		res = super(ResUsers, self).create(vals)
		return res
