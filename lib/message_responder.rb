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
    if @state[:is_hot_water]
      fill_hot_water
    elsif @state[:is_cold_water]
      fill_cold_water
    elsif @state[:is_day_energy]
      fill_day_energy
    elsif @state[:is_night_energy]
      fill_night_energy
    else
      respond_general
    end
  end

  def respond_general
    case message.text
    when '/start'
      answer_with_start_answer
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
    else
      answer_with_message_type('error')
    end
  end

  def fill_hot_water
    fill_hot_water_reading(message.text)
    answer_with_message_type('hot_water_reading_filled')
    @state[:is_hot_water] = false
  end

  def fill_cold_water
    fill_cold_water_reading(message.text)
    answer_with_message_type('cold_water_reading_filled')
    @state[:is_cold_water] = false
  end

  def fill_day_energy
    fill_day_energy_reading(message.text)
    answer_with_message_type('day_energy_reading_filled')
    @state[:is_day_energy] = false
  end

  def fill_night_energy
    fill_night_energy_reading(message.text)
    answer_with_message_type('night_energy_reading_filled')
    @state[:is_night_energy] = false
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

  def answer_with_start_answer
    MessageSender.new(bot: bot, chat: message.chat, text: I18n.t('start_bot_message')).answer_with_start_answer
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
end
