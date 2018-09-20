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

  def answer_with_readings_types_answers
    answers =
      Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: [['🚿 Горячая вода', '🚰 Холодная вода'], ['💡 Электроэнергия (день)', '💡 Электроэнергия (ночь)']], resize_keyboard: true, one_time_keyboard: true)

    bot.api.send_message(chat_id: chat.id, text: text, reply_markup: answers)

    logger.debug "sending '#{text}' to #{chat.username}"
  end

  def answer_with_start_answer
    answers =
      Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: ['Начнём вводить показания'], resize_keyboard: true, one_time_keyboard: true)

    bot.api.send_message(chat_id: chat.id, text: text, reply_markup: answers)

    logger.debug "sending '#{text}' to #{chat.username}"
  end
end
