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

    search_metadata!(collection)
  end
  
  def search_metadata!(results)
    _set_value :currentPage,  results.current_page
    _set_value :totalPages,   results.total_pages
    _set_value :totalEntries, results.total_entries
    _set_value :perPage,      results.per_page
  end
end
