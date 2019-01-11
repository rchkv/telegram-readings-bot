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
      .new(keyboard: [['🚿 Горячая вода', '🚰 Холодная вода'], ['💡 Электроэнергия (день)', '💡 Электроэнергия (ночь)'], ['Отменить всё к чертям']], resize_keyboard: true)

    bot.api.send_message(chat_id: chat.id, text: text, reply_markup: answers)

    logger.debug "sending '#{text}' to #{chat.username}"
  end

  def answer_with_start_button
    answers =
      Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: ['Начнём вводить показания'], resize_keyboard: true, one_time_keyboard: true)

    bot.api.send_message(chat_id: chat.id, text: text, reply_markup: answers)

    logger.debug "sending '#{text}' to #{chat.username}"
  end

  def answer_with_send_readings_answers
    answers =
      Telegram::Bot::Types::ReplyKeyboardMarkup
      .new(keyboard: [['Да!'], ['Я передумал']], resize_keyboard: true, one_time_keyboard: true)

    bot.api.send_message(chat_id: chat.id, text: text, reply_markup: answers)

    logger.debug "sending '#{text}' to #{chat.username}"
  end

  def send_image
    bot.api.send_photo(chat_id: chat.id, photo: Faraday::UploadIO.new('./success_sent.jpg', 'image/jpeg'))

    logger.debug "sending '#{text}' to #{chat.username}"
  end
end
