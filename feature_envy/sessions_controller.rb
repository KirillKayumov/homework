class SessionsControler < ApplicationController
  def create
    # ...
    update_device_information(user, params[:device_token]) if params[:device_token].present?
    # ...
  end

  private

  def update_device_information(user, device_token)
    device = Device.find_or_initialize_by_token(device_token)
    device.user_id = user.id
    device.last_sign_in_at = Time.now

    device.save
  end
end


----------------------------------------------------------------------------------------


class SessionsControler < ApplicationController
  def create
    # ...
    update_device_information(user, params[:device_token]) if params[:device_token].present?
    # ...
  end

  private

  def update_device_information(user, device_token)
    device = Device.find_or_initialize_by_token(device_token)
    device.user_id = user.id
    device.last_sign_in_at = Time.now

    device.save
  end
end
