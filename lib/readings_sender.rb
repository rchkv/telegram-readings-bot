require 'capybara'
require 'capybara/dsl'
require 'capybara/poltergeist'
require './lib/app_configurator'

HOME_PAGE = 'https://ek-territory.ru'
METERS_PAGE = 'https://ek-territory.ru/office/meters'

class ReadingsSender
  include Capybara::DSL

  def initialize
    Capybara.default_driver = :poltergeist
  end

  def open_site_and_login
    visit HOME_PAGE
    login
  end

  def fill_hot_water_reading(reading)
    visit_meters_page
    within(:xpath, '//tbody//tr[6]//td[5]') do
      find(:xpath, 'input').set(reading)
    end
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

  def visit_meters_page
    visit METERS_PAGE
    page.has_content?('Перечень счетчиков')
  end

  def debug
    print page.html
    save_screenshot(full: true)
  end

end
