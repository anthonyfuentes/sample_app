module ApplicationHelper

  # Returns full title on per-page basis.
  def full_title(page_title = nil)
    base_title = "Sample App"
    page_title ? "#{ page_title } | #{ base_title }" : base_title
  end

end
