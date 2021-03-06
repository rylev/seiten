defmodule Seiten do
  defprotocol Paginated do
    def paginate(resources, page)
  end

  defmacro __using__(_opts) do
    quote do
      @page_size 10
      @resource_name nil

      def paginate(resources) do
        current_page = Seiten.current_page(resources)
        paginate(resources, current_page)
      end
      def paginate(resources, conn = %Plug.Conn{}) do
        current_page = Seiten.current_page(conn, resource_name)
        resources |> paginate(current_page)
      end
      def paginate(resources, page) do
        Paginated.paginate(resources, page)
      end

      def paginated_html(conn, resources = %{pages_count: count}) do
        if count > 1 do
          html = ~s"""
          <div class="pagination">
          #{Seiten.previous_link(conn, resources)}
          #{for page <- Seiten.pages_range(resources), do: Seiten.page_link(conn, resources, page)}
          #{Seiten.next_link(conn, resources)}
          </div>
          """
          {:safe, html}
        else
          {:safe, ""}
        end
      end

      def page_size do
        @page_size
      end

      def resource_name do
        @resource_name || resource_name_from_module
      end

      def resource_name_from_module do
        __MODULE__
        |> Module.split
        |> Enum.to_list
        |> List.last
        |> String.downcase
      end

      defmodule Pages do
        defstruct resources: [], page: 1, pages_count: 0, name: ""
      end

      defimpl Paginated, for: List do
        def paginate(resources, current_page) do
          page_size = unquote(__CALLER__.module).page_size
          paged_resources = Enum.slice resources, ((current_page - 1) * page_size), page_size
          %Pages{resources: paged_resources, page: current_page, pages_count: pages_count(resources), name: unquote(__CALLER__.module).resource_name}
        end

        defp pages_count(resources) do
          (resources |> Enum.count |> div(unquote(__CALLER__.module).page_size)) + 1
        end
      end
    end
  end

  def pages_range(%{pages_count: count}) do
    1..count
  end
  def pages_range(resources) do
    resources|> Paginated.paginate(1) |> pages_range
  end

  def current_page(%{page: page}) do
    page
  end
  def current_page(_resources) do
    1
  end

  def current_page(conn = %Plug.Conn{}, %{name: resource_name}) do
    current_page(conn, resource_name)
  end
  def current_page(conn = %Plug.Conn{}, resource_name) when is_binary(resource_name) do
    page = conn.params[page_param(resource_name)] || "1"
    {page, _} = Integer.parse(page)
    page
  end

  defp page_param("") do
    "page"
  end
  defp page_param(resource_name) do
    resource_name <> "_page"
  end

  def last_page(paged = %{}) do
    paged |> pages_range |> Enum.to_list |> List.last
  end

  def previous_link(conn, %{name: resource_name}) do
    predicate = fn current_page -> current_page > 1 end
    page_number = fn current_page -> current_page - 1 end
    page_html(conn, resource_name, "Previous", predicate, page_number)
  end

  def next_link(conn, resources = %{name: resource_name}) do
    predicate = fn current_page -> current_page < last_page(resources) end
    page_number = fn current_page -> current_page + 1 end
    page_html(conn, resource_name, "Next", predicate, page_number)
  end

  def page_link(conn, %{name: resource_name}, page) do
    predicate = fn current_page -> current_page != page end
    page_number = fn _current_page -> page end
    page_html(conn, resource_name, page, predicate, page_number)
  end

  def page_html(conn, resource_name, page_name, predicate, page_number) do
    current_page = current_page(conn, resource_name)
    if predicate.(current_page) do
      page_anchor_tag(conn, resource_name, page_number.(current_page), page_name)
    else
      ~s"""
        <span>#{page_name}</span>
      """
    end
  end

  def page_anchor_tag(conn, resource_name, page_number, page_name) do
    query = Plug.Conn.Query.decode conn.query_string
    query = Dict.put query, page_param(resource_name), page_number
    query = Plug.Conn.Query.encode query
    link = Plug.Conn.full_path(conn) <> "?" <> query
    ~s"""
    <a href="#{link}">#{page_name}</a>
    """
  end
end
