# app/logic/fcm_notification.rb
module FcmNotification
  module_function
  def source_data_notification(topic, message = nil, image = nil, uid = nil, model = nil)
    fcm_client = FCM.new(Rails.application.credentials[:FCM_KEY_SERVER])
    options = {
      priority: 'high',
      data: {
        message: model,
        icon: image
      },
      notification: {
        title: topic,
        body: message,
        sound: 'default'
      }
    }

    registration_id = [uid]

    response = fcm_client.send(registration_id, options)
    response
  end

  def push_notification(topic, message = nil, image = nil, user = nil, model = nil)
    source_data_notification(topic, message, image, user.user_device_id, model)
    Pusher.trigger("user-#{user.id}", "receive-notifications", nil) unless topic == 'You got 1 message!'
  end
end
