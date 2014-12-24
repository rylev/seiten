# Seiten

Seiten is a simple pagination library for Elixir.

Seiten is Plug compatibile so it can be used with virtually any Elixir web
framework including [Phoenix](http://www.phoenixframework.org).

## Installation

Add Seiten to your deps in your `mix.exs` file.

```elixir
def deps do
  [{:plug, "~> 0.9.0"}
   {:seiten "0.0.1"}]
end
```

## Usage

```elixir
## render paginated links
<%= paginate @conn, @all_my_resources %>

## access your resources on the current page
paginated_resources(conn, all_my_resources)
```
