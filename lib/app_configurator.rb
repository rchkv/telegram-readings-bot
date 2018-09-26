require 'logger'

class AppConfigurator
  def configure
    setup_i18n
  end

  def get_token
    ENV['TELEGRAM_BOT_TOKEN']
  end

  def get_login
    ENV['SITE_LOGIN']
  end

  def get_password
    ENV['SITE_PASSWORD']
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
