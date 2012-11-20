module AccountControllerPatch
    def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :register_automatically, :ssp
      alias_method_chain :register, :ssp
      alias_method_chain :activate, :ssp
      alias_method_chain :invalid_credentials, :ssp
    end
  end

  module InstanceMethods
  
  # User self-registration
  def register_with_ssp
    redirect_to(home_url) && return unless Setting.self_registration? || session[:auth_source_registration]
    if request.get?
      session[:auth_source_registration] = nil
      @user = User.new(:language => Setting.default_language)
    else
      @user = User.new
      @user.safe_attributes = params[:user]
      @user.admin = false
      @user.register
      if session[:auth_source_registration]
        @user.activate
        @user.login = session[:auth_source_registration][:login]
        @user.auth_source_id = session[:auth_source_registration][:auth_source_id]
        if @user.save
          session[:auth_source_registration] = nil
          self.logged_user = @user
          name=@user.firstname+" "+@user.lastname
          flash[:notice] = l(:notice_account_activated_ssp, :selfServicePasswordURL => Setting.plugin_redmine_self_service_password['selfServicePasswordURL'],:selfServicePasswordName => Setting.plugin_redmine_self_service_password['selfServicePasswordName'], :name => name)
          redirect_to :controller => 'my', :action => 'account'
        end
      else
        @user.login = params[:user][:login]
        @user.password, @user.password_confirmation = params[:user][:password], params[:user][:password_confirmation]

        case Setting.self_registration
        when '1'
          register_by_email_activation(@user)
        when '3'
          register_automatically(@user)
        else
          register_manually_by_administrator(@user)
        end
      end
    end
  end

  # Token based account activation
  def activate_with_ssp
    redirect_to(home_url) && return unless Setting.self_registration? && params[:token]
    token = Token.find_by_action_and_value('register', params[:token])
    redirect_to(home_url) && return unless token and !token.expired?
    user = token.user
    redirect_to(home_url) && return unless user.registered?
    user.activate
    if user.save
      token.destroy
      name=user.firstname+" "+user.lastname
      flash[:notice] = l(:notice_account_activated_ssp, :selfServicePasswordURL => Setting.plugin_redmine_self_service_password['selfServicePasswordURL'],:selfServicePasswordName => Setting.plugin_redmine_self_service_password['selfServicePasswordName'],:name => name)
    end
    redirect_to :action => 'login'
  end

  def invalid_credentials_with_ssp
    logger.warn "Failed login for '#{params[:username]}' from #{request.remote_ip} at #{Time.now.utc}"
    flash.now[:error] = l(:notice_account_invalid_creditentials_ssp , :selfServicePasswordURL => Setting.plugin_redmine_self_service_password['selfServicePasswordURL'],:selfServicePasswordName => Setting.plugin_redmine_self_service_password['selfServicePasswordName'])
  end


  def register_automatically_with_ssp(user, &block)
    # Automatic activation
    user.activate
    user.last_login_on = Time.now
    if user.save
      self.logged_user = user
      name=user.firstname+" "+user.lastname
      flash[:notice] = l(:notice_account_activated_ssp, :selfServicePasswordURL => Setting.plugin_redmine_self_service_password['selfServicePasswordURL'],:selfServicePasswordName => Setting.plugin_redmine_self_service_password['selfServicePasswordName'],:name => name)
      redirect_to :controller => 'my', :action => 'account'
    else
      yield if block_given?
    end
  end	
  end
  end
