# Seiten

Seiten is a simple pagination library for Elixir.

Seiten is Plug compatibile so it can be used with virtually any Elixir web
framework including [Phoenix](http://www.phoenixframework.org).

## Installation

Add Seiten to your deps in your `mix.exs` file.

```elixir
def deps do
  [{:seiten "0.0.1"}]
end
```

## Usage

```elixir
defmodule Users do
  use Seiten
end

my_resources = Enum.to_list [1..100]

paged = Users.paginate(conn, my_resources)

# In a view:
<%= Users.paginated_html(conn, paged) %>
```
