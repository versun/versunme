class Current < ActiveSupport::CurrentAttributes
  attribute :session, :site
  delegate :user, to: :session, allow_nil: true
end
