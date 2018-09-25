require 'active_record'
require './lib/message_sender'
require './lib/readings_sender'

class MessageResponder
  attr_reader :message
  attr_reader :bot

  class <<self
    def states
      @states ||= {}
    end

    def user_state(user_id)
      states[user_id] ||= {}
    end
  end

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @state = self.class.user_state(@message[:from][:id])
  end

  def respond
    if @state[:is_cold_water]
      fill_cold_water
    elsif @state[:is_day_energy]
      fill_day_energy
    elsif @state[:is_night_energy]
      fill_night_energy
    elsif @state[:is_hot_water]
      fill_hot_water
    else
      respond_general
    end
  end

  def respond_general
    case message.text
    when '/start'
      answer_with_start_button('start_bot_message')
    when 'Начнём вводить показания'
      login_to_site
      answer_with_readings_types_answers
    when '🚿 Горячая вода'
      @state[:is_hot_water] = true
      answer_with_message_type('fill_reading_help')
    when '🚰 Холодная вода'
      @state[:is_cold_water] = true
      answer_with_message_type('fill_reading_help')
    when '💡 Электроэнергия (день)'
      @state[:is_day_energy] = true
      answer_with_message_type('fill_reading_help')
    when '💡 Электроэнергия (ночь)'
      @state[:is_night_energy] = true
      answer_with_message_type('fill_reading_help')
    when 'Да!'
      send_readings
      answer_with_start_button('readings_sended')
      clear_states
    when 'Отменить всё к чертям'
      clear_states
      answer_with_start_button('reset')
    when 'Я передумал'
      clear_states
      answer_with_start_button('reset')
    else
      answer_with_message_type('error')
    end
  end

  def fill_hot_water
    fill_hot_water_reading(message.text)
    answer_with_message_type('hot_water_reading_filled')
    @state[:is_hot_water] = false
    @state[:hot_water_filled] = true
    if can_send_readings?
      ready_for_send_readings
    end
  end

  def fill_cold_water
    fill_cold_water_reading(message.text)
    answer_with_message_type('cold_water_reading_filled')
    @state[:is_cold_water] = false
    @state[:cold_water_filled] = true
    if can_send_readings?
      ready_for_send_readings
    end
  end

  def fill_day_energy
    fill_day_energy_reading(message.text)
    answer_with_message_type('day_energy_reading_filled')
    @state[:is_day_energy] = false
    @state[:day_energy_filled] = true
    if can_send_readings?
      ready_for_send_readings
    end
  end

  def fill_night_energy
    fill_night_energy_reading(message.text)
    answer_with_message_type('night_energy_reading_filled')
    @state[:is_night_energy] = false
    @state[:night_energy_filled] = true
    if can_send_readings?
      ready_for_send_readings
    end
  end

  def ready_for_send_readings
    answer_with_send_readings_answers
    @state[:hot_water_filled]   = false
    @state[:cold_water_filled]  = false
    @state[:day_energy_filled]  = false
    @state[:night_energy_filled] = false
  end

  def clear_states
    @state[:hot_water_filled]   = false
    @state[:cold_water_filled]  = false
    @state[:day_energy_filled]  = false
    @state[:night_energy_filled] = false
    @state[:is_night_energy]    = false
    @state[:is_day_energy]      = false
    @state[:is_cold_water]      = false
    @state[:is_hot_water]       = false
    ReadingsSender.new.reset
  end

  private

  def answer_with_message_type(type)
    answer_with_message I18n.t(type)
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def answer_with_readings_types_answers
    MessageSender.new(bot: bot, chat: message.chat, text: I18n.t('wait_for_reading')).answer_with_readings_types_answers
  end

  def answer_with_start_button(locale_type)
    MessageSender.new(bot: bot, chat: message.chat, text: I18n.t(locale_type)).answer_with_start_button
  end

  def answer_with_send_readings_answers
    MessageSender.new(bot: bot, chat: message.chat, text: I18n.t('wait_for_send_readings')).answer_with_send_readings_answers
  end

  def login_to_site
    ReadingsSender.new.open_site_and_login
  end

  def fill_hot_water_reading(reading)
    ReadingsSender.new.fill_hot_water_reading(reading)
  end

  def fill_cold_water_reading(reading)
    ReadingsSender.new.fill_cold_water_reading(reading)
  end

  def fill_day_energy_reading(reading)
    ReadingsSender.new.fill_day_energy_reading(reading)
  end

  def fill_night_energy_reading(reading)
    ReadingsSender.new.fill_night_energy_reading(reading)
  end

  def send_readings
    ReadingsSender.new.send_readings
  end

  def can_send_readings?
    @state[:hot_water_filled] && @state[:cold_water_filled] && @state[:day_energy_filled] && @state[:night_energy_filled]
  end
end
