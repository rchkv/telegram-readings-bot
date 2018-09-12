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
    if @state[:is_gvs]
      respond_gvs
    else
      respond_general
    end
  end

  def respond_general
    case message.text
    when 'open'
      login_to_site
      answer_with_message_type('browser_open')
    when 'ГВС'
      @state[:is_gvs] = true
      answer_with_message_type('water_reading')
    else
      answer_with_message_type('error')
    end
  end

  def respond_gvs
    fill_hot_water_reading(message.text)
    answer_with_message_type('hot_water_reading_filled')
    @state[:is_gvs] = false
  end

  private

  def answer_with_message_type(type)
    answer_with_message I18n.t(type)
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def login_to_site
    ReadingsSender.new.open_site_and_login
  end

  def fill_hot_water_reading(reading)
    ReadingsSender.new.fill_hot_water_reading(reading)
  end
end
