class EventsController < ApplicationController
  allow_unauthenticated_access

  def show
    @event = Event.published.includes(images: { file_attachment: :blob }).find_by!(slug: params[:slug])
  end

  # The calendar file behind "Add to Calendar" (upcoming events only)
  def calendar
    event = Event.published.find_by!(slug: params[:slug])
    send_data EventCalendar.new(event, url: event_url(event)).to_ics, type: "text/calendar", disposition: "inline", filename: "#{event.slug}.ics"
  end
end
