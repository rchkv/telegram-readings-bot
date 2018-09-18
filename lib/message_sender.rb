require './lib/app_configurator'

class MessageSender
  attr_reader :bot
  attr_reader :text
  attr_reader :chat
  attr_reader :answers
  attr_reader :logger

  def initialize(options)
    @bot = options[:bot]
    @text = options[:text]
    @chat = options[:chat]
    @answers = options[:answers]
    @logger = AppConfigurator.new.get_logger
  end

  def send
    bot.api.send_message(chat_id: chat.id, text: text)

    logger.debug "sending '#{text}' to #{chat.username}"
  end

  def send_with_answers
    answers =
      Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: [['🚿 Горячая вода', '🚰 Холодная вода'], ['💡 Электроэнергия (день)', '💡 Электроэнергия (ночь)'], ['🚀 Отправить']])

    bot.api.send_message(chat_id: chat.id, text: text, reply_markup: answers)

    logger.debug "sending '#{text}' to #{chat.username}"
  end
end
