require 'active_record'
require './lib/message_sender'

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
    end
  end

  private

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end
end
