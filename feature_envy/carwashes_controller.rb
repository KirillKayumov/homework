class CarwashesController < ApplicationController
  def summary
    userdata = session[:userdata]
    code = params[:code]

    ticket = Ticket.find(userdata[:ticket_id])

    if code.present? && code.to_i == ticket.code
      ticket.status = Ticket::NEW
      ticket.save

      return redirect_to summary_carwash_path
    end

    redirect_to confirm_step_carwash_path, alert: "Код подтверждения неправильный"
  end
end


----------------------------------------------------------------------------------------


class TicketsController < ApplicationController
  def create
    ticket = Ticket.find(userdata[:ticket_id])

    if code.present? && code.to_i == ticket.code
      ticket.status = Ticket::NEW
      ticket.save

      redirect_to summary_carwash_path
    end

    redirect_to confirm_step_carwash_path, alert: "Код подтверждения неправильный"
  end

  private

  def userdata
    session[:userdata]
  end

  def code
    params[:code]
  end
end
