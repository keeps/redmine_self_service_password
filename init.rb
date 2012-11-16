require 'redmine'
require 'dispatcher'
require 'mailer_patch'

Redmine::Plugin.register :redmine_self_service_password do
  name 'Redmine Self Service Password plugin'
  author 'Sébastien Leroux'
  description 'This is a plugin that bla bla bla'
  version '0.0.1'
  author_url 'mailto:sleroux@keep.pt'

  settings :default => {
    'authenticationServiceURL' => 'http://www.google.pt'
  }, :partial => 'settings/self_service_password'
  project_module :self_service_password do
    permission :self_service, {:self_service_password => :show}
  end
end

Dispatcher.to_prepare do
	 require_dependency 'mailer'
  AccountController.send(:include, AccountControllerPatch)
end
