require 'redmine'
require 'dispatcher'
require 'account_controller_patch'

Redmine::Plugin.register :redmine_self_service_password do
  name 'Redmine Self Service Password plugin'
  author 'Sébastien Leroux'
  description 'This is a plugin that allows Redmine to work with the Keep\'s Authentication Management Service'
  version '0.0.3'
  author_url 'mailto:sleroux@keep.pt'

  settings :default => {
    'authenticationServiceURL' => 'https://www.keep.pt/ams/',
    'authenticationServiceName' => 'KEEP SOLUTIONS authentication management service'
  }, :partial => 'settings/self_service_password'
  project_module :self_service_password do
    permission :self_service, {:self_service_password => :show}
  end
end

Dispatcher.to_prepare do
	 require_dependency 'account_controller'
  AccountController.send(:include, AccountControllerPatch)
end
