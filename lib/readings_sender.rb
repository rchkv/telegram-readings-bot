require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require './lib/app_configurator'

class ReadingsSender
  include Capybara::DSL

  def initialize
    Capybara.default_driver = :poltergeist
  end

  def open_site
    link = 'https://ek-territory.ru'
    visit link
    login
  end

  private

  def login
    config = AppConfigurator.new
    login = config.get_login
    password = config.get_password

    within('#login_form') do
      fill_in 'Flogin', with: login
      fill_in 'Fpass', with: password
      find('.go').click
    end
    page.has_content?('Моя информация')
  end
end
