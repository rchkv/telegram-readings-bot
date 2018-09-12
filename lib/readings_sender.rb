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
    visit METERS_PAGE if current_url != METERS_PAGE
    fill_reading('//tbody//tr[6]//td[5]', reading)
    debug
  end

  def fill_cold_water_reading(reading)
    visit METERS_PAGE if current_url != METERS_PAGE
    fill_reading('//tbody//tr[2]//td[5]', reading)
    debug
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

  def fill_reading(input_xpath, reading)
    within(:xpath, input_xpath) do
      find(:xpath, 'input').set(reading)
    end
  end

  def current_url
    Capybara.current_url
  end

  def debug
    print page.html
    save_screenshot(full: true)
  end
end
