defmodule Ibanity.Collection do
  defstruct [
    class: nil,
    items: [],
    page_limit: nil,
    before_cursor: nil,
    after_cursor: nil,
    first_link: nil,
    next_link: nil,
    previous_link: nil,
    latest_synchronization: nil,
    synchronized_at: nil
  ]

  def new(class, items, paging, links, synchronized_at \\ nil, latest_synchronization \\ nil) do
    %__MODULE__{
      class: class,
      items: items,
      page_limit: paging["limit"],
      before_cursor: paging["before"],
      after_cursor: paging["after"],
      first_link: links["first"],
      next_link: links["next"],
      previous_link: links["previous"],
      synchronized_at: synchronized_at,
      latest_synchronization: latest_synchronization
    }
  end
end