class OrdersController < ApplicationController
  def new
    @order = Order.new
  end

  def create
    @order = Order.new(params[:order])

    basket.products.each do |product|
      @order.order_items << OrderItem.new(
        :product_id  => product.id,
        :product_uid => product.uid,
        :count       => basket.product_count(product),
        :cost        => basket.product_cost(product)
      )
    end

    if @order.save
      @order.order_items.each {|i| basket.remove_product_id(i.product_id) }
      user_orders << @order.id.to_s
      flash[:new_order] = true

      mail_config = app_settings.mail_config
      mail_config = 'office@example.com' if mail_config.blank?
      ActionMailer::Base.smtp_settings = SMTP_SETTINGS[mail_config]

      Notifier.deliver_new_order_notification(
        @order,
        render_to_string(:template => 'admin/orders/show.xls', :layout => false),
        mail_config
      )

      if app_settings.gcal_sms_notifier
        logger.info "Sending SMS Notification"
        SmsNotifier.send_new_order_notification(@order,
          :gcal_login    => 'office@example.com',
          :gcal_password => SMTP_SETTINGS['office@example.com'][:password]
        ) rescue logger.error("SmsNotifier error")
      end

      redirect_to @order
    else
      flash[:error] = "Необходимо заполнить поля подсвеченные красным"
      render 'new'
    end
  end

  def show
    if user_orders.include?(params[:id])
      @order = Order.find(params[:id])
    end

    render :file => "public/404.html", :layout => false, :status => 404 if @order.blank?
  end

  def index
    if user_orders
      @orders = Order.find(user_orders)
      user_orders_update(@orders)
    end
  end

  private

  def user_orders
    (session[:orders] ||= []) # .select{|o| o.to_s.size > 20}
  end

  def user_orders_update(orders)
    session[:orders] = orders.map(&:id).map(&:to_s)
  end
end


----------------------------------------------------------------------------------------


class OrdersController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, :render_404

  def new
    @order = Order.new
  end

  def create
    result = CreateOrder.call(basket: basket, order_params: order_params)

    if result.success?
      flash[:new_order] = true
      redirect_to result.order
    else
      flash[:error] = "Необходимо заполнить поля подсвеченные красным"
      render 'new'
    end
  end

  def show
    raise ActiveRecord::RecordNotFound if user_orders.exclude?(params[:id])
    @order = Order.find(params[:id])
  end

  def index
    @orders = Order.find(user_orders)
    user_orders_update(@orders)
  end

  private

  def order_params
    params.require(:order).permit(...)
  end

  def user_orders
    session[:orders] || []
  end

  def render_404
    render :file => "public/404.html", :layout => false, :status => 404
  end

  def user_orders_update(orders)
    session[:orders] = orders.map(&:id).map(&:to_s)
  end
end


class CreateOrder
  include Interactor::Organizer

  organize SaveOrder, RemoveOrderItems, SendNewOrderEmailNotification, SendNewOrderSMSNotification
end

class SaveOrder
  include Interactor

  def call
    build_order
    assign_order_items

    context.fail! unless context.order.save
  end

  private

  def build_order
    context.order = Order.new(context.order_params)
  end

  def assign_order_items
    context.basket.products.each do |product|
      context.order.order_items << OrderItem.new(
        :product_id  => product.id,
        :product_uid => product.uid,
        :count       => basket.product_count(product),
        :cost        => basket.product_cost(product)
      )
    end
  end
end

class RemoveOrderItems
  include Interactor

  def call
    context.order.order_items.each { |i| context.basket.remove_product_id(i.product_id) }
  end
end

class SendNewOrderEmailNotification
  include Interactor

  before do
    context.mail_config = app_settings.mail_config.presence || 'office@example.com'
    ActionMailer::Base.smtp_settings = SMTP_SETTINGS[context.mail_config]
  end

  def call
    Notifier.deliver_new_order_notification(
      context.order,
      render_to_string(:template => 'admin/orders/show.xls', :layout => false),
      context.mail_config
    )
  end
end

class SendNewOrderSMSNotification
  include Interactor

  def call
    if app_settings.gcal_sms_notifier
      logger.info "Sending SMS Notification"
      SmsNotifier.send_new_order_notification(context.order,
        :gcal_login    => 'office@example.com',
        :gcal_password => SMTP_SETTINGS['office@example.com'][:password]
      ) rescue logger.error("SmsNotifier error")
    end
  end
end
