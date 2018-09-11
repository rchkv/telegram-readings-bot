require 'logger'

class AppConfigurator
  def configure
    setup_i18n
  end

  def get_token
    YAML::load(IO.read('config/secrets.yml'))['telegram_bot_token']
  end

  def get_login
    YAML::load(IO.read('config/secrets.yml'))['site_login']
  end

  def get_password
    YAML::load(IO.read('config/secrets.yml'))['site_password']
  end

  def get_logger
    Logger.new(STDOUT, Logger::DEBUG)
  end

  private

  def setup_i18n
    I18n.load_path = Dir['config/locales.yml']
    I18n.locale = :en
    I18n.backend.load_translations
  end
end
