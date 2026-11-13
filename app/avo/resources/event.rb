class Avo::Resources::Event < Avo::BaseResource
  # The admin's links use the slug (Slugged#to_param); bulk actions pass several
  self.find_record_method = -> { id.is_a?(Array) ? query.where(slug: id).or(query.where(id: id)) : query.find_by_param!(id) }
  self.title = :title
  self.icon = "tabler/outline/calendar-event"
  self.includes = [ images: { file_attachment: :blob } ]
  self.default_sort_column = :date
  self.search = {
    query: -> { query.where("title LIKE ? OR slug LIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id, only_on: :index

    # Photos, then the recordings (also on Edit)
    field :images, as: :has_many, show_on: :edit
    field :tracks, as: :has_many, name: "Recordings", show_on: :edit

    # The event
    field :published, as: :boolean, help: "Off keeps it off the site."
    field :title, as: :text, required: true, help: "The first line under the poster, and the browser tab, e.g. Margate Electronics #13: Ambient Garden"
    field :slug, as: :text, required: true, help: "The page address: me-13 makes /events/me-13/. Lower case, numbers and dashes."
    field :date, as: :date, format: "dd.LL.yyyy", picker_format: "d.m.Y", required: true, help: "Upcoming until this day, then archived. The page's status line follows it: 'Upcoming – 9 Oct 2026', then 'Archived – 9 Oct 2026'."
    field :doors_at, as: :text, hide_on: :index, help: "e.g. 7PM. Shown as 'Time: Doors 7PM / Music 8PM' before the night."
    field :music_at, as: :text, hide_on: :index, help: "e.g. 8PM"
    field :venue, as: :text, hide_on: :index, help: "Shown as 'Venue: …', e.g. Margate Arts Club, Margate, UK"
    field :external_ticket_url, as: :text, hide_on: :index, help: "Ticket link, shown while the event is upcoming."
    field :tickets, as: :text, hide_on: :index, name: "Ticket prices",
      help: "Shown as 'Tickets: …' beside the Book Tickets button before the night, e.g. £8, £10 adv / £13 otd / £20 ticket+tape"
    field :sold_out, as: :boolean, help: "Tickets gone: Sold Out instead of the ticket button (until the date, then Archived)."

    # Text
    field :heading, as: :tiptap,
      help: "Optional large heading at the top of the page. Enter starts a new line. Select text for italic or White."
    # The lineup, under the title: each line only when filled in
    field :live, as: :tiptap, name: "Live", help: "Shown as 'Live: …'. One line; select names to link them. Leave empty to leave it out."
    field :dj, as: :tiptap, name: "DJ", help: "Shown as 'DJ: …'. One line; select names to link them. Leave empty to leave it out."
    field :screening, as: :tiptap, name: "Screening", help: "Shown as 'Screening: …'. One line; select names to link them. Leave empty to leave it out."
    field :workshop, as: :tiptap, name: "Workshop", help: "Shown as 'Workshop: …'. One line; select names to link them. Leave empty to leave it out."
    field :description, as: :tiptap, name: "Description (the free text)",
      help: "Under the title, lineup, venue, date and time, which are written from the fields above. Enter starts a new paragraph, Shift+Enter a new line in the same one."

    # The home page tile
    field :show_tile_text, as: :boolean, name: "Text on the home tile", hide_on: :index,
      help: "Show the text under the tile's photo: the heading (or title) and the lineup, written from the fields above."
    field :tile_ratio, as: :select, options: Avo::Resources::Image::SHAPES, include_blank: "The photo's own shape",
      hide_on: :index, help: "Crop of the photo on the home tile."
    field :home_position, as: :number, name: "Home position", hide_on: :index,
      help: "Optional. Pins it to the top of the home page: 1 first, then 2 and so on. Leave empty to follow the date order."

    # The scattered photos
    field :reshuffle, as: :number, name: "Reshuffle photos", hide_on: :index, min: 0,
      help: "The arrangement of the scattered photos on wide screens. Change the number (1, 2, 3…) for a new one; 0 is the original."
  end
end
