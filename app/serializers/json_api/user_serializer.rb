class JsonApi::UserSerializer
  include JSONAPI::Serializer
  attributes :id, :first_name, :last_name

  attribute :full_name do |record|
    "#{record.first_name} #{record.last_name}"
  end
end
