class Avo::Resources::Track < Avo::BaseResource
  self.title = :title
  self.icon = "tabler/outline/music"
  self.visible_on_sidebar = false

  def fields
    field :id, as: :id, only_on: :index
    field :trackable, as: :belongs_to, polymorphic_as: :trackable, types: [ ::Release, ::Event ], name: "Belongs to"
    # Lists show long text shortened (…), so they never scroll sideways
    field :title, as: :text, required: true, format_index_using: -> { value.to_s.truncate(40, omission: "…") }
    # Recordings only (release tracks always show their 0:45 preview)
    field :duration, as: :text, hide_on: :forms, visible: -> { resource.record.nil? || !resource.record.release? },
      help: "Recordings: read from the file after an upload."
    field :position, as: :number, help: "Order: 1 first, then 2 and so on."
    # Filled in after an upload: shown, never typed
    field :audio_path, as: :text, hide_on: :forms, format_index_using: -> { value.present? ? File.basename(value).truncate(34, omission: "…") : value },
      help: "Where the file is in the public bucket, filled in after an upload."
    field :master_upload, as: :file, accept: "audio/*", hide_on: :index, name: "Audio file (upload)",
      help: "Upload the MP3 here. Releases: the full track stays private and a 45-second preview is made from it. Event recordings: published in full for streaming. Either way it takes a moment after Save; refresh to see the audio path."
    # Release tracks only: where the upload's full file is kept (shown, never typed)
    field :master_path, as: :text, only_on: :show, visible: -> { resource.record&.release? },
      help: "Where the full file is in the private bucket, filled in after an upload."
    field :preview_start, as: :number, hide_on: :index, visible: -> { resource.record.nil? || resource.record.release? }, help: "Releases: where the 45-second preview starts, in seconds."
  end
end
