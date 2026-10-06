class Avo::Resources::User < Avo::BaseResource
  self.title = :email_address
  self.icon = "tabler/outline/users"

  def fields
    field :id, as: :id
    field :email_address, as: :text, required: true
    field :password, as: :password, only_on: :forms, help: "Leave blank to keep the current password."
    field :password_confirmation, as: :password, only_on: :forms
  end
end
