class Notification < ApplicationRecord
  ACCEPT_OFFER_TITLE = I18n.t("notification_mobile.notification.accept_your_offer")
  CONFIRM_ACCEPT_TITLE = I18n.t("notification_mobile.notification.confirmed_to_help")
  COMPLETE_HELP_REQUEST_TITLE = I18n.t("notification_mobile.notification.completed_to_help_request")
  COMPLETE_OFFER_TITLE = I18n.t("notification_mobile.notification.completed_to_help_offer")
  HELP_REQUEST_TITLE = I18n.t("notification_mobile.notification.need_help")
  OFFER_REQUEST_TITLE = I18n.t("notification_mobile.notification.offered_help_on_your_request")
  RATING_TITLE = I18n.t("notification_mobile.notification.give_rate")
  START_CONVERSATION_TITLE = I18n.t("notification_mobile.notification.invited_join")

  CANCAL_AN_OFFER_TITLE = I18n.t("notification_mobile.notification.cancelled_offer")
  CANCEL_OTHER_OFFER_TITLE = I18n.t("notification_mobile.notification.cancelled_accept")
  CANCEL_ACCEPT_TITLE = I18n.t("notification_mobile.notification.rejected_accept")
  REJECT_TITLE = I18n.t("notification_mobile.notification.chosen_another_helper")

  GREEN_LEVEL_MESSAGE = 'Normal'
  YELLOW_LEVEL_MESSAGE = 'Assistance'
  RED_LEVEL_MESSAGE = 'Urgent'

  acts_as_paranoid

  belongs_to :chat, optional: true
  belongs_to :chat_room, optional: true
  belongs_to :help_request, -> { with_deleted }, optional: true
  belongs_to :offer_request, -> { with_deleted }, optional: true
  belongs_to :owned_offer_request, -> (noti) { only_deleted.where(user_id: noti.user_id) }, class_name: 'OfferRequest', foreign_key: "offer_request_id", optional: true
  belongs_to :rate, optional: true
  belongs_to :user

  include ApplyReadAll

  scope :with_current_user, -> (current_user, page) { where(user_id: current_user).order(created_at: :desc).paginate(page: page, per_page: 99) }

  def set_font_bold_syntax(username)
    "<span class='font-weight-bold'>#{username}</span>"
  end

  def as_title_notification_format
    if help_request.present?
      "#{set_font_bold_syntax(help_request.user.username)} #{HELP_REQUEST_TITLE}"
    elsif owned_offer_request.present?
      "#{set_font_bold_syntax(offer_request.owned_help_request_user.username)} #{REJECT_TITLE}"
    elsif offer_request.present?
      if check_is_cancelled?
        "#{set_font_bold_syntax(offer_request.owned_help_request_user.username)} #{CANCEL_OTHER_OFFER_TITLE}"
      elsif is_offer_rejected
        "#{set_font_bold_syntax(offer_request.owned_help_request_user.username)} #{CANCEL_ACCEPT_TITLE}"
      elsif is_offer_cancelled
        "#{set_font_bold_syntax(offer_request.user.username)} #{CANCAL_AN_OFFER_TITLE}"
      else
        "#{set_font_bold_syntax(offer_request.user.username)} #{OFFER_REQUEST_TITLE}"
      end
    elsif chat.present?
      case chat.type
      when StartChat::MESSAGE
        "#{set_font_bold_syntax(chat_room.help_request_user.username)} #{START_CONVERSATION_TITLE}"
      when AcceptChat::MESSAGE
        check_is_owner? ?
        "#{set_font_bold_syntax(chat_room.help_request_user.username)} #{ACCEPT_OFFER_TITLE}" :
        "#{set_font_bold_syntax(chat.user.username)} #{CONFIRM_ACCEPT_TITLE}"
      when ConfirmChat::MESSAGE
        check_is_owner? ?
        "#{set_font_bold_syntax(chat_room.help_request_user.username)} #{COMPLETE_OFFER_TITLE}" :
        "#{set_font_bold_syntax(chat.user.username)} #{COMPLETE_HELP_REQUEST_TITLE}"
      end
    elsif rate.present?
      "#{set_font_bold_syntax(rate.offer_request.owned_help_request_user.username)} #{RATING_TITLE}"
    end
  end

  def as_notification_format(current_user)
    self.slice(:id, :chat_room, :is_read).merge(
      {
        chat: chat&.as_chat_format,
        help_request: help_request&.as_help_request_format(current_user) || nil,
        offer_request: offer_request&.as_self_user_format(current_user) || nil,
        rate: rate&.as_rate_notification_format(current_user) || nil,
        title: as_title_notification_format,
        created_at: TimeToHumanWord.calculator_time_to_human_word(created_at),
        user: user&.as_profile_json
      }
    )
  end

  private
  def check_rate_avialable(current_user)
    return if rate.blank?
    rate.offer_request.help_request.as_help_request_format(current_user)
  end

  def check_is_owner?
    chat_room.help_request_user.id != user.id
  end

  def check_is_cancelled?
    check_avialable_accept_type = offer_request.chat_room.chats.find_by(type: AcceptChat::MESSAGE) rescue nil
    offer_request.helpee_request_status_id == OfferRequest::PENDING_STATUS && check_avialable_accept_type.present?
  end
end
