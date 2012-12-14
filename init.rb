require 'redmine'
require 'dispatcher'
require 'account_controller_patch'

require_dependency 'hooks/cssHooks'

Redmine::Plugin.register :redmine_self_service_password do
  name 'Redmine Self Service Password plugin'
  author 'Sébastien Leroux'
  description 'This is a plugin that allows Redmine to work with the Self Service Password application (http://ltb-project.org/wiki/documentation/self-service-password)'
  version '0.0.4'
  author_url 'mailto:sleroux@keep.pt'
  url 'https://github.com/keeps/redmine_self_service_password'
  settings :default => {
    'selfServicePasswordURL' => 'https://www.keep.pt/ams/',
    'selfServicePasswordName' => 'KEEP SOLUTIONS authentication management service'
  }, :partial => 'settings/self_service_password'
end

Dispatcher.to_prepare do
	 require_dependency 'account_controller'
  AccountController.send(:include, AccountControllerPatch)
end
