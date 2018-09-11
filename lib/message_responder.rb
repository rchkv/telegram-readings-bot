require 'active_record'
require './lib/message_sender'
require './lib/readings_sender'

class MessageResponder
  attr_reader :message
  attr_reader :bot

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
  end

  def respond
    case message.text
    when '/start'
      answer_with_greeting_message
    when '/stop'
      answer_with_farewell_message
    when 'open'
      login_to_site
      answer_with_message("Сайт открыл, заходи :)")
    when 'ГВС'
      fill_hot_water_reading
      answer_with_message("Заполнил ГВС")
    else
      answer_with_error_message
    end
  end

  private

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_error_message
    answer_with_message I18n.t('error_message')
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def login_to_site
    ReadingsSender.new.open_site_and_login
  end

  def fill_hot_water_reading
    ReadingsSender.new.fill_hot_water_reading
  end
end
