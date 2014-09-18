module Slug

  def name_to_slug name
    name.tr(" ","-")
  end

  def slug_to_name slug
    slug.tr("-"," ")
  end
end
