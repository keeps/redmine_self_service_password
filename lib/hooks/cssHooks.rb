require 'redmine'
# encoding: utf-8
module RedmineSelfServicePassword
  class Hooks < Redmine::Hook::ViewListener
	def view_layouts_base_html_head(context={ })
      		context[:controller].send(:render_to_string, {
        	:partial => "hooks/redmine_self_service_password/includes",
        	:locals => context
      })
   	end
  end
end
