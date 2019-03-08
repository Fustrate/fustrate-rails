# frozen_string_literal: true

class Jbuilder
  def collection!(collection, *options)
    if ::Kernel.block_given?
      _set_value :data, (_scope { array! collection, &::Proc.new })
    else
      _set_value :data, (_scope { array! collection, *options })
    end
  end

  def paginated_collection!(collection, *options)
    if ::Kernel.block_given?
      _set_value :data, (_scope { array! collection, &::Proc.new })
    else
      _set_value :data, (_scope { array! collection, *options })
    end

    _set_value :currentPage,  collection.current_page
    _set_value :totalPages,   collection.total_pages
    _set_value :totalEntries, collection.total_entries
    _set_value :perPage,      collection.per_page
  end
end
