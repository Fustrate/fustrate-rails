# frozen_string_literal: true

# Copyright (c) 2020 Steven Hoffman
# All rights reserved.

class Jbuilder
  def pagination!(results)
    _set_value :currentPage,  results.current_page
    _set_value :totalPages,   results.total_pages
    _set_value :totalEntries, results.total_entries
    _set_value :perPage,      results.per_page
  end
end
