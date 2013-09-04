class AppointmentRequestsController < ApplicationController
  def new
    @availability = Availability.find_by_id(params[:availability_id])
    @appointment_request = Appointment.new
    return redirect_to availabilities_path unless @availability.present?
  end

  def create
    @availability = Availability.find_by_id(params[:availability_id])

    mentee_params = params[:appointment].delete(:user)
    params.merge!(mentee_params)
    @appointment_request = Appointment.new
    mentee = User.find_by_email(params[:email])
    if mentee.nil? || !mentee.activated?
      mentee = User.create!(user_params).send_activation
      flash.now[:notice] = "Please go check your email, ok? Then come back and re-submit."
      render :new
    else
      flash[:notice] = "An email has been sent to #{@availability.mentor.first_name}. Once they confirm the appointment, we'll let you know."
      mentee.send_appointment_request(@availability)
      redirect_to root_path
    end
  end
end